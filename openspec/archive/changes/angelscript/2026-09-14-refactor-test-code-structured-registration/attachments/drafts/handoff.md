Source: brainstorming topic `angelscript/test-framework-completion`, scoped design `generated-structured-registration`, accepted by the user on 2026-09-14. This English handoff faithfully exports the decision-complete Chinese source.

# Draft

This handoff covers only the structured successor to the implemented one-authored-file/one-generated-C++ carrier. The archived carrier Change remains immutable. This scope does not recreate the code database or add diagnostics expectations, reload execution, LSP behavior or debugger products.

# Problem

The current CodeGenTool projects each complete authored `.as` container as an unreadable `0xNN` array. Its generated registration invokes `FAngelscriptTestSourceParser` during central activation to discover the real File/Version metadata, version tree, annotations and origin map. Generated code is not reviewable, startup performs authoring-protocol parsing, and registration initially carries placeholder metadata while final Cases carry a separately reconstructed FileMeta.

# Success Criteria

- Python parses and validates the complete v1 fixture protocol before any output mutation and produces immutable structured IR.
- One authored `.as` still maps to one mirrored `.generated.cpp`, which directly displays real FileMeta, VersionMeta, clean source, typed annotations and compact origin projection.
- Generated C++ uses `AS_TEST_SOURCE`, a captureless lambda, `FAngelscriptTestCodeBuilder` and a namespace-scope static `FAngelscriptTestCodeRegistration`; it does not include or invoke the C++ parser.
- Builder overloads admit `FAngelscriptTestSourceDescriptor` and report descriptor and version-tree errors together through terminal `Build()`.
- The C++ parser remains independent and is proven semantically equivalent to Python with shared positive and negative fixtures.
- Intentionally invalid AngelScript remains valid fixture material. Only fixture-protocol invalidity prevents generation.
- `check` remains read-only, `generate` remains explicit and ordinary UBT never runs Python.

# Evidence

- Current `Language/Counter.generated.cpp` contains a `constexpr uint8[]`, placeholder Summary and activation-time parser call. See [Current and target Counter projection](findings/generated-before-after-counter-example.md).
- `FAngelscriptTestSource::FromParsedData`, annotation maps and origin offsets are private. A structured generated provider lacks a legal admission seam.
- `FAngelscriptTestCodeBuilder` already uses declarative `AddRoot/AddVersion` followed by terminal `Build()`, which is the established accumulated-error boundary.
- The C++ annotation parser stores clean offsets and appends an original offset for clean `Num()`. A compact projection therefore needs spans plus an independent `AuthoredEnd`.
- The durable `angelscript/testing/code-database` requirement currently mandates activation-time byte parsing and must be modified.
- Active planning-only `angelscript/refactor-testing-unified-framework` still contains overlapping source-history/diff, byte-shard and aggregate-release work. It must be updated/replanned separately before this Change's product implementation begins.

# Scope and Exclusions

Included: Python fixture model, normalization, container/annotation parsing, diagnostics and tree validation; deterministic renderer; C++ Source descriptor and Builder admission; readable registration symbols; compact origin mapping; v1-to-v2 sync migration; parser conformance; focused tests and the code-database delta.

Excluded: AngelScript language compilation/semantic validation, diagnostic expectation DSL, reload/LSP/debugger execution, diff authoring, virtual project trees, Windows RCDATA, implicit Python from UBT, a second database, runtime current-version state and duplicate embedding of the complete authored container.

# Constraints

- Preserve the accepted author/tool/generated roots and per-file mirrored projection.
- Derive FileTag only from the root-relative slash-normalized path without terminal `.as`; a move changes identity.
- Require English, non-empty file and version Summaries. Keep file and version Topics separate and non-inherited.
- Store complete source for every version. Parent describes topology only.
- Default generated source to `AS_TEST_SOURCE`; prove exact equality between macro bytes and Python clean bytes.
- Emit contiguous origin spans plus `AuthoredEnd`; never emit a per-byte C++ mapping array.
- Emit namespace-scope `static` registrations under `AngelscriptTest::Generated`; use no anonymous namespace and no opaque symbol hash.
- Parse, validate and render the complete input set before atomic output replacement. Bound stale deletion to signed files under the generated root.

# Options

1. Keep activation-time C++ parsing: maximal reuse, but retains unreadable carrier, startup parsing and duplicate FileMeta truth. Rejected.
2. Use a Source-owned factory: clean object ownership, but failed validation requires another Result/error bridge or invalid Source state. Rejected.
3. Add a separate Source Builder: strong separation, but every generated lambda operates two builders. Rejected.
4. Add Builder overloads that consume `FAngelscriptTestSourceDescriptor`: concise generated code, unified terminal errors and no mutable Source storage. Selected.

# Decision and Rationale

Python is the fixture-protocol parser for the checked-in generated path. The renderer emits file/version metadata, clean `AS_TEST_SOURCE` literals, typed Points/Breakpoints/Ranges and compact origin spans plus `AuthoredEnd`. Builder overloads consume a temporary `FAngelscriptTestSourceDescriptor`, validate it and construct immutable Source data. Each registration remains one atomic admission batch.

