# Model and cost policy

A Scenario-driven agent workflow should not use the strongest model for every step.

The goal is to use the right level of intelligence for the right part of the workflow.

## Basic idea

```text
Scripts
  for deterministic work

Cheap or fast models
  for simple summaries and formatting

Medium models
  for implementation and routine fixes

Strong models
  for ambiguous judgment, safety review, and final reports

Humans
  for approval, responsibility, and external context
```

## Example task split

| Task | Suggested actor |
|---|---|
| Environment check | script |
| Dependency check | script |
| Simple status summary | cheap / fast model |
| Issue intake classification | strong model |
| Implementation | medium or strong executor |
| Self-review | executor or separate medium model |
| Security-sensitive review | strong model |
| Evidence posting | script |
| Merge-readiness report | strong model |
| Merge approval | human |
| Merge execution | guarded script |

## Why this matters

Using strong AI everywhere can be expensive and slow.

Using weak AI everywhere can be risky.

Using scripts for everything is not flexible enough.

The useful pattern is to separate work by type.

## Model policy in a scenario

A scenario can define a model policy.

Example:

```yaml
model_policy:
  cheap_or_fast:
    use_for:
      - status_summary
      - formatting
      - dependency_check_summary

  medium:
    use_for:
      - implementation
      - self_review
      - fixing_blocking_comments

  strong:
    use_for:
      - intake_classification
      - ambiguous_spec_decision
      - security_sensitive_review
      - merge_readiness_report

  human:
    required_for:
      - merge_approval
      - external_account_setup
      - secrets
      - billing
      - production_release
```

## Executor profiles

A scenario may allow rough executor names.

Example:

```text
deepseek
kimi
codex-mini-high
manual
report-only
```

The scenario deployment step resolves those names into real tools and model IDs for the current environment.

This lets the user say something simple, such as:

```text
Run this with Kimi.
```

or:

```text
Use Codex only for this project.
```

## Human approval is not a model choice

A stronger model does not remove the need for human approval.

For risky steps, the model should prepare the decision brief and then stop.

The human makes the approval decision.