#!/usr/bin/env bash
# audit-private-default-branches.sh <org> [days]
#
# Every change reaches a default branch through a pull request. Public
# repositories enforce that with a ruleset; private ones cannot, because
# rulesets on private repositories need GitHub Pro and the API answers 403.
# There the rule is held by practice, and practice needs something that notices
# when it slips. This is that: every commit on each private repository's default
# branch in the last <days> days must belong to a merged pull request, or the
# run fails and names it.
#
# Needs GH_TOKEN able to read the org's private repositories and their pull
# requests (contents: read, pull-requests: read).
#
# Commits already known to have reached a default branch directly are listed,
# one exact repository and SHA per line with a reason and a date, in
# audit-private-default-branches.exemptions beside this script
# (AUDIT_EXEMPTIONS overrides the path). Anything not on that list still fails.
set -euo pipefail

org=${1:?usage: audit-private-default-branches.sh <org> [days]}
days=${2:-14}
case "$days" in ''|*[!0-9]*) echo "days must be a whole number, got: $days" >&2; exit 2 ;; esac
exemptions_file=${AUDIT_EXEMPTIONS:-"$(dirname "$0")/audit-private-default-branches.exemptions"}
exempt=""
if [ -f "$exemptions_file" ]; then
  lineno=0
  while IFS= read -r line || [ -n "$line" ]; do
    lineno=$((lineno + 1))
    case "$line" in ''|'#'*) continue ;; esac
    read -r e_repo e_sha e_date e_reason <<< "$line"
    # An entry covers exactly one commit in one repository, and says why and when.
    # Anything looser -- a pattern, a short SHA, a missing reason -- is refused
    # rather than read generously, so the list cannot grow into a blanket pass.
    if ! [[ "$e_repo" =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$ ]] \
       || ! [[ "$e_sha" =~ ^[0-9a-f]{40}$ ]] \
       || ! [[ "$e_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] \
       || [ -z "${e_reason:-}" ]; then
      echo "::error::$exemptions_file:$lineno: expected '<org>/<repo> <40-char sha> <YYYY-MM-DD> <reason>', got: $line" >&2
      exit 2
    fi
    [ "${e_repo%%/*}" = "$org" ] && exempt+="$e_repo $e_sha"$'\n'
  done < "$exemptions_file"
fi
matched=""

since=$(date -u -d "-${days} days" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-"${days}"d +%Y-%m-%dT%H:%M:%SZ)

repos=$(gh api --paginate "orgs/$org/repos?type=private&per_page=100" \
          --jq '.[] | select(.archived | not) | "\(.name) \(.default_branch)"')

checked_repos=0 checked_commits=0 offenders=0
while read -r name branch; do
  [ -n "$name" ] || continue
  checked_repos=$((checked_repos + 1))
  while read -r sha; do
    [ -n "$sha" ] || continue
    checked_commits=$((checked_commits + 1))
    merged=$(gh api "repos/$org/$name/commits/$sha/pulls" --jq '[.[] | select(.merged_at != null)] | length')
    # A repository's root commit cannot arrive through a pull request -- there is no base to open
    # one against -- so the "Initial release" of a new repository is not a direct push.
    if [ "$merged" = 0 ] && [ "$(gh api "repos/$org/$name/commits/$sha" --jq '.parents | length')" = 0 ]; then
      continue
    fi
    if [ "$merged" = 0 ] && grep -Fqx "$org/$name $sha" <<< "$exempt"; then
      matched+="$org/$name $sha"$'\n'
      echo "exempt: $org/$name $sha (listed in $(basename "$exemptions_file"))"
      continue
    fi
    if [ "$merged" = 0 ]; then
      offenders=$((offenders + 1))
      subject=$(gh api "repos/$org/$name/commits/$sha" --jq '.commit.message | split("\n")[0]')
      echo "::error title=Direct push to $org/$name::$sha reached $branch without a merged pull request: $subject"
    fi
  done < <(gh api --paginate "repos/$org/$name/commits?sha=$branch&since=$since&per_page=100" --jq '.[].sha')
done <<< "$repos"

# An entry whose commit has left the window covers nothing any more. Say so, so
# the list is pruned rather than left to accumulate.
while read -r entry; do
  [ -n "$entry" ] || continue
  grep -Fqx "$entry" <<< "$matched" \
    || echo "::notice::exemption no longer matches a direct push in the last $days days and can be removed: $entry"
done <<< "$exempt"

summary="$org: $checked_repos private repositories, $checked_commits commit(s) on default branches since $since, $offenders without a pull request"
echo "$summary"
[ -n "${GITHUB_STEP_SUMMARY:-}" ] && echo "$summary" >> "$GITHUB_STEP_SUMMARY"

# A token that cannot see private repositories lists none, and an audit of
# nothing passes. That is the failure this script exists to prevent, so it is
# an error rather than a clean result.
[ "$checked_repos" -gt 0 ] || { echo "::error::$org: saw no private repositories; the token cannot read them"; exit 1; }
[ "$offenders" -eq 0 ]
