# Clang AST architecture reference

This attachment records the local primary-source evidence behind the design. It is research context, not an additional dependency or a requirement to copy Clang code.

## Local revision

```text
Repository: Reference/llvm-project
Commit:     9bc4fd0fafb58ff1fb50231e39a882a678542dac
Date:       2026-08-09
```

The checkout is sparse, but the complete sources remain available as Git objects. Read them with commands such as:

```powershell
git -C Reference/llvm-project show HEAD:clang/include/clang/AST/ASTContext.h
```

## Evidence map

| AngelScript decision | Clang source evidence | Principle adopted |
|---|---|---|
| Context-owned arena lifetime | `clang/include/clang/AST/ASTContext.h` | Long-lived AST nodes owned and bulk-released by one context |
| Tagged, data-oriented statement hierarchy | `clang/include/clang/AST/Stmt.h` | Compact class tags and `isa/cast`-style traversal rather than per-node shared ownership |
| Expressions carry exact type | `clang/include/clang/AST/Expr.h` | Typed expressions are semantic nodes, not token wrappers |
| Declarations are distinct from statements | `clang/include/clang/AST/DeclBase.h` | Decl/Type/Stmt/Expr are separate responsibilities |
| Parser invokes semantic actions | `clang/include/clang/Parse/Parser.h` | Parser receives Sema actions rather than owning final semantic decisions |
| Sema builds the AST | `clang/include/clang/Sema/Sema.h` | Lookup, overload, conversions, access, and AST building share one authority |
| Backends read typed AST | `clang/lib/CodeGen/CGStmt.cpp`, `clang/lib/CodeGen/CGExpr.cpp` | CodeGen consumes `const Stmt*`/`const Expr*` and does not repeat frontend Sema |
| CFG is derived | `clang/include/clang/Analysis/CFG.h` | Build analysis CFG from Decl/Stmt/ASTContext on demand |
| Implicit semantics are explicit nodes | `clang/include/clang/AST/Expr.h`, `clang/include/clang/AST/ExprCXX.h` | Cast, construction, single-evaluation, temporary materialization, and cleanup are AST facts |

Relevant implicit-node examples include `ImplicitCastExpr`, `OpaqueValueExpr`, `CXXConstructExpr`, `ExprWithCleanups`, and `MaterializeTemporaryExpr`.

## Adopted versus excluded

Adopt:

- SourceManager separated from AST nodes;
- Parser + Sema action boundary;
- ASTContext ownership and canonical type interning;
- Decl/Type/QualType/Stmt/Expr layering;
- explicit implicit conversions, temporaries, cleanup, and single-evaluation;
- read-only backend traversal;
- deterministic dump/verifier and derived CFG;
- arena allocation, compact tags, non-owning internal references, and bulk lifetime.

Exclude:

- concrete Clang classes and libraries;
- C++ templates/instantiation, Objective-C, CUDA, OpenMP, HLSL, PCH, and Clang Modules complexity;
- public exposure of arena pointers or concrete internal C++ layouts;
- any assumption that LLVM core supplies a source AST;
- LLVM IR lowering or LLVM runtime/object lifecycle in this change.

## Current AngelScript evidence

- `as_scriptnode.h`: generic node type/token/source span plus parent/child/sibling links.
- `as_parser.cpp`: nodes allocated from Parser `FMemStackBase`.
- `as_builder.h/.cpp`: `asCScriptNode*` used through declaration/type/default/import registration and diagnostics.
- `as_compiler.h`: `asCExprContext` combines `asCByteCode`, resolved value/type state, Parser node, and HIR expression identity.
- `as_compiler.cpp`: semantic analysis and Bytecode emission remain interleaved.
- `as_typed_semantic_ir.h/.cpp`: separate function-owned statement/expression/symbol/cleanup representation and verifier.
- `as_datatype.h`: `asCDataType` retains Engine-local `asCTypeInfo*`, so live HIR is not a portable pointer-free DTO.

## Secondary daScript evidence

`Reference/daScript` uses a final typed/normalized `Function + Expression` graph as the common input for interpreter/AOT/LLVM visitors. This supports the conclusion that a typed AST can also be the high-level IR. Its GC/raw-pointer identity is not adopted because this project additionally requires Cache V2, Hot Reload, module generations, stable artifact identity, and public snapshot leases.
