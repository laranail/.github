#!/usr/bin/env bash
# Tests for scripts/audit-private-default-branches.sh, run against a fake `gh`
# so no token or network is needed:
#
#   bash scripts/tests/audit-private-default-branches.test.sh
#
# The fixture org has one private repository with four commits on main: one
# merged through a pull request, the root commit, one direct push that is on the
# exemption list, and one direct push that is not. The audit must fail on the
# unlisted one and only that one.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
audit="$here/../audit-private-default-branches.sh"
work=$(mktemp -d "${TMPDIR:-/tmp}/audit-test.XXXXXX")
trap 'rm -rf "$work"' EXIT

merged=1111111111111111111111111111111111111111
root=2222222222222222222222222222222222222222
listed=3333333333333333333333333333333333333333
unlisted=4444444444444444444444444444444444444444

mkdir -p "$work/bin"
cat > "$work/bin/gh" <<EOF
#!/usr/bin/env bash
# Answers only the calls the audit makes, already in the shape its --jq produces.
all="\$*" path="" jq=""
shift # api
while [ \$# -gt 0 ]; do
  case "\$1" in
    --jq) jq=\$2; shift ;;
    -*) ;;
    *) [ -n "\$path" ] || path=\$1 ;;
  esac
  shift
done
case "\$path" in
  orgs/fixture/repos*)                 echo "app main" ;;
  repos/fixture/app/commits\?*)        printf '%s\n' \${FAKE_COMMITS:-$merged $root $listed $unlisted} ;;
  repos/fixture/app/commits/$merged/pulls) echo 1 ;;
  repos/fixture/app/commits/*/pulls)   echo 0 ;;
  repos/fixture/app/commits/$root)     case "\$jq" in *parents*) echo 0 ;; *) echo "Initial release" ;; esac ;;
  repos/fixture/app/commits/*)         case "\$jq" in *parents*) echo 1 ;; *) echo "A direct push" ;; esac ;;
  *) echo "fake gh: unexpected call: \$all" >&2; exit 99 ;;
esac
EOF
chmod +x "$work/bin/gh"

cat > "$work/exemptions" <<EOF
# comment lines and blank lines are ignored

fixture/app  $listed  2026-10-12  Pushed directly when the repository was first published.
other/app    $unlisted  2026-10-12  Same SHA in another org must not exempt it here.
EOF

pass=0 fail=0
check() { # check <name> <expected exit> <pattern expected in output> [<pattern that must not appear>]
  local name=$1 want=$2 needle=$3 forbid=${4:-} got out
  set +e
  out=$(PATH="$work/bin:$PATH" AUDIT_EXEMPTIONS=${EXEMPTIONS:-$work/exemptions} GITHUB_STEP_SUMMARY='' \
        bash "$audit" fixture 14 2>&1)
  got=$?
  set -e
  if [ "$got" = "$want" ] && grep -Fq -- "$needle" <<< "$out" \
     && { [ -z "$forbid" ] || ! grep -Fq -- "$forbid" <<< "$out"; }; then
    pass=$((pass + 1)); echo "ok   $name"
  else
    fail=$((fail + 1)); echo "FAIL $name (exit $got, want $want)"; printf '     %s\n' "$out"
  fi
}

check "an unlisted direct push still fails" 1 \
  "$unlisted reached main without a merged pull request" \
  "$listed reached main"

check "the listed commit is exempt and named" 1 "exempt: fixture/app $listed"

FAKE_COMMITS="$merged $root $listed" check "with only listed commits the audit passes" 0 \
  "0 without a pull request"

FAKE_COMMITS="$merged $root" check "an entry outside the window is reported for pruning" 0 \
  "can be removed: fixture/app $listed"

EXEMPTIONS=/dev/null check "with no exemptions both direct pushes fail" 1 "2 without a pull request"

refuse() { # refuse <what> <line>
  printf '%s\n' "$2" > "$work/bad"
  EXEMPTIONS=$work/bad check "an exemption with $1 is refused" 2 "expected '<org>/<repo>"
}
refuse "a short SHA"           "fixture/app  ${listed:0:7}  2026-10-12  Reason."
refuse "a repository pattern"  "fixture/*    $listed  2026-10-12  Reason."
refuse "a SHA pattern"         "fixture/app  33333*  2026-10-12  Reason."
refuse "no reason"             "fixture/app  $listed  2026-10-12"
refuse "no measured date"      "fixture/app  $listed  yesterday  Reason."

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] && [ "$pass" -ge 10 ]
