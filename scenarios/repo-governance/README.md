# Dependency and security governance scenario

This scenario helps an AI agent create a maintainable guardrail workflow for a repository before agentic coding causes long-term drift.

It is intended for both:

- existing repositories that already have code and technical debt;
- new repositories where dependency and security boundaries should be established early.

The scenario file is:

```text
scenarios/repo-governance/dependency-security-governance.yaml
```

## What this scenario does

The scenario asks the AI agent to:

1. inspect the repository and record a baseline;
2. analyze dependency structure and architecture drift risks;
3. analyze security posture with available static analysis, secret scanning, and dependency vulnerability tools;
4. present multiple remediation and maintenance policy options;
5. wait for human agreement on the policy;
6. implement small, reversible guardrails and approved fixes;
7. record evidence and a maintenance plan for future agents.

The important point is that the AI should not jump directly from findings to implementation.

The required flow is:

```text
baseline
  -> dependency/security audit
  -> multiple policy options
  -> human policy agreement
  -> implementation
  -> verification
  -> maintenance handoff
```

## Typical policy options the AI should compare

The exact options depend on the repository, but the decision brief should usually compare choices like these.

### Dependency governance

```text
Option A: Minimal guardrails
  Add dependency cycle checks, import linting, and a short architecture note.
  Low cost, low disruption, weaker long-term control.

Option B: Core and extension boundary
  Define stable core modules and extension/adaptor modules.
  Good for agentic coding because agents get clear dependency direction.
  Requires some naming and folder discipline.

Option C: Clean architecture or layered architecture
  Define domain, application, infrastructure, and UI boundaries.
  Strong separation, useful for long-lived systems.
  Higher migration cost and more false-positive boundary debates.

Option D: Feature-sliced governance
  Organize by feature with explicit allowed shared layers.
  Useful for UI-heavy or product-oriented repositories.
  Can degrade if shared code becomes a dumping ground.
```

### Security governance

```text
Option A: Local lightweight baseline
  Use package-manager audit, secret scanning, and existing linters.
  Low setup cost, but coverage varies.

Option B: Semgrep + dependency vulnerability scan + secret scan
  Good general baseline for many repositories.
  May require triage and suppression policy.

Option C: CI-required security gates
  Stronger maintenance, but false positives can block work.
  Better after the baseline false-positive rate is understood.

Option D: Report-only security posture
  Use when tools or permissions are unavailable.
  Produces a setup plan but does not enforce checks yet.
```

The AI should recommend one option or a hybrid, with pros, cons, implementation cost, false-positive risk, and rollback notes.

## How to use

Ask a strong reasoning model to adapt the scenario to your repository.

Example prompt:

```text
Read scenarios/repo-governance/dependency-security-governance.yaml.

Apply it to this repository.

First, inspect the current dependency structure and security tooling.
Do not implement changes yet.

Produce:
- baseline inventory,
- dependency structure audit,
- security baseline audit,
- at least three policy options with pros and cons,
- your recommended policy,
- and the exact human decision needed before implementation.

Do not change secrets, CI permissions, billing, or production settings.
```

After the human approves a policy, the agent may implement the approved guardrails and low-risk fixes only within the agreed scope.

## Evidence markers

The scenario defines evidence markers such as:

```text
repo-baseline-inventory:v1
dependency-structure-audit:v1
security-baseline-audit:v1
repo-governance-options:v1
human-policy-agreement:v1
repo-governance-verification:v1
repo-governance-maintenance-plan:v1
```

Use these markers in PR comments, issue comments, committed docs, or local `.agent/evidence` files so future agents can inspect what was decided and why.

## Validation

Validate the scenario against the repository schema:

```bash
python - <<'PY'
import json
import pathlib
import yaml
from jsonschema import Draft202012Validator

schema = json.loads(pathlib.Path('schema/scenario.schema.json').read_text())
data = yaml.safe_load(pathlib.Path('scenarios/repo-governance/dependency-security-governance.yaml').read_text())
Draft202012Validator(schema).validate(data)
print('scenario schema validation: ok')
PY
```

This uses `schema/scenario.schema.json`.

If `yaml` or `jsonschema` is not installed, install them in a local or temporary development environment rather than adding a global dependency without approval.

## Safety notes

This scenario is intentionally conservative.

It requires human agreement before architecture policy changes or security-maintenance policy changes. It also stops before secrets, auth, billing, production deploys, destructive data changes, or CI permission changes unless there is explicit human approval.

The default implementation posture is:

```text
record first
propose options
agree policy
make small reversible changes
verify
leave evidence for future agents
```