This aligns authored source, reviewed generated diff, translation unit, registration batch and database file identity one-to-one while removing runtime container parsing and placeholder metadata. TestCode remains a material database rather than an execution framework.

# Flip Condition

Replan the selected architecture only if evidence proves one of the following:

- `AS_TEST_SOURCE` cannot deterministically preserve canonical UTF-8/LF clean bytes.
- Builder cannot aggregate descriptor validation without an invalid Source state.
- Span-based mapping cannot satisfy the current `Num()+1` original-offset behavior.
- A real runtime consumer requires the complete authored container in the DLL rather than structured Cases.

# Architecture, Components, and Data Flow

```text
authored .as
└─ Python normalization/container parser/annotation parser/tree validation
   └─ ParsedFile IR
      └─ deterministic renderer
         └─ one readable .generated.cpp
            └─ static registration + captureless lambda
               └─ Builder.AddRoot/AddVersion(Source, Descriptor)
                  └─ Build → central activation → code database

C++ Parser(bytes)
└─ retained independent protocol path and conformance tests
```

The Python package separates thin CLI, paths, discovery, model, normalization, container parsing, annotation parsing, validation, rendering and sync. Other modules may continue handwritten static registration with `AS_TEST_SOURCE` or reuse the public descriptor overload for generated providers.

# Failures and Edge Cases

- Preserve exact semantics for UTF-8, optional BOM, CRLF/CR normalization, Unicode byte coordinates and trailing LF.
- Duplicate metadata, unknown v1 directives, missing Summary/Parent, duplicate versions, missing root, cycles, invalid annotations, duplicate typed names, unmatched/crossing ranges, invalid offsets/spans/end anchor and path/symbol collisions fail before disk mutation.
- Invalid AngelScript syntax or semantics does not fail codegen when the fixture protocol is valid.
- `/** @@point name */` emits literal marker text and no annotation.
- Invalid generated descriptors reject the complete registration batch without aborting host startup or affecting unrelated batches.
- Signed v1 byte-carrier files are recognized as owned changed outputs and replaced with v2 structured projections.

# Verification

- Python unittest groups prove normalization, container and annotation parsing, tree validation, renderer goldens, symbol encoding/collisions, atomic sync and negative-language/protocol separation.
- C++ Framework Source/Builder groups prove descriptor construction, typed annotations, `Num()+1` origin mapping and invalid descriptor rejection.
- Generated Counter/adoption groups prove activation/query parity and one true Registration/Case FileMeta.
- Shared conformance fixtures prove positive semantic equality and stable negative error codes between Python and C++ parsers.
- A handwritten cross-module provider remains a control.
- Harness-owned focused UE build/test is selected only where compiled framework or activation behavior requires it.

# OpenSpec Handoff

- Change ID: `angelscript/refactor-test-code-structured-registration`.
- Title: `Generate structured AngelScript test-code registrations`.
- Domain: `angelscript`.
- Modified capability: `angelscript/testing/code-database`.
- Required planning artifacts: proposal, code-database delta spec, design, Ready Task DAG and planning-validation evidence.
- Required seeded attachments: English design/handoff/glossary, two focused findings, one Talk and two Knowledge candidates.
- Independently reviewable implementation outcomes:
  1. Python fixture model, normalization and container parser.
  2. Python annotations/origin projection and negative-protocol behavior.
  3. C++ `FAngelscriptTestSourceDescriptor` and Builder overload admission.
  4. Deterministic readable renderer, FileTag symbol encoding and macro byte parity.
  5. Atomic sync migration and Counter v2 projection.
  6. C++ parser conformance, activation/database and cross-module controls.
  7. Verified durable-spec synchronization preparation and truthful completion evidence.
- Inter-Change prerequisite: before product implementation begins, use the update lifecycle on `angelscript/refactor-testing-unified-framework` so its overlapping TestCode source-history/shard/aggregate work no longer claims this scope.

# Exploration Carryover

The user confirmed the core set:

- Talk: source discussion of build-time parsing, direct registration and retained C++ parsing → `talks/talk-20260914-201008-build-time-structured-registration.md` → retain the non-obvious architecture decision, consequences and flip condition.
- Knowledge: [Current and target Counter projection](findings/generated-before-after-counter-example.md), [Build-time parser evidence](findings/generated-build-time-parser.md), and the EOF mapping correction → `knowledges/generated-source-byte-origin-projection.md` → reusable macro-byte-parity and span/end-anchor model.
- Knowledge: the negative-source grill and [Build-time parser evidence](findings/generated-build-time-parser.md) → `knowledges/negative-script-vs-fixture-protocol.md` → reusable distinction between invalid language source and invalid fixture protocol.

Discard the complete conversation log, temporary form state, a redundant symbol talk and a separate Builder talk. Their required conclusions are already present in the design and handoff.
