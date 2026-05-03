#!/usr/bin/env bash
set -euo pipefail

# Minimal reference implementation for Scenario-driven agent workflow.
# This is intentionally conservative. It does not implement the whole workflow.
# It demonstrates how repeatable safety checks can move from prompts into scripts.

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_DIR="$ROOT_DIR/.agent/state"
CURRENT_STATE="$STATE_DIR/current.json"

usage() {
  cat <<'USAGE'
Usage:
  agentctl.sh doctor
  agentctl.sh status
  agentctl.sh start <issue>
  agentctl.sh merge-report <pr>
  agentctl.sh merge-after-human-approval <pr> <issue> <head-sha>

Notes:
  - This is a small reference script, not a complete framework.
  - It assumes GitHub CLI is installed and authenticated for GitHub operations.
  - It does not merge unless a precise APPROVE_MERGE marker exists on the PR.
USAGE
}

need_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "missing required command: $cmd" >&2
    return 1
  fi
}

repo_slug() {
  git -C "$ROOT_DIR" remote get-url origin \
    | sed -E 's#^git@github.com:##; s#^https://github.com/##; s#\.git$##'
}

json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

write_state() {
  mkdir -p "$STATE_DIR"
  local issue="$1"
  local repo="$2"
  cat > "$CURRENT_STATE" <<EOF
{
  "issue": "$issue",
  "repo": "$repo",
  "status": "started"
}
EOF
}

doctor() {
  local failed=0
  need_cmd git || failed=1
  need_cmd gh || failed=1
  need_cmd python3 || failed=1

  if command -v gh >/dev/null 2>&1; then
    gh auth status >/dev/null 2>&1 || {
      echo "gh is installed but not authenticated" >&2
      failed=1
    }
  fi

  if [ "$failed" -eq 0 ]; then
    echo "doctor: ok"
  else
    echo "doctor: failed" >&2
    return 1
  fi
}

status() {
  if [ -f "$CURRENT_STATE" ]; then
    cat "$CURRENT_STATE"
  else
    echo "no current workflow state found"
  fi
}

start() {
  local issue="${1:-}"
  if [ -z "$issue" ]; then
    echo "start requires an issue number" >&2
    return 1
  fi

  doctor
  local repo
  repo="$(repo_slug)"
  write_state "$issue" "$repo"
  echo "started scenario workflow for issue #$issue in $repo"
  echo "Next: ask the planner agent to classify the issue and prepare a decision brief if needed."
}

assert_clean_enough_for_merge_gate() {
  local pr="$1"
  local repo
  repo="$(repo_slug)"

  local files
  files="$(gh pr diff "$pr" --repo "$repo" --name-only)"

  if echo "$files" | grep -E '(^|/)(\.env|\.env\.|secrets?|credentials?)(/|$)' >/dev/null; then
    echo "stop: PR appears to touch secrets or environment files" >&2
    return 1
  fi

  if echo "$files" | grep -E '^\.github/workflows/' >/dev/null; then
    echo "stop: PR touches GitHub Actions workflows; human review required" >&2
    return 1
  fi
}

current_pr_head() {
  local pr="$1"
  local repo
  repo="$(repo_slug)"
  gh pr view "$pr" --repo "$repo" --json headRefOid --jq '.headRefOid'
}

check_required_checks() {
  local pr="$1"
  local repo
  repo="$(repo_slug)"

  local status
  status="$(gh pr checks "$pr" --repo "$repo" --json state --jq '[.[].state] | unique | join(",")' 2>/dev/null || true)"

  if [ -z "$status" ]; then
    echo "warning: no PR checks were found; relying on local evidence and human review" >&2
    return 0
  fi

  if echo "$status" | grep -E 'FAIL|ERROR|CANCEL|PENDING|QUEUED|IN_PROGRESS|SKIPPED' >/dev/null; then
    echo "stop: PR checks are not all passing: $status" >&2
    return 1
  fi
}

require_marker_in_pr_comments() {
  local pr="$1"
  local marker="$2"
  local repo
  repo="$(repo_slug)"

  gh pr view "$pr" --repo "$repo" --comments --json comments \
    --jq '.comments[].body' | grep -F "$marker" >/dev/null
}

merge_report() {
  local pr="${1:-}"
  if [ -z "$pr" ]; then
    echo "merge-report requires a PR number" >&2
    return 1
  fi

  doctor
  assert_clean_enough_for_merge_gate "$pr"
  check_required_checks "$pr"

  local head
  head="$(current_pr_head "$pr")"

  cat <<EOF
codex-merge-report:v1

PR: #$pr
Head: $head

Pre-merge checks performed by agentctl:
- Checked for secret/env-like file changes.
- Checked for GitHub workflow changes.
- Checked GitHub PR checks when available.

Human approval marker required before merge:

APPROVE_MERGE pr=$pr head=$head report=codex-merge-report:v1
EOF
}

merge_after_human_approval() {
  local pr="${1:-}"
  local issue="${2:-}"
  local approved_head="${3:-}"

  if [ -z "$pr" ] || [ -z "$issue" ] || [ -z "$approved_head" ]; then
    echo "merge-after-human-approval requires: <pr> <issue> <head-sha>" >&2
    return 1
  fi

  doctor
  assert_clean_enough_for_merge_gate "$pr"
  check_required_checks "$pr"

  local current_head
  current_head="$(current_pr_head "$pr")"
  if [ "$current_head" != "$approved_head" ]; then
    echo "stop: PR head moved after approval" >&2
    echo "approved: $approved_head" >&2
    echo "current:  $current_head" >&2
    return 1
  fi

  require_marker_in_pr_comments "$pr" "codex-merge-report:v1" || {
    echo "stop: missing codex-merge-report:v1 marker in PR comments" >&2
    return 1
  }

  require_marker_in_pr_comments "$pr" "agent-test-evidence:v1" || {
    echo "stop: missing agent-test-evidence:v1 marker in PR comments" >&2
    return 1
  }

  local approval="APPROVE_MERGE issue=$issue pr=$pr head=$approved_head report=codex-merge-report:v1"
  require_marker_in_pr_comments "$pr" "$approval" || {
    echo "stop: missing exact human approval marker:" >&2
    echo "$approval" >&2
    return 1
  }

  gh pr merge "$pr" --squash --delete-branch
  gh issue close "$issue" --comment "Closed after guarded merge of PR #$pr."
}

main() {
  local cmd="${1:-}"
  shift || true

  case "$cmd" in
    doctor) doctor "$@" ;;
    status) status "$@" ;;
    start) start "$@" ;;
    merge-report) merge_report "$@" ;;
    merge-after-human-approval) merge_after_human_approval "$@" ;;
    -h|--help|help|"") usage ;;
    *)
      echo "unknown command: $cmd" >&2
      usage >&2
      return 1
      ;;
  esac
}

main "$@"
