# Build-time fixture parsing and direct registration evidence

Source identity: focused finding `generated-build-time-parser.md` from brainstorming topic `angelscript/test-framework-completion`, translated and scoped for this Change on 2026-09-14.

## Corrected objective

The readability defect is not limited to hexadecimal bytes. The current generated path treats the full authored `.as` container as opaque data and defers all fixture-protocol interpretation to `FAngelscriptTestSourceParser` during module activation. The accepted target makes Python implement the same authoring protocol and render already structured C++.

Python parses file and version `@version`, `@summary`, `@topic` and `@parent` directives; explicit `/** @end */` boundaries; `@point`, `@breakpoint`, `@range-begin` and `@range-end`; clean source bytes; authored-origin mapping; and UTF-8/BOM/newline, duplicate, topology and range validity.

Generated C++ directly constructs Builder inputs and never scans metadata or source markers. The C++ parser remains a separate capability.

## Current flow

```text
Counter.as
└─ Python discovery: path, raw bytes, hash
   └─ C++ renderer: uint8[] plus placeholder FileMeta
      └─ static registration
         └─ ActivateRegistrations
            └─ FAngelscriptTestSourceParser::Parse
               ├─ metadata and version parsing
               ├─ annotation removal
               ├─ origin-map construction
               └─ Builder validation and Cases
```

The renderer currently hard-codes format v1 and a placeholder Summary. During factory execution the C++ parser uses the registration Tag but reconstructs real FileMeta from the container. The activation record and final Cases therefore do not initially share one metadata truth.

## Target flow

```text
Counter.as
└─ Python fixture parser
   └─ ParsedFile IR
      ├─ FileMeta
      ├─ VersionMeta[] and parent topology
      ├─ clean source[]
      ├─ typed annotations[]
      └─ compact origin projection[]
         └─ readable structured generated C++
            └─ static FileMeta + captureless factory
               └─ Builder.AddRoot/AddVersion + Build
                  // No container or annotation parsing.

FAngelscriptTestSourceParser::Parse(bytes)
└─ independent C++ path
   ├─ handwritten/dynamic containers
   ├─ parser and conformance tests
   └─ future evidence-backed runtime import
```

## Existing reusable C++ boundaries

- `FAngelscriptTestCodeRegistration` already accepts FileMeta and a captureless function-pointer-compatible factory.
- `FAngelscriptTestCodeBuilder` already owns AddRoot/AddVersion/Build and validates root, duplicates, parent existence and cycles.
- `FAngelscriptTestSourceCase`, activation, database admission and query interfaces are carrier-independent.
- `FAngelscriptTestSource::FromParsedData` is private, and annotations/origin storage is private. A controlled public descriptor accepted by Builder is the missing seam.

## Negative source boundary

Builder does not compile AngelScript. `int X=Missing;` with valid fixture metadata is a successful material. Python must preserve this behavior and validate only the fixture/container protocol.

- Compile-negative, reload-negative and diagnostic-negative bodies are normal generated inputs.
- Missing metadata, duplicate versions, missing parents and invalid annotation structure are codegen errors.
- Intentionally bad fixture containers belong to tool/parser test fixture directories excluded from production discovery.

## Origin projection

The current runtime map stores one original offset per clean byte plus an EOF entry. Emitting that array would recreate the numeric-noise and size problem. Generated data uses contiguous mapping spans:

```text
FOriginSpan
├─ CleanBegin
├─ AuthoredBegin
└─ Length
```

Marker removal or newline normalization starts a new span. A separate `AuthoredEnd` maps clean `Num()` because terminal marker removal can make EOF discontinuous from the last visible byte. The initial C++ implementation may expand spans plus that endpoint internally.

## Two-parser drift

Python and C++ implementations require one durable authoring specification and shared positive/negative fixture semantics. Compare FileMeta, VersionMeta, clean bytes, annotations, origin mapping and stable error codes. Message prose and independent-error ordering may differ.

## Contract conflicts

The current durable code-database spec still requires generated authored bytes to be parsed during central activation. The archived carrier design explicitly made Python a byte projector. Both are intentionally superseded by this Change's delta rather than silently edited in history.

The active planning-only `angelscript/refactor-testing-unified-framework` also contains a Python SourceHistory/diff model, byte-array shards and aggregate release design. Its overlapping TestCode ownership must be removed through a separate update/replan before implementation of this Change; two contradictory active implementation plans must not execute in parallel.

## Embedded payload boundary

The generated default stores structured File/Version metadata, clean version source, typed annotations, compact origin data, authored path/length and hash. It does not duplicate the complete authored container. A later real runtime need may introduce an optional original-container payload through its own design.
