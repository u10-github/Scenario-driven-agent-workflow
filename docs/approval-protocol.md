# Explicit approval protocol

Human approval should be explicit, scoped, and machine-checkable.

A scenario may still ask for ordinary natural-language confirmation during planning, but irreversible operations should not depend only on loose phrases such as `approved` or `looks good`.

## Why plain approval text is weak

Plain text is easy for humans, but it is ambiguous for scripts.

Examples of weak approval text:

```text
approved
merge ok
LGTM
マージしてよい
```

These are weak because they do not identify:

- which Issue was approved;
- which pull request was approved;
- which head commit was reviewed;
- which merge-readiness report was accepted;
- whether the approval is still valid after new commits.

## Recommended merge approval marker

For merge approval, prefer a structured marker like this:

```text
APPROVE_MERGE issue=123 pr=45 head=abc1234 report=codex-merge-report:v1
```

A guarded merge script should verify at least the following:

- the Issue number matches the current workflow state;
- the PR number matches the current workflow state;
- the current PR head SHA still matches the approved `head` value;
- the referenced merge-readiness report exists;
- test evidence exists;
- required checks are passing;
- no blocking review is unresolved;
- no stop-condition file changes are present.

## Approval invalidation

Approval should be treated as invalid when:

- a new commit is pushed to the PR after approval;
- the merge-readiness report is regenerated;
- required checks change from passing to failing;
- the PR scope changes materially;
- a stop condition is detected.

## Human-friendly wrapper

The AI agent may still present a human-readable summary first:

```text
This PR appears ready to merge.

If you approve, reply with:

APPROVE_MERGE issue=123 pr=45 head=abc1234 report=codex-merge-report:v1
```

This keeps the human experience simple while giving scripts a precise token to verify.

## Do not treat silence as approval

Silence, emoji reactions, or vague positive comments should not be accepted as approval for irreversible operations.

Use them only as conversation signals, not as merge gates.
