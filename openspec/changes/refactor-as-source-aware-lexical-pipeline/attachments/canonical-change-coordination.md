# Coordination with `refactor-as-canonical-typed-ast-compiler`

## Relationship

The two changes are complementary and ordered by responsibility:

1. `refactor-as-source-aware-lexical-pipeline` establishes source-buffer identity, raw tokens, classification, buffered cursor navigation, current-Parser adoption, and the UE host lexical adapter.
2. `refactor-as-canonical-typed-ast-compiler` uses those inputs to establish Parser-to-Sema actions, ASTContext, canonical typed nodes, read-only Bytecode/TypedASTJIT consumption, public AST snapshots, and AST-aware Cache V2.

Neither change creates an LLVM backend. Both preserve an LLVM-ready boundary by removing source/semantic reconstruction from future lowering.

## Overlap map

| Existing canonical artifact | Existing intent | Ownership after coordination |
|---|---|---|
| `proposal.md` pipeline `SourceManager -> Parser + Sema -> ASTContext` | Defines semantic frontend shape | Refine conceptually to `SourceManager -> lexical pipeline -> Parser + Sema -> ASTContext`; canonical change remains semantic authority |
| `design.md` Decision 2 | SourceManager owns source identities/mappings | One shared implementation; lexical change lands buffer/location/line/mapping substrate, canonical change adds AST/public/cache use |
| `tasks.md` 2.1 | SourceManager tests | Reconcile before implementation: lexical tests own buffer/location/mapping/token needs; canonical tests own AST lifetime/public/cache implications |
| `tasks.md` 2.2 | `as_source_manager.h/.cpp` | Implement once in the plugin submodule; both change records point to the same evidence, but neither task is checked without its own acceptance criteria |
| `specs/as-canonical-typed-ast` “Source identity is independent from node storage” | AST source-range contract | Consumes the SourceManager substrate defined here; no duplicate stable/source-local ID types |
| `specs/as-canonical-compiler-pipeline` Parser requirement | Parser constructs canonical AST through Sema actions | Parser receives the TokenCursor defined here; this change does not construct canonical semantic nodes |
| canonical final cutover tasks | Remove `asCScriptNode` semantic authority and sidecar HIR | Not part of lexical cutover; current Parser may use TokenCursor while still building temporary `asCScriptNode` |

## Required reconciliation before applying source changes

Before either change implements `as_source_manager.h/.cpp`:

- amend the canonical task wording or add a dependency note so only one source patch creates the files;
- preserve both changes' requirements in the implementation tests;
- select one internal names/packing decision for buffer IDs, locations, ranges, and mappings;
- ensure Standard C++ sources are added once to UE maintained-fork builds and Standalone CMake;
- keep parent OpenSpec commits separate from plugin submodule commits and update the parent gitlink only after the plugin commit exists;
- do not mark canonical Tasks 2.1/2.2 complete merely because lexical tests pass; public AST/cache/source-retention scenarios must also pass there;
- do not mark the lexical SourceManager milestone complete merely because AST tests exist; RawLexer/TokenBuffer/preprocessor source mapping scenarios must pass here.

## Sequencing gates

| Gate | Lexical change evidence | Canonical change may then |
|---|---|---|
| L1 Source substrate | Immutable buffer IDs/generations, checked ranges, line tables, mappings | Store source ranges on syntax/semantic nodes |
| L2 Token contract | Deterministic raw/final tokens and error categories | Consume tokens without inventing a second kind/range model |
| L3 Cursor Parser | Current Parser uses checkpointed token indices with parity | Replace Parser node construction with Sema actions independently of byte rewind |
| L4 Host provenance | Authored/processed/generated mappings survive UE preprocessing | Publish canonical AST diagnostics/source views across UE builds and Hot Reload |
| L5 Lexical cutover | No duplicate production raw scanner; all host/core parity gates pass | Treat the lexical input as stable while retiring legacy semantic paths |

## Cache V2 boundary

This lexical change does not create a token sidecar. The shared durable boundary is:

```text
stable logical source key
content/profile/lexical compatibility identity
authored/processed/generated mapping DTO
source range DTO
```

The canonical change may attach these ranges to AST records and function-body sidecars. It must not serialize a live `asCTokenBuffer`, `asCTokenCursor`, build-local identifier ID, literal ID, or source-buffer ID as durable authority.

## Completion independence

Lexical completion means the current compiler and UE host use one verified lexical truth. It does not mean:

- canonical typed AST/Sema exists;
- HIR has been removed;
- Bytecode consumes canonical AST;
- public AST V1 or Cache V2 AST sidecars exist;
- LLVM lowering has been implemented.

Canonical compiler completion depends on the lexical input contract but retains its own 93-task semantic/backend/public/cache acceptance plan.
