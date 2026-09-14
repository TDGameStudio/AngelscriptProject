## Context

The existing parser accepts raw `.as` v1 container bytes and the existing registration stores deferred factory callbacks until a one-shot central activation barrier. The current RCDATA owner is therefore a replaceable byte carrier, not a database requirement. The approved exploration is exported in [attachments/drafts/design.md](attachments/drafts/design.md), and inspected implementation evidence is in [attachments/drafts/findings/generated-cpp-manual-sync.md](attachments/drafts/findings/generated-cpp-manual-sync.md).

## Goals / Non-Goals

**Goals:**

- keep `.as` as the only authored semantic truth;
- produce deterministic, mirrored, checked-in C++ with one translation unit per source;
- keep generation and read-only drift detection on one synchronization plan;
- reuse public static registration, central activation, parser, database, and queries;
- remove every resource-only build and runtime path;
- make stale cleanup bounded and no-op generation timestamp-stable.

**Non-Goals:**

- interpreting metadata, annotations, versions, diffs, diagnostics, reload plans, or tooling protocols in Python;
- changing the code database's admission and query model;
- adding an aggregate runtime generated index or a private generated batch seam;
- making ordinary UBT invoke Python;
- changing or closing the older planning-only unified-framework Change.

## Decisions

### One authored source maps to one generated translation unit

`AngelscriptTestCode/Language/Counter.as` maps reversibly to `Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Counter.generated.cpp`, and its FileTag is `Language/Counter`. Per-source output aligns author review, Git diffs, compilation, static registration, and admission batches. Fixed hash shards remain a later evidence-driven optimization rather than a first-version policy.

### Python is a byte projector, not a container parser

Discovery normalizes paths and reads raw bytes. The pure renderer emits a length-aware `uint8` array, source identity, byte length, SHA-256, and a stable digest-suffixed C++ symbol set. The generated factory calls `FAngelscriptTestSourceParser::Parse`, leaving metadata, annotation removal, version graphs, and origin coordinates under one C++ authority.

### A modular package owns one shared synchronization plan

`codegen.py` only delegates to `angelscript_test_codegen.cli`. Model/path modules are lower-level, discovery never writes, the renderer never touches the filesystem, and `sync.build_sync_plan()` supplies both modes. `check` only reports the plan; `generate` validates and renders all sources before atomically replacing changes and then deleting safe signed stale outputs.

### Static registration is the runtime index

Each generated translation unit constructs one `FAngelscriptTestCodeRegistration`. It records a factory during static initialization and parses only at the established activation barrier. There is no generated aggregate or runtime index. Handwritten providers continue using the same registration and `AS_TEST_SOURCE` path.

### Resource transport is deleted in the same migration

The Build.cs generator, `.rc`, JSON resource index, Win32 loader, private batch bridge, resource unit tests, and incremental resource helper are deleted. The module retains only central activation. This avoids duplicate FileTags and two drift contracts.

## Failure modes and safety

- Discovery rejects invalid, escaping, and case-fold-colliding paths before any mutation.
- `CodeGenTool/**` is excluded even when tests store `.as` fixtures there.
- `check` performs no filesystem mutation, including directory creation.
- `generate` does not rewrite equal bytes; stale deletion is restricted to signed `.generated.cpp` files beneath the exact generated root and occurs only after all desired writes succeed.
- An unsigned extra file is preserved and reported instead of being deleted.
- Output excludes absolute paths, timestamps, locale-sensitive formatting, and Python `hash()`.
- Generated C++ names have stable digest suffixes and remain distinct if UBT Unity Build merges translation units.
- Source origin remains the authored relative `.as` path; generated C++ physical locations do not overwrite parser coordinates.

## Compatibility and migration

The checked-in projection changes carrier transport but retains public file/version identities and source bytes. Existing exact and topic queries, activation errors, `FAngelscriptTestCodeRegistration`, and `AS_TEST_SOURCE` remain compatible. The first generated `Counter` projection replaces the resource-provided `Language/Counter`, and the `AngelscriptTestJIT` provider remains the cross-module handwritten control.

Rollback is a normal source revert of the whole migration. Runtime coexistence is intentionally unsupported because two providers claiming `Language/Counter` would be rejected as conflicting batches.

## Risks / Trade-offs

- Authors must run `generate`; a fixed `check` verification is required to prevent drift.
- Adding, deleting, or renaming a fixture changes the UBT source set; this is accepted for the one-to-one mapping.
- Generated byte arrays add review volume, but their deterministic source identity and hash make changes auditable.
- Atomic replacement is per file rather than a transactional filesystem snapshot. Whole-plan validation occurs before writes, and stale deletion is last, so semantic input failures cannot produce a partial expected set.

