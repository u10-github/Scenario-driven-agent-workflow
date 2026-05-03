# Scenario-driven agent workflow

A **Scenario-driven agent workflow** is a way to build useful AI workflows without asking the AI to freely improvise every step.

The basic idea is simple:

> A scenario defines the goal, safety rules, evidence, human decision points, preferred tools, and fallback options.  
> When the scenario is used in a real project, an AI agent checks the environment and turns the scenario into concrete scripts, commands, and steps.

This repository describes the idea in plain English.

It is not a product, framework, or official standard. It is a pattern that others can copy, change, and develop in their own way.

## Why this exists

Many AI agent workflows fall into two weak patterns:

1. **Too manual**: a human tells the AI every small step.
2. **Too autonomous**: the AI decides and executes too much by itself.

Scenario-driven agent workflow aims for a middle path.

```text
Human
  gives goals, decisions, and approvals

AI agent
  reads context, classifies work, explains choices, reviews results, and adapts the plan

Scripts / commands
  perform repeatable actions, checks, evidence recording, and safety gates
```

The goal is to:

- move repeatable work into scripts;
- keep judgment-heavy work in AI;
- use stronger or weaker models depending on the task;
- reduce the number of human interruptions;
- keep important human decisions explicit;
- improve reproducibility;
- leave evidence that both humans and AI can inspect later.

## Core layers

A practical setup can be seen as three layers.

```text
AGENTS.md
  = constitution
  = top-level project rules and hard safety boundaries

skills
  = usage guide
  = when to use a workflow, how to decide, when to stop

scripts / command suite
  = execution layer
  = reproducible commands, state handling, evidence, and guardrails
```

The AI should not invent the whole process each time. It should use the right scenario and command suite.

## What is a scenario?

A scenario is not a fully fixed procedure.

A scenario is a workflow blueprint that is adapted at deployment time.

At authoring time, a scenario defines:

- the goal;
- non-goals;
- safety boundaries;
- required evidence;
- human decision gates;
- preferred tools;
- model or executor candidates;
- fallback policy.

At deployment time, the AI checks the actual environment:

- Is Git available?
- Is GitHub CLI available?
- Is the user authenticated?
- Is OpenCode available?
- Is Codex CLI available?
- Is this a Node, Python, or other project?
- Which commands already exist?
- Which files must not be overwritten?

Then the AI compiles the scenario into a concrete plan for that environment.

## Example

For coding work, a scenario might look like this:

```text
Issue
  -> intake / classify
  -> ask human only if judgment is needed
  -> implement
  -> self-review
  -> run tests
  -> post evidence
  -> create PR
  -> AI review
  -> fix blocking comments
  -> create a plain-language merge report
  -> stop for human approval
  -> merge only after explicit approval
```

This is only one example. The same pattern can apply to incident response, documentation publishing, community operations, admin work, data analysis, and other repeatable tasks.

## Important principle

Do not rely on prompts alone for safety.

```text
Use AI for judgment and explanation.
Use scripts for repeatable execution.
Use human gates for value judgments, approvals, and external context.
```

## Repository structure

```text
docs/
  concept.md
  authoring-guide.md
  deployment-lifecycle.md
  model-and-cost-policy.md

scenarios/
  _template.yaml
  issue-pr-to-merge-gate.example.yaml
```

## Maintenance model

This repository is intended as an idea seed.

There is no promise that this repository will become a maintained framework. If the idea is useful, please fork it, copy it, rename it, or build your own version.

You do not need to wait for this repository to define the correct way.

## License

This repository is shared under CC0-1.0. See [LICENSE](LICENSE).

The intent is to let people reuse the idea freely.