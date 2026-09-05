---
record: harness-workflow-evaluation-v1
result: passed
change: angelscript/refactor-native-engine-test-foundation
closure_kind: completed
input_sha256: c5c88e5b45bc750a5bd1861a213785d3eee1f8cffc6d27171b08f1c6febbb33f
captured_at: 2026-09-05T02:28:13.4302060+08:00
---

# Workflow Evaluation

## Lifecycle

- Implemented the first dependency in the nine-Change NativeEngine sequence directly in the selected primary workspace.
- Added CQTest only to the replacement `WITH_ANGELSCRIPT_TESTS` editor boundary while preserving the disabled `WITH_ANGELSCRIPT_UNITTESTS` legacy branch.
- Established a replacement-owned source-input and diagnostic-capture fixture under `NewVersion/NativeEngine` and four exact Foundation scenarios.
- Applied one evidence-gated Replan after the first real Automation report proved that CQTest composes its public name from directory, class, and method components.
- Synchronized the verified replacement-test contract into the testing Skill and current `angelscript/testing/baseline` specification.

## Verification

- Expected RED build `99c5bff430e146f78ace045bfe653697`: failed because replacement tests could not include `CQTest.h` before the build-rule change.
- Expected fixture RED build `7741ac5d1eaf4c53bf5a9321b862fd0b`: failed because the replacement support header did not yet exist.
- Final editor build `96b26c7ff9944f7bb37faf222ddc3ee2`: succeeded with the final compiled source identities recorded in `data/native-engine-foundation-verification.md`.
- Final exact Fast test run `6963d59f5b874c3396cc7fc0b9be079f`: 4/4 passed, 0 failed, 0 skipped, 0 warnings, and 0 errors under `Angelscript.UnitTest.NativeEngine.Foundation`.
- `angelscript-test-guide` system Skill validation: passed.
- `OpenSpecSkill.Tests.ps1`: package safety and Skill package tests passed.
- OpenSpec doctor: succeeded.
- Strict exact active-Change validation: succeeded.
- Strict all-current-spec validation: succeeded.
- Canonical Task DAG: 4/4 complete.

## Material friction and corrective action

- A transient UBT project-rules assembly lock was preserved as an indexed, evidence-backed rejected issue. Seven later builds passed the same rules stage, so no unproved Harness or UBT fix was introduced; recurrence requires capturing the actual holder.
- The initial CQTest class identifier duplicated an internal class component in public Automation names. The real report invalidated the accepted naming design, so the replan changed the CQTest class to the unprefixed area name and the final report proved all four exact paths.
- A registry-enumeration assertion produced unrelated MetaSound tag warnings. It was removed because the Harness Automation report is the stable external oracle for public discovery, leaving the final focused run warning-free.

## Spec and knowledge disposition

The complete NativeEngine foundation delta was merged into `openspec/specs/angelscript/testing/baseline/spec.md`. The reusable isolation guidance was promoted into that durable capability contract and `.agents/skills/angelscript-test-guide/SKILL.md`; its change-local knowledge attachment remains provenance. No Review was requested.

## Scope boundary and provenance

Harness `Quick`, `Performance`, and `Integration`, full UE suites, Standalone, legacy tests, and unrelated plugin tests were intentionally omitted. The affected boundary is one test-module dependency, two replacement test files, one testing Skill, and one testing spec; the exact editor build and one complete Foundation-prefix process directly prove its compilation, registration, public naming, ownership, and cleanup behavior. Raw UE request, log, metadata, and Automation artifacts remain under ignored `Saved/Harness/Unreal/Runs/<RunId>/`; the indexed compact verification attachment retains their run identities, source hashes, counts, and report paths.
