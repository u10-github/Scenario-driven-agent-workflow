# Deployment lifecycle

A scenario is not meant to be executed blindly.

A good Scenario-driven agent workflow has a deployment lifecycle.

## 1. Authoring

At authoring time, define the stable parts:

- purpose;
- non-goals;
- invariants;
- actors;
- evidence requirements;
- human gates;
- safety policy;
- preferred tools;
- fallback policy;
- runtime modes.

Do not decide every environment-specific command in advance.

## 2. Preflight

Before running, the AI or command suite should check the environment.

Examples:

```text
- Is this a git repository?
- Is the required CLI installed?
- Is the user authenticated?
- Is the working tree clean?
- Are required files present?
- Are write permissions available?
- Are project-specific scripts available?
```

Preflight should be non-destructive.

## 3. Dependency handling

The scenario may recommend dependencies.

If something is missing, the agent should not immediately fail. It should classify the missing dependency.

```text
required
  stop if missing

recommended
  ask whether to install or use fallback

optional
  continue without it
```

Global installs, authentication setup, secret changes, billing changes, and deploy settings should require human approval.

## 4. Fallback negotiation

If the preferred path is not available, the AI should offer simple choices.

Example:

```text
OpenCode is not available.

A. Install OpenCode and use the preferred executor.
B. Use Codex as the executor for this project.
C. Use report-only mode.

Recommended: B, because it avoids changing the environment first.
```

The human answers with a small decision, such as:

```text
Bで進めて
```

The decision should be recorded as evidence or state.

## 5. Deployment plan

After preflight and fallback negotiation, the AI creates a deployment plan.

The plan should describe:

- selected runtime mode;
- selected executor;
- generated or installed scripts;
- evidence location;
- human gates;
- verification commands;
- remaining risks.

## 6. Runtime

The scenario runs through its steps.

During runtime, scripts should handle repeatable work. AI should handle classification, explanation, review, and adaptation.

If the scenario reaches a human gate, it must stop.

## 7. Evidence and reporting

The scenario should leave evidence.

Evidence should answer:

- What was attempted?
- What commands ran?
- What passed or failed?
- What did the AI review?
- What did the human approve?
- What remains uncertain?

## 8. Finalization

Finalization steps are often risky.

Examples:

- merge;
- deploy;
- publish;
- delete;
- send;
- close an issue;
- modify production state.

These should be guarded by explicit human approval and script-level checks.