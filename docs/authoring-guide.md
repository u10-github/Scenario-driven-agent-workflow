# Authoring guide

This guide explains how to write a Scenario-driven agent workflow.

The goal is not to create a perfect procedure in advance. The goal is to create a reusable workflow blueprint that an AI agent can adapt to a real environment.

## 1. Start with the purpose

Write one clear sentence.

Example:

```text
Use a GitHub Issue to drive implementation, review, test evidence, and a merge-readiness report.
```

## 2. Define non-goals

Non-goals are important. They stop the scenario from expanding too far.

Example:

```text
- Do not deploy to production.
- Do not change secrets.
- Do not merge without human approval.
```

## 3. Define invariants

Invariants are rules that must always hold.

Example:

```text
- Human approval is required before merge.
- Evidence must be posted before final approval.
- If secrets or billing are involved, stop.
```

## 4. Define actors

Common actors:

```text
human
  gives goals, decisions, and approval

planner_agent
  classifies work and prepares decision briefs

executor_agent
  performs implementation or task execution

reviewer_agent
  checks results and writes reports

command_suite
  runs scripts, tests, and guarded operations
```

## 5. Define evidence

Evidence should be durable and visible to both AI and humans.

Examples:

- GitHub PR comments;
- issue comments;
- log artifacts;
- generated reports;
- files committed to the repository;
- database records;
- exported documents.

Avoid posting secrets, tokens, private media, or verbose environment dumps.

## 6. Define human gates

Human gates should be explicit.

Good examples:

```text
- Ask the human to choose A/B/C when the specification is ambiguous.
- Ask for explicit merge approval before merge.
- Ask for approval before changing production settings.
```

Bad examples:

```text
- Let the AI decide whether its own report is enough to merge.
- Treat silence as approval.
- Hide risk behind a long technical log.
```

## 7. Define dependencies and fallback

A scenario should check whether the environment is ready.

Separate dependencies into:

```text
required
  the scenario cannot work without this

recommended
  ideal path uses this, but fallback exists

optional
  useful but not required
```

If a recommended dependency is missing, the agent should offer fallback options.

## 8. Define runtime modes

Runtime modes make the scenario usable in imperfect environments.

Example:

```text
full-auto
  GitHub CLI, auth, Codex, and OpenCode are available

codex-only
  OpenCode is not available, but Codex can run the work

report-only
  write permission is missing, so the AI only reports findings
```

## 9. Define model policy

Use strong models where judgment matters. Use cheaper or faster models where the task is simple.

Example:

```text
strong model
  intake classification, risk review, merge-readiness report

medium model
  implementation and self-review

cheap model or script
  formatting, status summaries, simple checks

human
  final approval and external-context decisions
```

## 10. Define command entrypoints

The human should not need to run every low-level command.

Expose a few high-level commands.

Example:

```bash
agentctl start <issue-number>
agentctl resume-current
agentctl merge-current-approved
agentctl status
agentctl doctor
```

## 11. Keep safety in scripts where possible

Prompts are not enough for safety.

If a rule must always be enforced, put it in a script or guard.

Examples:

- merge requires explicit approval;
- risk:high blocks auto-merge;
- test evidence must exist before merge;
- secret changes stop the scenario.

## 12. Keep the first version small

A good first scenario should be narrow.

Do not try to automate everything. Start with one repeatable flow, then improve it.