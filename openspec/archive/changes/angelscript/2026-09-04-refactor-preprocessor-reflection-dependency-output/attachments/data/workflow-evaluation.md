---
record: harness-workflow-evaluation-v1
result: passed
change: angelscript/refactor-preprocessor-reflection-dependency-output
closure_kind: completed
input_sha256: 049774133630a24f61cb2167782204e727f007c6695343e65b742bde7787e46e
captured_at: 2026-09-05T06:23:36.6060142+08:00
---

# Workflow Evaluation

## Lifecycle

- Implemented the terminal Change in the nine-Change reconstructed NativeEngine frontend sequence directly in the selected primary workspace.
- Extracted the existing concrete descriptor family to one Core owner while preserving `AngelscriptEngine.h` as the compatible include entry.
- Added one dormant `asCPreprocessor` semantic facade that retains directive/preprocessing records and a sealed typed-AST session, projects resolved descriptors, and finalizes distinct declaration and body graphs.
- Added typed dependency use-site evidence, deterministic SCC/condensation output, active-configuration filtering, enum/delegate classification, and transactional structured failure diagnostics without connecting the legacy Runtime preprocessor or live Engine publication.
- Created and synchronized the new durable reflection/dependency capability, then promoted the verified semantic-event projection rule into capability knowledge.

## Verification

- Initial contract build `c434f01fd6d1443bbfe1febbac4cca68` exposed one test-only shared-pointer API mismatch; exact Task 1.1 build `20108c9915bc43508165eef08f74b613` passed after correction.
- Expected grouped RED run `245834968ab447459383210cc26cab55` discovered 12 tests: the include-identity proof passed and the 11 not-yet-implemented result/graph behaviors failed without skips or warnings.
- Task 2.1 exact build `41a632612b044d538b245793a3b079d5` passed after two local compile-API corrections.
- Task 2.2 exact build `24ab60e9d14a465d8181c1d3905debaa` passed after correcting a unity-build helper-name collision.
- Expanded RED run `758f475e3d564db4a4678af5f42da0fd` left exactly seven facade/reflection behaviors failing before result assembly was implemented.
- Final exact build `c2d99017077647a581b33517159983fa` succeeded, followed immediately by focused run `3cda9a15092f4f6db860f6e265447540`: 14/14 passed with zero failures, skips, warnings, or errors.
- Shared-front-end adjacent run `8f0007d3679e4357a96db5475add06a5`: 37/37 Lexer, Declarations, and Bodies tests passed with zero failures, skips, warnings, or errors.
- OpenSpec doctor reported zero diagnostics; final strict exact Change validation and strict all-current-spec validation passed; the canonical Task DAG is 6/6 complete.

## Material friction and corrective action

- Moving the descriptor family revealed ordinary include and UE shared-pointer call-site mismatches; each was corrected inside its owning task and recompiled without changing the accepted architecture.
- Unreal unity compilation combined two anonymous namespaces that both used the helper name `HasAttr`. The graph-local helper was renamed to express its scope, and the same exact build then passed. This was a source-level collision, not a Harness defect.
- No Harness execution, reporting, lifecycle, or evidence defect was observed during this Change. Failed runs retained readable UBT or Automation evidence and the successful reports enforced complete counts and process outcomes.

## Spec and knowledge disposition

The complete five-requirement delta was merged exactly into the new `angelscript/language/frontend/reflection-dependencies` current capability. The change-local semantic-event projection candidate was promoted after implementation and adjacent regression evidence, with stale pre-extraction line references removed from the durable copy. No Review was requested and no implementation issue crossed the material-record threshold.

## Scope boundary and provenance

Harness `Quick`, `Performance`, `Integration`, complete UE suites, Standalone, dormant legacy tests, and unrelated plugin tests were intentionally omitted. The implementation is isolated to reconstructed frontend leaves, shared descriptor declarations, and replacement NativeEngine tests; it has no production route, performance contract, cross-product integration boundary, Runtime/UE materialization, bytecode, or VM behavior. The exact editor builds, complete Reflection/ModuleGraph prefix, and adjacent Lexer/Declarations/Bodies prefixes directly prove the affected compilation and semantic surface. Raw request, metadata, log, and Automation artifacts remain under ignored `Saved/Harness/Unreal/Runs/<RunId>/` and are referenced here only by managed run identity.
