# Fix Evolution Closure Validation

## Why

`harness.evolution.status -RequireTerminal` currently checks only a shallow subset of closure evidence. An active Change can be reported closure-ready with no completed Task DAG, a schema-less or nested material issue, an unfinished Review, or an evaluation captured before later evidence changes. The same terminal path also accepts archived records, mixing current fail-closed policy with immutable-history compatibility.

## What Changes

- Make terminal evaluation an active-Change-only operation with an explicit `completed | abandoned | superseded` closure kind.
- Consume the portable OpenSpec TaskPlan instead of parsing Task DAG YAML, and require a non-empty all-complete plan for completed closure.
- Validate active material issues recursively, bind their task references and timestamps, and make successor ownership exact.
- Validate any active `review-v2` record and reject unfinished lifecycle or unresolved Critical/Required findings.
- Bind the canonical workflow evaluation to the requested closure kind and a deterministic SHA-256 of the active Change inputs.
- Keep ordinary archived status readable while leaving historical closure validation to `openspec validate --archived --strict --json`.

## Verification Boundary

This Change adds and runs one lightweight real-module fixture dedicated to `harness.evolution.status`, plus the directly affected Protocol test and exact OpenSpec strict validations. It does not run Harness Quick, Git, Workspace, Unreal, performance, build, Editor, Automation, or other unrelated suites.

## Success

Every demonstrated active closure bypass fails with a bounded diagnostic, one fully valid completed fixture passes, archived terminal requests fail without rewriting history, current specs and guidance agree, and the focused test remains fast enough to run on every future evolution-gate edit.
