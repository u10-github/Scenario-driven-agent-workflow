# Concept

Scenario-driven agent workflow is a pattern for combining AI agents, scripts, evidence, and human decision gates.

It is useful when a task is too complex for a single prompt, but too risky to let an AI agent execute freely.

## Short definition

A Scenario-driven agent workflow is a human-gated automation pattern where:

- a scenario defines the expected flow;
- agents handle planning, classification, implementation, review, and reporting;
- scripts perform reproducible actions and safety checks;
- evidence is recorded in a durable place;
- humans make only the decisions that require judgment, approval, or external context.

## The main idea

Do not ask the AI to invent the whole workflow every time.

Instead:

1. Define a scenario.
2. Let the AI inspect the current environment.
3. Let the AI adapt the scenario to that environment.
4. Move repeatable operations into scripts.
5. Keep human gates for important decisions.
6. Record evidence so humans and AI can review what happened.

## Why scripts matter

AI is good at reading context, explaining tradeoffs, classifying risk, and writing drafts.

Scripts are better for:

- repeatable commands;
- state checks;
- dependency checks;
- test execution;
- evidence recording;
- merge, deploy, delete, or other guarded operations.

If a step can be made deterministic, it should usually move into the script layer.

## Why human gates matter

Some decisions should not be delegated to an AI model alone.

Examples:

- approving a merge;
- changing secrets or environment variables;
- changing billing or deployment settings;
- publishing public content;
- deleting data;
- deciding product direction;
- accepting legal, privacy, or security risk.

For these cases, the AI should prepare a plain-language decision brief, then stop.

## Delayed binding

A scenario should not decide every detail at authoring time.

A scenario should define the stable parts:

- purpose;
- invariants;
- safety boundaries;
- evidence requirements;
- human gates;
- preferred tools;
- fallback policy.

At deployment time, the AI checks the real environment and chooses concrete commands, tools, and runtime mode.

This makes the scenario reusable across different projects.

## Common runtime modes

A scenario may support several runtime modes.

```text
full-auto
  preferred tools are available
  scripts can perform most steps

codex-only
  OpenCode or another executor is missing
  Codex performs more of the work

assisted-auto
  some steps are automated, but some require human confirmation

guided-manual
  AI writes instructions and scripts, but the human or another tool executes them

report-only
  the environment is read-only or write permissions are missing
  AI produces analysis and reports only
```

## Key design rule

A scenario should be able to explain whether it can run in the current environment before it tries to run.

If it cannot run as designed, it should offer fallback options.