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
set -euo pipefail

org=${1:?usage: audit-private-default-branches.sh <org> [days]}
days=${2:-14}
case "$days" in ''|*[!0-9]*) echo "days must be a whole number, got: $days" >&2; exit 2 ;; esac
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
    if [ "$merged" = 0 ]; then
      offenders=$((offenders + 1))
      subject=$(gh api "repos/$org/$name/commits/$sha" --jq '.commit.message | split("\n")[0]')
      echo "::error title=Direct push to $org/$name::$sha reached $branch without a merged pull request: $subject"
    fi
  done < <(gh api --paginate "repos/$org/$name/commits?sha=$branch&since=$since&per_page=100" --jq '.[].sha')
done <<< "$repos"

summary="$org: $checked_repos private repositories, $checked_commits commit(s) on default branches since $since, $offenders without a pull request"
echo "$summary"
[ -n "${GITHUB_STEP_SUMMARY:-}" ] && echo "$summary" >> "$GITHUB_STEP_SUMMARY"

# A token that cannot see private repositories lists none, and an audit of
# nothing passes. That is the failure this script exists to prevent, so it is
# an error rather than a clean result.
[ "$checked_repos" -gt 0 ] || { echo "::error::$org: saw no private repositories; the token cannot read them"; exit 1; }
[ "$offenders" -eq 0 ]
