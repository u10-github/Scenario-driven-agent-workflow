# Explicit approval protocol

Human approval should be explicit, scoped, and machine-checkable.

However, this does not mean the human should manually paste a long approval token.

The recommended flow is:

```text
1. The AI presents a human-readable merge-readiness report.
2. The human approves in a normal review surface, such as chat or a PR review.
3. The AI or command wrapper runs a guarded merge command with an explicit approval flag.
4. The command records a structured approval marker on the PR.
5. The command verifies the marker, PR head, evidence, and checks before merging.
```

The human decision stays explicit, but the mechanical record is produced by the workflow.

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

Plain text can still be used as the human-facing decision.

It should not be the only machine-checked merge gate.

## Recommended approval record

For merge approval, record a structured marker like this on the PR:

```text
human-approval-record:v1

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

## Human-friendly wrapper

The AI agent may still present a human-readable summary first:

```text
This PR appears ready to merge.

If you approve, say so in chat or approve the PR review.

After that, the agent can run:

HUMAN_APPROVED_MERGE=yes scripts/agents/agentctl.sh merge-after-human-approval 45 123 abc1234
```

The human is not expected to type the full `APPROVE_MERGE` marker by hand.

The script writes that marker as durable evidence after explicit human approval.

## Approval invalidation

Approval should be treated as invalid when:

- a new commit is pushed to the PR after approval;
- the merge-readiness report is regenerated;
- required checks change from passing to failing;
- the PR scope changes materially;
- a stop condition is detected.

## Do not treat silence as approval

Silence, emoji reactions, or vague positive comments should not be accepted as approval for irreversible operations.

Use them only as conversation signals, not as merge gates.
