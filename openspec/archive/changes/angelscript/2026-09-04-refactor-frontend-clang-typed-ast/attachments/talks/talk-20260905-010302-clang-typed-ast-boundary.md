# Clang-Informed Typed AST Boundary

## Context

The user selected a real Clang-informed typed AST rather than continuing the current wide tagged records. The decision concerns the C++ semantic object model, not a request to implement the C++ language or clone Clang internals.

## Evidence

- `Temp/ast/CanonicalASTArchitectureVisual.md:2639-2698` identifies the compile-time type safety, typed API, layout, and maintenance costs lost by the existing wide-record model.
- `Temp/ast/CanonicalASTArchitectureVisual.md:3239-3275` explicitly characterizes the node representation as the shortcut within an otherwise stronger semantic architecture.
- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 3955-4043 records the desired Clang-like Parser/Sema/ASTContext separation and the absence of a durable ASTContext in the legacy pipeline.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_decl.h:49-91`, `as_stmt.h:11-34`, `as_expr.h:44-69`, and `as_ast_type.h:26-45` show the current `kind + mutually exclusive fields` records.
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/DeclBase.h`, `Stmt.h`, `Expr.h`, and `Type.h` show concrete subclasses retaining compact kind discriminators and `classof`-based casting.
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/TypeLoc.h` separates canonical semantic types from authored type spelling and component ranges.
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Basic/DeclNodes.td`, `StmtNodes.td`, and `TypeNodes.td` are single taxonomy inputs reused by generated declarations and visitors.
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/ASTContext.h` owns AST allocation/lifetime, and `RecursiveASTVisitor.h` demonstrates taxonomy-driven traversal.

## Options

1. Keep the wide records and add more verifier rules.
2. Keep wide storage but add typed facade classes/views.
3. Build genuine concrete subclasses in an isolated new frontend context and migrate later producers/consumers to that sole authority.
4. Copy Clang's complete AST taxonomy, allocation tricks, and serialization.

## Settled Decision

Choose option 3. The new lowercase `frontend` namespace owns final-named concrete node classes, one context arena, checked casts, `.def` family taxonomies, exhaustive visitors, structural verification, and read-only projections. `DeclContext` is an orthogonal ownership/lookup role. Expr participates in the `Stmt -> ValueStmt -> Expr` lineage. Canonical `Type` and compact non-node `QualType` remain separate from authored `TypeLoc`/`TypeSourceInfo`; Attr remains its own typed family.

```text
frontend::asCASTContext
├─ Decl hierarchy + orthogonal DeclContext
├─ Stmt -> ValueStmt -> Expr hierarchy
├─ canonical Type + non-node QualType
├─ authored TypeLoc / TypeSourceInfo
├─ Attr hierarchy
└─ cast / visitor / verifier / const projection / versioned codec
```

The older audit recommendation to stop at tagged storage plus typed facades was a bounded migration option, not the final requirement selected for this reconstruction. It is therefore not the authority for this Change.

## Consequences and Flip Condition

The implementation has more source files and concrete types, but illegal field combinations become harder to express and consumers gain exact APIs. Common flags and variable payloads use measured bitfield, inline, or context-owned trailing storage where focused layout tests demonstrate value. Those choices preserve the same concrete semantic API and single authority; they cannot reintroduce mutable wide records as a hidden second AST.

The Change also owns a new explicitly versioned, pointer-free flat projection/codec. It uses validated local indices plus stable source/type witnesses, rejects unknown or current wide-record wire versions before constructing a graph, and is not a copy of Clang's serialization format.

## Rejected Boundaries

- Reject renaming or wrapping the current wide records and calling that a genuine hierarchy.
- Reject a permanent typed facade over mutable wide storage as the reconstructed AST authority.
- Reject synchronized `asCScriptNode`, legacy canonical, sidecar IR, and typed-AST graphs.
- Reject copying all Clang C++ node kinds, virtual APIs, TableGen build pipeline, source-location raw encoding, or serialized pointer/ID conventions.
- Reject per-node shared ownership, runtime engine/UObject pointers, numeric runtime IDs, or cross-generation raw node pointers.
- Reject an uppercase `Frontend` namespace or `V2` suffixes that preserve duplicate provisional identities.
- Reject preprocessing records on every node; source-range query remains the normal relationship.
- Reject treating the current Canonical AST sidecar/public-view wire shape as a compatibility constraint on the new codec.

## Sources

- `Temp/ast/CanonicalASTArchitectureVisual.md:2639-2698,3239-3275`
- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 3955-4043
- [Canonical AST architecture audit 01](../../../../../../Temp/canonical-ast-cache-jit-audit/01-CanonicalAST%E6%9E%B6%E6%9E%84%E4%B8%8E%E9%97%AE%E9%A2%98.md), lines 38-216,327-375,475-503
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_decl.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_stmt.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_expr.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_type.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/DeclBase.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/Stmt.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/Expr.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/Type.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/TypeLoc.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/ASTContext.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/AST/RecursiveASTVisitor.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Basic/DeclNodes.td`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Basic/StmtNodes.td`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Basic/TypeNodes.td`
