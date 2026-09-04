---
record: harness-workflow-evaluation-v1
result: passed
change: harness/fix-unreal-execution-reliability
closure_kind: completed
input_sha256: b10cd86277512e3315ac464a05e1626229913182b84be9fce52273bef6b96c1b
captured_at: 2026-09-04T18:47:53.3216461+08:00
---

# Workflow Evaluation

## Lifecycle

- Created one focused Harness Change from two terminal dogfooding findings retained by the immediately preceding product-isolation archive.
- Used independent RED/GREEN tasks for UBT planning and common-envelope failure propagation.
- Applied one evidence-gated Replan after UE 5.8 source disproved the initial `NoUBA` assumption; preserved the rejected path and added a permanent corrective task instead of rewriting completed Task history.
- Replaced top-level recursive Session correlation with contained log identity plus exact native PID, project, mapping, Request, metadata, and path checks.
- Synchronized the durable behavior into current `harness/unreal`, completed all six Task nodes, and retained no open issue or Review.

## Verification

- `Harness.Tests.ps1`: PASS, including five synchronous Unreal execution routes, all terminal failure states, native exit/data/artifact preservation, non-terminal dispatch, observation, cancellation, and success boundaries.
- `UnrealEngineDevelop.Tests.ps1 -Tag Build`: PASS; typed build, generic build, and QueryTargets plans contain no top-level Session and preserve configured executor policy.
- `UnrealEngineDevelop.Tests.ps1 -Tag ConcurrencyProgress`: PASS; contained-log recognition succeeds while wrong PID and external log cases fail closed.
- `UnrealEngineDevelop.Tests.ps1 -Tag Integration`: PASS through the common Harness/Unreal boundary.
- `Protocol.Tests.ps1`: PASS after repairing the immediately preceding archive's one missing script INDEX entry without weakening validation.
- `HarnessEvolution.Tests.ps1`: PASS.
- Real build `aa0b22a50b554a76acfb289b1079cf71`: XGE, 32/32 actions, succeeded in 105.64 seconds; live process/progress recognition worked without Session.
- Real low-action build `d9c2e144acc849d4aa327fcc41ba7d1a`: Unreal Build Accelerator local executor, 6/6 `[NoUba]` actions, succeeded in 6.16 seconds without Session or executor/threshold overrides.
- Workflow validation `0f3ad6bb768042b49cbdb121cb3536fa`, doctor `62c8abe300f64f4bbb85b895cb15fa62`, final strict active-Change validation `14ebbf30aafa4094b674d26a6a549a43`, focused current-spec validation `0df260d5c73f4b678b76d0d7b2735bdd`, and all-spec validation `26ff6b861cbf4aaea56ad5e1a3350d81`: PASS.

## Executor environment finding

The selected UE 5.8 installation contains bundled UBA binaries. The project-local UBT XML already sets `bAllowUBAExecutor=false`, but UE 5.8 still constructs the local UBA executor with detouring disabled when remote executors are not selected; the real 6-action run confirms this `[NoUba]` behavior. Incredibuild/XGE 10.32.2 is installed with its Agent running, active Fixed Initiator licensing, 24 floating helper cores, and the Multiple Builds feature. Current `/LIST` was empty during inspection. These are availability signals, not a durable promise of concurrent capacity.

## Material friction and corrective action

- The initial `-NoUBA` design passed its plan fixture but source inspection proved it could not prevent the trace-dependent fallback executor. Replan `replan-20260904-183422-use-contained-run-correlation` superseded the implementation before real acceptance and added Task `1.2`.
- Protocol verification found that the immediately preceding archive omitted its retained quarantine script from `attachments/INDEX.md`. The exact index entry was added; no historical requirement, evidence body, or closure disposition was rewritten.
- One invalid exploratory `openspec validate --workflows` invocation returned CLI syntax error 2; the documented `openspec workflow validate angelscript --json` route was then used and passed. No CLI or workflow defect was inferred.

## Scope boundary

Harness aggregate `Quick`, `Performance`, and `Integration` profiles, full UE Automation and suites, packaging, Standalone, plugin-wide C++, and product tests were intentionally omitted. The public envelope and UE leaf are covered by their direct fixtures plus the direct Integration tag; two real editor builds cover XGE and low-action local fallback; no performance, release, Automation, or product-code behavior changed.

## Spec synchronization and provenance

The `harness/unreal` delta was semantically merged into `openspec/specs/harness/unreal/spec.md`. Raw requests, metadata, command logs, UBT logs, process progress, and executor output remain under ignored `Saved/Harness/Unreal/Runs/<RunId>/`; this evaluation and Task evidence retain the compact run identities and outcomes. No Review was requested, no material implementation issue remains active, and the one applied Replan is indexed.
