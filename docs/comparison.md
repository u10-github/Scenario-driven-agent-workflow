# Comparison with adjacent approaches

Scenario-driven agent workflow is not intended to replace existing agent instruction files, hooks, coding agents, or CI systems.

It is a thin pattern for connecting them.

## Summary

```text
AGENTS.md
  Project constitution and standing instructions.

Skills / rules / custom instructions
  Usage guidance for the AI agent.

Hooks / permissions
  Tool-call level guardrails.

CI / scripts
  Deterministic checks and repeatable execution.

GitHub Issues / PRs
  Shared work surface and durable evidence.

Scenario-driven agent workflow
  Portable workflow blueprint that tells an AI how to assemble the above for one repeatable scenario.
```

## AGENTS.md

AGENTS.md is useful for stable project rules:

- coding style;
- test commands;
- forbidden changes;
- repository-specific conventions;
- review expectations.

Scenario-driven agent workflow sits one layer above that.

A scenario can tell an AI agent which AGENTS.md fragment should exist or which existing rules must be respected, but it should not replace project-specific instructions.

## Skills, rules, and custom instructions

Skills and rules are useful for deciding when and how to use a workflow.

They are weaker than scripts for safety-critical behavior because they depend on the model following instructions correctly.

Scenario-driven agent workflow uses skills or rules as guidance, but moves repeatable enforcement into scripts where possible.

## Hooks and permission systems

Hook systems can block or ask before specific tool calls.

They are good for local enforcement such as:

- blocking dangerous shell commands;
- asking before network access;
- preventing edits to protected files;
- logging tool use.

Scenario-driven agent workflow is broader. It describes the whole scenario: actors, evidence, fallback modes, human gates, and verification.

A scenario may compile into hook rules when the target tool supports them.

## GitHub Copilot coding agent and similar hosted agents

Hosted coding agents can already turn Issues into branches, commits, and pull requests.

Scenario-driven agent workflow is different in scope:

- it is tool-agnostic;
- it can combine multiple agents and local scripts;
- it can define project-specific evidence formats;
- it can require explicit human approval protocols;
- it can fall back to report-only or guided-manual modes.

It may use hosted coding agents as one executor, but it does not depend on them.

## CI systems

CI is the right place for deterministic verification:

- tests;
- lint;
- type checks;
- build checks;
- security scans;
- policy checks.

Scenario-driven agent workflow should not duplicate CI. It should call CI or local equivalents and record the evidence.

## What this pattern adds

The main addition is not a new runtime.

The main addition is a portable middle layer:

```text
scenario YAML
  -> AI adapts to the actual project and toolchain
  -> standing instructions, skills, scripts, evidence, and gates are created or selected
  -> scripts enforce the repeatable safety checks
  -> humans approve only the judgment-heavy or irreversible steps
```

That makes the workflow easier to copy across tools without assuming one fixed agent platform.
