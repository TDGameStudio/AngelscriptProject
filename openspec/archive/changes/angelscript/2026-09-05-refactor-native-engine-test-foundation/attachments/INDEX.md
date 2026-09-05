# INDEX

## Current position

All four tasks are complete. The replacement-only CQTest foundation, exact public identity, focused verification evidence, testing guidance, and durable testing baseline are ready for completed closure.

## Hard conclusions

- CQTest is allowed for replacement tests only as an explicitly included UE test library.
- `WITH_ANGELSCRIPT_TESTS` owns the new foundation; `WITH_ANGELSCRIPT_UNITTESTS` and all legacy helpers remain dormant.
- Public tests use `Angelscript.UnitTest.NativeEngine.<Area>.<Scenario>` and group one area into one Fast process.
- CQTest composes directory, class, and method; the directory supplies `Angelscript.UnitTest.NativeEngine`, the unprefixed class identifier supplies `<Area>`, and the method supplies `<Scenario>`.

## Forbidden

- Do not restore the legacy force include, engine pool, `ASTEST_*` surface, old prefixes, or ignored sources.
- Do not create a persistent editor, custom commandlet, or alternate Harness test route.

## Attachment index

- `data/completed-closure.yaml` — explicit completed disposition consumed by the deterministic OpenSpec archive operation.
- `talks/talk-20260905-010000-cqtest-without-legacy-reactivation.md` — settled boundary between the reusable CQTest library and the quarantined AngelScript test framework — read before changing test dependencies or fixtures.
- `knowledges/native-engine-test-isolation.md` — promoted into `.agents/skills/angelscript-test-guide/SKILL.md` and `openspec/specs/angelscript/testing/baseline/spec.md`; the attachment remains the change-local provenance.
- `implementation/issue-20260905-020702-ubt-rules-assembly-lock.md` — rejected dogfooding issue preserving a transient project-rules assembly lock without attributing an unproved Harness defect — reopen only with a captured holder or reproducible cause.
- `implementation/issue-20260905-021118-cqtest-name-composition.md` — resolved verification issue proving and correcting CQTest's class-name path component — read when adding a new NativeEngine area.
- `replans/replan-20260905-021228-cqtest-public-name-composition.md` — applied replan that maps CQTest directory, class, and method to the stable public identity — resume Task `1.2`.
- `data/native-engine-foundation-verification.md` — final source hashes, RED/GREEN build runs, exact four-test report, and impact boundary — use for Task `2.1` synchronization and closure.
- `data/workflow-evaluation.md` — canonical completed-closure evaluation written last against the final active Change digest.
