
# Clang Typed AST Shape and Lifetime

## Reusable Insight

Clang's reusable lesson is not “copy every class.” It is the combination of concrete semantic subclasses, a compact kind on each family base, checked `classof` casting, taxonomy-driven exhaustive consumers, and context-owned lifetime. AngelScript can use that shape with its own smaller language taxonomy, UE containers, immutable source snapshots, and explicit runtime/persistence boundaries.

## Evidence

| Mechanism | Clang source | AngelScript application |
|---|---|---|
| Concrete declaration subclasses plus base kind | `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/DeclBase.h`; `clang/include/clang/AST/Decl.h` | Concrete `asCDecl` subclasses store only relevant declaration payload. |
| Orthogonal declaration context | `clang/include/clang/AST/DeclBase.h` | `asCDeclContext` owns declaration lookup/nesting without replacing concrete `asCDecl` types. |
| Expr in Stmt lineage | `clang/include/clang/AST/Stmt.h`; `clang/include/clang/AST/Expr.h:112` | `asCExpr` derives through `asCValueStmt` from `asCStmt`, preserving statement traversal and value/expression APIs. |
| Concrete type forms and compact qualified use | `clang/include/clang/AST/Type.h`; `clang/include/clang/AST/TypeBase.h` | Separate canonical `asCType` subclasses from `asCQualType` use-site qualifiers. |
| Semantic type versus authored spelling | `clang/include/clang/AST/TypeLoc.h`; `clang/include/clang/AST/TypeBase.h:8263+` | Keep canonical `Type`/`QualType` separate from `asCTypeLoc`/`asCTypeSourceInfo` ranges and spelling. |
| Context allocation/lifetime | `clang/include/clang/AST/ASTContext.h:220+` | One non-copyable context owns arena nodes and the immutable source lease. |
| Canonical type uniquing and compact payload | `clang/include/clang/AST/ASTContext.h`; `clang/include/clang/AST/Type.h`; `clang/include/clang/AST/Stmt.h` | Intern equivalent canonical types and use measured bitfield, inline, or trailing payload storage under focused layout tests. |
| Taxonomy-generated dispatch | `clang/include/clang/Basic/DeclNodes.td`, `StmtNodes.td`, `TypeNodes.td`; generated `.inc` use in visitors | Small checked-in `.def` files drive kinds, forward declarations, casts, visitor/verifier coverage. |
| Exhaustive traversal | `clang/include/clang/AST/RecursiveASTVisitor.h` | Deterministic owning-child traversal with explicit non-owning cross-reference hooks. |
| Source locations are manager-bound | `clang/include/clang/Basic/SourceLocation.h`; `clang/include/clang/Basic/SourceManager.h` | Keep AST ranges snapshot-bound; do not persist or compare raw manager-local encodings. |

Project evidence confirms why the shift is needed: root `as_decl.h`, `as_stmt.h`, `as_expr.h`, and `as_ast_type.h` expose broad mutually exclusive fields selected by `kind`; `Temp/ast/CanonicalASTArchitectureVisual.md:2639-2698,3239-3275` documents the resulting compile-time safety and maintenance loss.

## Boundaries

- Genuine inheritance does not require virtual RTTI on every node; compact kinds and checked casts remain appropriate.
- Typed pointers are valid only inside the owning context lifetime. Public, persisted, and cross-generation boundaries use checked handles, stable identities, or value projections.
- A context seal proves structural immutability, not runtime publication or ABI compatibility.
- Read-only projections are consumer adapters, not mutable mirror graphs.
- A bounded pointer-free flat projection/codec may persist sealed graphs through validated local indices and stable witnesses, but it has its own explicit version and deliberately does not decode the current wide-record sidecar/public-view wire shape.
- UE strings, names, containers, maps, and smart pointers are allowed implementation choices; live engine/UObject state remains outside AST semantics.

## Rejected Boundaries

- No “kind plus every optional field” record as the new authoritative node representation.
- No long-term typed facade backed by a mutable wide semantic record.
- No synchronized legacy AST, `asCScriptNode`, generic IR, and new AST authorities.
- No copy of Clang's full C++ grammar taxonomy, raw `SourceLocation`, serialization format, pointer identity, or TableGen toolchain requirement.
- No per-node `TSharedPtr`, runtime `typeId`, `TypeInfo*`, function ID, or UObject/engine pointer.
- No preprocessing entity ID on every AST node.

## Application

When adding a node kind, first place it once in the correct family taxonomy, then define its concrete payload and construction invariant. Cast, visit, verify, dump, projection, and codec behavior must derive from or be exhaustively checked against that entry. When adding a consumer, read the typed node or a const projection from the sealed context; never recreate semantic truth in a parallel record.

## Sources

- `Temp/ast/CanonicalASTArchitectureVisual.md:2639-2698,3239-3275`
- [Temp reconstruction transcript 1](../../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 3955-4043
- [Canonical AST architecture audit 01](../../../../../../../Temp/canonical-ast-cache-jit-audit/01-CanonicalAST%E6%9E%B6%E6%9E%84%E4%B8%8E%E9%97%AE%E9%A2%98.md), lines 38-216,327-375,475-503
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_decl.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_stmt.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_expr.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_type.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/DeclBase.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/Decl.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/Stmt.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/Expr.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/Type.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/TypeBase.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/TypeLoc.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/ASTContext.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/RecursiveASTVisitor.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Basic/DeclNodes.td`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Basic/StmtNodes.td`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Basic/TypeNodes.td`

