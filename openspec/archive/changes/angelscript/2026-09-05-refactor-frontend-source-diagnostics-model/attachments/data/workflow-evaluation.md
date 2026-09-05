---
record: harness-workflow-evaluation-v1
result: passed
change: angelscript/refactor-frontend-source-diagnostics-model
closure_kind: completed
input_sha256: f25282196cef5c6a8d8dc59df7509598ccb6f4f7b1b597f2f744cd58719d1b0d
captured_at: 2026-09-05T02:52:17.7330471+08:00
---

# Workflow Evaluation

## Lifecycle

- Consumed the archived NativeEngine CQTest foundation and implemented the second dependency in the nine-Change frontend sequence.
- Used three focused RED/GREEN cycles for snapshot-bound ranges, lazy source provenance, and structured diagnostics.
- Kept every new type in the fork-internal lowercase `frontend` namespace and left current Parser, Builder, Engine, VM, Standalone, and reflection routes unchanged.
- Created the shared `angelscript/language/frontend` domain and first `source-diagnostics` capability through the portable CLI, synchronized the full delta, and promoted reusable Clang provenance guidance into capability knowledge.
- Completed all four tasks with two resolved material issues, three applied Replans, and no requested Review.

## Verification

- Task `1.1` expected RED `d0c43c28bcf94934980039daa4cb6ec3`: missing source-location header.
- UBT planning RED `8d50869f797a421ebf421d793298f080`: duplicate manager implementation basename, resolved through a unique implementation-unit name.
- Task `1.1` GREEN build/test: `8d3971ef5122438d8409aca77938eda1`, then `079f0c1fe393414e83067c9bf8b8e1d5` with 4/4 passed.
- Task `1.2` expected RED `da205e15ecdf48cabbc10dd23d7ff3cc`: missing provenance header.
- Task `1.2` GREEN build/test: `3e05841f43664a28858d3794cab893e1`, then `7f5b72c4340c4b32af4871f087e78085` with 8/8 passed.
- Task `2.1` expected RED `01a6bcdd41d54a18a9d0a1f2c46522b7`: missing diagnostics header.
- Final editor build `a13d244bdb6f48e09e4fecd19eaf7e9f`: 7/7 actions, succeeded.
- Final exact Fast test `1c6cad52becb4c528a8f1970ac3d5033`: 11/11 passed, 0 failed, 0 skipped, 0 warnings, and 0 errors.
- OpenSpec doctor, exact strict active-Change validation, exact strict source-diagnostics spec validation `680fd814c44c442f9bb36b5269da9d90`, and strict all-current-spec validation: passed.
- Canonical Task DAG: 4/4 complete.

## Material friction and corrective action

- UBT requires unique C++ source basenames across a module even when files occupy distinct subdirectories. The new manager implementation became `as_frontend_source_manager.cpp`; the public header/type and preserved production manager remain unchanged.
- Task `1.2` originally omitted SourceManager files even though the accepted design makes it the query facade. The applied ownership Replan added only those declarations/forwarders; storage remains snapshot-owned.
- The first spec-create call was correctly rejected because the planned parent frontend domain did not exist. The applied Replan used `openspec.domain create` before `openspec.spec create`; both CLI-owned identities and strict validation now pass.

## Durable contract and knowledge disposition

The complete delta is present in `openspec/specs/angelscript/language/frontend/source-diagnostics/spec.md` without operation headings. Its capability knowledge records the Clang-derived separation between snapshot-local ranges, shared origin queries, display coordinates, and durable relocation. The change-local knowledge file remains immutable provenance after archive.

## Scope boundary and provenance

Harness aggregate profiles, full UE suites, Standalone, legacy tests, and upper Runtime tests were intentionally omitted. No production consumer exists yet; the exact editor build and complete SourceDiagnostics prefix directly prove compilation, source ownership, cross-snapshot rejection, lazy concurrent line queries, provenance chains, stable-anchor relocation, typed diagnostics, fix-its, delayed rendering, and deterministic parallel merge. Raw run artifacts remain under ignored `Saved/Harness/Unreal/Runs/<RunId>/`; `data/source-diagnostics-verification.md` retains the compact run identities, final report, source hashes, and exclusions.
