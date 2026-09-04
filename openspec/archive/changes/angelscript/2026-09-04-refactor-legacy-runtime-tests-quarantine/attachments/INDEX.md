# INDEX

## Current position

Implementation, focused real-UE verification, durable-spec synchronization, and the Task DAG are complete. Capture the terminal workflow evaluation, pass the terminal evolution gate, and archive with completed closure.

## Hard conclusions

- Legacy AngelScript execution is hard-disabled for the reconstruction baseline; retained source is reference material, not a supported config-restorable path.
- `WITH_ANGELSCRIPT_UNITTESTS` is legacy-only and defaults to `0`; `WITH_ANGELSCRIPT_TESTS` owns replacement tests and defaults to `1`.
- `NewVersion` is a temporary source directory. Public replacement tests use `Angelscript.UnitTest.<Area>.<Scenario>`.
- Existing legacy source is retained under source-free `.ubtignore`-marked `Legacy/` parents; generated JIT artifacts are not mechanically rewritten.
- The default AngelscriptTest module is a shell plus NewVersion; passive TestJIT probe symbols remain only because retained generated objects require them at link time.

## Forbidden

- Do not begin lexer or AST implementation in this Change.
- Do not edit `Documents/`, `Wiki/`, `openspec-old/`, unrelated Skills, or unrelated dirty paths.
- Do not use old aggregate suites to prove a baseline that intentionally compiles the legacy suite out.

## Attachment index

- `data/completed-closure.yaml` — explicit completed disposition consumed by the deterministic OpenSpec archive operation.
- `data/workflow-evaluation.md` — canonical terminal Harness workflow evaluation for completed closure; written last from the exact active-input digest.
- `data/test-startup-timing.md` — measured comparison of the ordinary and Fast Harness `ue.test` profiles in fresh UE processes; produced by Task `3.3`.
- `implementation/issue-20260904-171616-ubt-session-uba-executor.md` — terminal rejected-from-scope dogfooding issue recording the UE 5.8 `-Session`/UBA low-action build failure and verified bounded XGE-threshold workaround.
- `implementation/issue-20260904-174842-ue-dispatch-envelope-masks-native-failure.md` — terminal rejected-from-scope dogfooding issue recording the common Harness envelope/native operation failure-state mismatch and the required evidence-reading workaround.
- `replans/replan-20260904-170132-fast-focused-unit-tests.md` — applied user-directed verification update adding fast-headless exact-prefix timing and adoption.
- `replans/replan-20260904-171148-hard-disable-legacy-execution.md` — applied user-directed removal of the config-restorable legacy path.
- `replans/replan-20260904-172453-isolate-legacy-test-framework.md` — applied user direction plus link evidence defining the thin test-module and passive TestJIT ABI boundary.
- `replans/replan-20260904-174800-use-parent-ubtignore-boundaries.md` — applied UHT/UBT evidence replacing invalid whole-file guards with source-free parent `.ubtignore` boundaries and routing the reusable rule to the test Skill.
- `scripts/Test-LegacyTestQuarantine.ps1` — focused retained-source quarantine audit used by Tasks `3.1` and `5.1`.
