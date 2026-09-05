## Context

The current parser owns a character offset and calls the engine tokenizer directly. Parser diagnostics are routed through Builder line calculations, while Builder can call `engine->WriteMessage`. Existing source-location and AST-diagnostic files contain useful pieces, but the next frontend cannot treat a mutable Engine or an individual parser as source-lifetime authority.

Clang's actual model is layered: AST nodes retain compact `SourceLocation`/`SourceRange`, `ASTContext` references a `SourceManager`, spelling and expansion provenance lives in source-location entries, and optional preprocessing records are queried by range. Raw Clang locations are only meaningful with one unchanged SourceManager and are relocated through a different serialization encoding.

## Goals / Non-Goals

**Goals:**

- Establish one immutable source lifetime for all frontend products.
- Preserve explicit UTF-8 byte coordinates and half-open ranges.
- Support source-origin and later preprocessing backqueries without bloating each AST node.
- Unify structured diagnostics across frontend stages.
- Make read-only source and diagnostic results deterministic under later parallel execution.

**Non-Goals:**

- Copy Clang's packed raw-location representation, macro machinery, include graph, or PCH serialization.
- Parse tokens, directives, declarations, or bodies in this Change.
- Route the current production Parser or Builder to the new model.
- Create UObjects, runtime types, bytecode, or Engine registrations.

## Decisions

### A snapshot is the ownership and validity boundary

`asCSourceSnapshot` owns immutable UTF-8 buffers, logical source metadata, a lazily built line map, origin records, and a unique runtime snapshot identity. `asCSourceManager` is the query facade used by the compilation session. Files are added during snapshot construction and become immutable on freeze.

`asCSourceLocation` is `(FileID, ByteOffset)` and `asCSourceRange` is `[Begin, End)`. Public query handles also carry or are validated against their snapshot owner; two equal FileID integers from different snapshots are never interchangeable. The design keeps this explicit representation instead of imitating Clang's opaque 31-bit virtual address space.

### Stable anchors are different from snapshot-local locations

Snapshot-local ranges are optimized for one compilation. Cross-compilation storage uses an `asSStableSourceAnchor` containing canonical logical source key, source content digest/revision, and byte range. It never treats a filesystem path or line number as stable identity. Consumers relocate an anchor into a later snapshot and handle a missing or changed revision explicitly.

### Provenance is range-indexed shared data

The snapshot stores an origin graph for directly spelled, directive-produced, transformed, and synthetic ranges. Ordinary tokens and AST nodes retain ranges only. A consumer walks `range -> source manager -> overlapping origin records -> parent chain`. Rare products that need a direct origin handle may store a snapshot-local ID, but its owner check is mandatory.

### Diagnostics remain structured until presentation

`asCDiagnosticsEngine` accepts a diagnostic ID, severity, ranges, typed arguments, and fix-its and forwards immutable records to `asIDiagnosticConsumer`. The engine does not calculate display strings eagerly or call the live script engine. A collecting consumer supports tests; a later adapter may render messages to existing UE or AngelScript reporting surfaces at the unified cutover.

Final diagnostic order uses stable logical source ordering and byte coordinates rather than task completion order. A fragment-local sequence resolves otherwise equal records without a global atomic becoming semantic identity.

### API and placement boundary

New types are fork-internal public classes beneath `BEGIN_AS_NAMESPACE` and the nested lowercase `frontend` namespace, with files in the new `ThirdParty/angelscript/source/frontend/` directory. They are not added to the stable public `angelscript.h` ABI. Existing source classes can be adapted or retired only during the later unified cutover; this Change introduces no second production route.

Unreal Build Tool requires distinct C++ source basenames across one module's non-Unity inputs. Public frontend headers retain their direct conceptual names, while a new implementation unit whose basename would collide with a preserved production source uses an `as_frontend_` implementation prefix. This is a build-artifact identity rule, not a public type-name prefix.

## Risks / Trade-offs

- Lazy caches can violate apparent immutability if initialized unsafely. Freeze plus thread-safe once-only publication is required, and tests distinguish logical immutability from eager allocation.
- Retaining immutable bytes and provenance for an AST lifetime costs memory. One root lease avoids per-node shared-pointer overhead, and later measurements can tune retention without changing coordinate semantics.
- UTF-8 byte columns differ from code-point and terminal-display columns. The diagnostic renderer must name its presentation convention; stored offsets remain bytes.
- Source anchors cannot magically track arbitrary edits. Content revision mismatch is an explicit relocation failure, not a fuzzy match hidden inside the core source model.
