# Scenario-driven agent workflow

A **Scenario-driven agent workflow** is a way to build useful AI workflows without asking the AI to freely improvise every step.

The basic idea is simple:

> A scenario defines the goal, safety rules, evidence, human decision points, preferred tools, and fallback options.  
> When the scenario is used in a real project, an AI agent checks the environment and turns the scenario into concrete scripts, commands, and steps.

This repository describes the idea in plain English.

It is not a product, framework, or official standard. It is a pattern that others can copy, change, and develop in their own way.

## What should I do next?

If you want to try this idea, do not start by building a full framework.

Start by asking a strong reasoning AI to adapt the scenario to your own environment.

For example:

```text
Read the Scenario-driven agent workflow idea.

Using the scenario YAML as a blueprint, design a workflow for my project.

Do not assume my environment is the same as the author's.

First, check what tools are available.
Then decide which parts should be scripts, which parts should be handled by AI, and where human approval is required.

Create:
- an AGENTS.md fragment,
- skill or instruction files if useful,
- a command script layer,
- evidence formats,
- human approval gates,
- and a short setup plan.

Do not perform irreversible actions without explicit approval.
```

The scenario file is not meant to be executed blindly.

It is meant to help an AI agent create a workflow that fits your tools, your project, and your risk tolerance.

## Core idea

This repository is not mainly about YAML.

It is also not mainly about GitHub, Codex, OpenCode, or any specific model.

The core idea is this:

> Use AI to design and adapt the workflow, but move repeatable and safety-critical operations into scripts.

Skills and prompts can guide an AI agent, but they are weak guardrails.

Scripts can provide stronger guardrails.

A Scenario-driven agent workflow is a way to let people create those script-based guardrails more reproducibly.

This separation also helps you choose the right actor for each part of the work:

```text
Scripts
  for deterministic checks and execution

AI agents
  for classification, adaptation, drafting, implementation, review, and reporting

Stronger reasoning models
  for ambiguity, risk review, workflow design, and final reports

Smaller or cheaper models
  for simpler summaries, formatting, and routine tasks

Humans
  for approval, responsibility, and external context
```

Cost control is not the main purpose.

It is one possible result of separating the workflow clearly.

Instead of telling an AI:

```text
Please be careful.
```

we ask the AI to help create:

```text
scripts that make being careful reproducible.
```

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

## Why scenarios are written as YAML

People use different tools.

One person may use Codex and OpenCode.

Another may use Claude Code, GitHub Copilot, Cursor, a local LLM, shell scripts, or a custom agent runner.

Because of that, this repository does not assume one fixed runtime.

Instead, the idea is distributed as a scenario.

A scenario describes:

- the goal;
- the safety rules;
- the preferred tools;
- executor or model candidates;
- fallback options;
- the evidence that should be produced;
- the human decision points.

At deployment time, an AI agent should inspect the actual environment and turn the scenario into concrete files and commands.

```text
scenario YAML
  -> AI reads the local environment
  -> AI creates or adapts AGENTS.md
  -> AI creates skill/instruction files if useful
  -> AI creates scripts and command entrypoints
  -> AI defines evidence and human gates
  -> human reviews the plan
  -> scripts enforce the important guardrails
```

The scenario can also help the AI choose a practical runtime mode:

```text
full-auto
  preferred tools are available

codex-only
  OpenCode or another executor is missing

report-only
  write permission is missing

guided-manual
  scripts cannot safely run, so the AI prepares steps for a human or another tool
```

The scenario does not force one model or one tool.

It gives the AI enough structure to choose a reasonable path for the current environment.

The YAML is not the product.

The YAML is a portable blueprint.

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

## Practical guardrails added in this repository

This repository includes a few small reference pieces to make the pattern more concrete:

```text
schema/scenario.schema.json
  A JSON Schema for scenario YAML shape and required sections.

docs/approval-protocol.md
  A low-friction, machine-checkable approval record for irreversible actions.

docs/comparison.md
  A comparison with AGENTS.md, skills, hooks, hosted coding agents, and CI.

scripts/agents/agentctl.sh
  A conservative reference script that demonstrates doctor, status, merge-report,
  and guarded merge-after-human-approval commands.
```

These files are intentionally small.

They are not a complete framework. They are examples of how the pattern can move from instruction text toward reproducible checks.

## Example: the author's coding workflow

The author's first concrete use case is a GitHub-based coding workflow.

In that environment, the layers look like this:

```text
Human
  -> asks Codex to proceed with a GitHub Issue
  -> answers only when a decision is needed
  -> approves merge after reading a plain-language report

AGENTS.md
  -> project constitution
  -> defines hard rules and safety boundaries

skills
  -> tell the AI when to use the workflow
  -> explain how to classify work and when to stop

scripts / agentctl
  -> perform repeatable operations
  -> check dependencies
  -> run tests
  -> post evidence
  -> enforce merge guards

GitHub Issues / PRs / comments
  -> shared memory
  -> durable evidence
  -> human review surface

Codex
  -> planning, intake, review, merge-readiness reports

OpenCode + DeepSeek
  -> implementation executor by default

Other models
  -> Kimi or smaller GPT models can be used depending on cost and task difficulty
```

A possible user experience is:

```text
Human:
Please take Issue #123 up to the merge gate. Do not merge yet.

AI:
Checks the environment.
Classifies the Issue.
Asks for human judgment only if needed.
Runs the scripted workflow.
Creates a PR.
Posts test evidence.
Reviews the PR.
Creates a merge-readiness report.
Stops for human approval.

Human:
Looks good. Merge it.

AI:
Runs the guarded merge script with HUMAN_APPROVED_MERGE=yes.
The script records a structured approval marker on the PR.
The script verifies the PR head, evidence, and checks.
If the guard passes, the script merges the PR and closes the linked Issue.
```

This is only one example.

Your environment may be different, so your concrete scripts and tools may be different too.

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
  approval-protocol.md
  comparison.md

schema/
  scenario.schema.json

scenarios/
  _template.yaml
  issue-pr-to-merge-gate.example.yaml

scripts/
  agents/
    agentctl.sh
```

## This is an idea seed

This repository is not intended to become the one official implementation.

It is an idea seed.

Please fork it, copy the structure, rename the pattern, rewrite the scenarios, or build your own command suite.

The important part is not this repository.

The important part is the pattern:

- describe the scenario;
- let AI adapt it to the environment;
- move repeatable work into scripts;
- keep human gates for judgment;
- record evidence;
- choose models based on task difficulty and cost when useful.

## Maintenance model

This repository is intended as an idea seed.

There is no promise that this repository will become a maintained framework. If the idea is useful, please fork it, copy it, rename it, or build your own version.

You do not need to wait for this repository to define the correct way.

## License

This repository is shared under CC0-1.0. See [LICENSE](LICENSE).

The intent is to let people reuse the idea freely.
