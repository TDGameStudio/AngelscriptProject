## Context

The implemented carrier already provides deterministic discovery, one mirrored generated C++ file per authored `.as`, checked-in synchronization, static `FAngelscriptTestCodeRegistration`, central activation, immutable Cases and handwritten cross-module providers. Its Python layer projects raw bytes; the C++ parser discovers all meaningful structure during activation. The accepted exploration and exact Counter evidence are indexed under `attachments/`.

The owning implementation spans the repository-root Python tool and the `Plugins/Angelscript` submodule. Existing unrelated dirty work is outside this Change. Active planning-only `angelscript/refactor-testing-unified-framework` describes incompatible source-history, shard and aggregate ownership and must be updated separately before this plan is implemented.

## Goals / Non-Goals

**Goals:**

- Make Python the fixture-protocol parser for checked-in generated files.
- Produce readable structured Builder registrations with one FileMeta truth.
- Admit authored annotations and compact origin mapping through a validated public descriptor.
- Retain and prove the independent C++ parser.
- Preserve explicit atomic sync and negative-language material.

**Non-Goals:**

- Compiling, formatting or semantically validating AngelScript in Python.
- Diagnostic expectations, reload/LSP/debugger execution, diff authoring or virtual project trees.
- Windows resources, implicit UBT generation, a second database or full original-container payloads.
- Implementing or rewriting the older unified-framework Change inside this Change.

## Decisions

### Parse before rendering and mutation

Discovery reads every authored file, normalization and the fixture parser produce immutable byte-coordinate IR, validation covers metadata/annotations/topology/symbol identity, and only then does the pure renderer produce expected C++ bytes. `check` compares the plan without writes; `generate` atomically applies it and removes signed stale files last.

This rejects malformed fixture protocol before any mixed output state while allowing deliberately invalid AngelScript bodies.

### Keep Python components directional

`model.py` and normalization are low-level. Discovery, container and annotation parsers produce IR. Validation does not render. `cpp_renderer.py` is filesystem-free. `sync.py` owns the common plan and `cli.py` owns commands/messages only. Focused modules may be combined when implementation evidence shows no independent responsibility, but these dependency directions remain.

### Use typed clean-source and origin IR

Each ParsedVersion owns complete clean UTF-8 bytes, version metadata, Points, Breakpoints, half-open Ranges, authored body line, contiguous `{CleanBegin, AuthoredBegin, Length}` spans and an independent `AuthoredEnd` for clean `Num()`. Authored offsets refer to unmodified file bytes. The C++ seam may initially expand spans plus endpoint into the current `Num()+1` array.

### Admit through Builder-owned Source descriptors

`FAngelscriptTestSourceDescriptor` is an exported temporary construction value with nested Point, Breakpoint, Range, OriginSpan and annotation records. Existing two-argument Builder calls remain supported. New overloads accept `(VersionMeta, Source, Descriptor)`, validate descriptor invariants, copy/move data into private immutable Source storage and accumulate failures in terminal `Build()`.

A Source factory was rejected because failed validation needs another result bridge or invalid Source state. A second Source Builder was rejected as generated-call boilerplate. Mutable public annotation/origin maps remain forbidden.

### Render readable Unity-safe registrations

Each generated translation unit declares one namespace-scope `static FAngelscriptTestCodeRegistration` under `AngelscriptTest::Generated` and initializes it with a captureless lambda. The symbol is `GRegistration_` plus deterministic reversible FileTag encoding; the entire symbol set is collision-checked. No anonymous namespace or opaque hash suffix is required. SHA-256 remains in the generated header.

The lambda displays real FileMeta and complete VersionMeta, calls `AS_TEST_SOURCE` for clean bodies, supplies typed descriptors, and returns `Builder.Build()`. It has no named build helper and does not include or call the C++ parser.

### Prove macro byte equality

The renderer uses a canonical raw-literal envelope, common indentation and a deliberate extra blank line when preserving a terminal clean LF. It selects a non-conflicting delimiter. Python goldens and a compiled C++ fixture must prove `ParsedVersion.clean_source == AS_TEST_SOURCE(literal).GetBytes()` so annotation offsets cannot drift.

### Retain C++ parsing with semantic conformance

The C++ parser remains public for handwritten/dynamic containers and focused tests. Shared fixtures compare positive metadata, ordering, clean bytes, annotations and all origin offsets; negative fixtures compare stable primary codes and locations. Generated production paths do not depend on the parser.

### Migrate signed v1 output to v2

The generator header advances independently from authored `@version v1`. Existing signed v1 projections are recognized as owned changed outputs and regenerated. Unsigned/foreign files remain preserved and reported. Complete authored containers are not duplicated into production generated C++.

## Compatibility and Ownership

- Existing `AS_TEST_SOURCE`, two-argument Builder methods, Source/Case queries, static Registration and one-shot activation remain available.
- Other test modules may continue handwritten registration or use the new descriptor overload.
- Python/root fixture work belongs to the parent repository. C++ framework and generated translation units belong to `Plugins/Angelscript`; submodule changes land there before a later parent gitlink update.
- No existing archived Change is edited. The stale active unified-framework plan is a separately governed prerequisite, not a task hidden inside this Change.

## Failure Containment

Python collects independent reliable protocol errors and performs no output mutation until the complete parse/render plan is valid. C++ defensively validates hand-edited/generated descriptors; a failed registration publishes no Cases, retains structured errors and does not abort host startup or affect unrelated batches. FileTag/output/symbol collisions have no order-dependent winner.

## Risks / Trade-offs

- Two parsers can drift; durable semantics and shared fixtures are mandatory.
- Normalized literals can shift bytes; dual Python/C++ parity proof is mandatory.
- Builder takes limited Source-construction responsibility; the accepted reduction in Result/bridging complexity outweighs that coupling.
- Checked-in generated diffs grow with metadata, but remain readable and per-file rather than opaque or aggregate.
- Test-only C++ conformance may read shared fixture files from the host project; production database loading must remain disk-independent.

## Migration and Rollback

Migration is deterministic regeneration of signed v1 files after parser/renderer and descriptor support are ready. A failed generation leaves existing output unchanged. During development, the current v1 projection remains recoverable from Git; rollback restores the previous generator and signed projections together. Runtime dual-carrier fallback is not added because duplicate FileTags would make admission ambiguous.
