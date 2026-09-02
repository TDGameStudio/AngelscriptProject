# LLVM/Clang encoding adopted for canonical AST

Primary source: `Reference/llvm-project` (local `D:\LLVM\llvm-project-22.1.8.src`, tag `llvmorg-22.1.8`). LLVM core has no source-language AST. The adopted model is Clang's frontend, not LLVM IR.

This change does **not** link Clang/LLVM, copy Clang headers, or store `llvm::Value*`.

## Mapping

| Clang | AngelScript canonical AST | Why |
| --- | --- | --- |
| `SourceManager` + `FileID` + `SourceLocation` | `asCSourceManager` + `asASTFileID` + `asCSourceLocation` | Nodes store compact coords; section strings live in the manager |
| `SLocEntry` authored vs expansion | `asEASTSourceOrigin` authored / processed / generated | Preprocessor and compiler-generated bodies must remap |
| `ASTContext` bump allocator + type uniquing | `asCASTContext` arena + interned `asCType` | One owner, bulk free, canonical types |
| `QualType` (type pointer + qualifier bits) | `asCQualType` (`asASTTypeRef` + packed qualifier mask) | Public/cache identity has no `asCTypeInfo*` |
| `Decl` / `DeclContext` | `asCDecl` + parent/child ID ranges | Declarations are not statements |
| `Stmt` / `Expr` + `QualType` + value kind | `asCStmt` / `asCExpr` + `asCQualType` + `asEASTValueCategory` | Expressions are typed semantic nodes |
| `isa<>` / `cast<>` | `asASTIsa` / `asASTCast` on kind tags | Compact tagged hierarchy, no per-node vtables required |
| Parser calls `Sema` actions | `asCParser` → `asCSema` | Parser does not own overload/conversion/lifetime |
| `ImplicitCastExpr` / `OpaqueValueExpr` / `CXXBindTemporaryExpr` / `MaterializeTemporaryExpr` | explicit conversion, sequence/single-eval, temporary identity, exact action target, activation/lifetime-extension facts | Backends must not re-infer Sema |
| `ExprWithCleanups` full-expression boundary | Canonical full-expression/lifetime region fact | It marks that cleanup semantics exist; it is not an expanded per-edge cleanup list |
| `CodeGenFunction` reads `const Stmt*` | `asCBytecodeCodeGen` / TypedASTJIT read sealed AST | No `asCExprContext::bc` in Sema |
| `EHScopeStack` / `RunCleanupsScope` / branch-through-cleanup lowering | backend-local cleanup/EH stacks, labels, patches, slots, active flags and physical tables | Lower verified actions without persisting backend state |
| On-demand Analysis `CFG` implicit-dtor/lifetime elements | shared transient derived lifetime/control view now; general typed CFG later | Deterministic verification projection, never semantic transport or HIR |

## Lifetime and partial-construction boundary (approved 2026-08-28)

Clang 22.1.8 does not store or serialize one fully expanded
initializer-abort cleanup list on every AST edge. Its three relevant layers
are:

1. AST/Sema stores exact initializer, constructor, destructor, temporary,
   materialization, storage-duration and lifetime-extension facts;
2. Analysis CFG optionally derives implicit destructor/lifetime elements from
   the AST;
3. CodeGen uses a function-local cleanup/EH stack and pushes an active cleanup
   only after initialization succeeds.

Primary local-source evidence:

- `clang/include/clang/AST/Decl.h:926-972`, `1356-1376` — `VarDecl`
  initializer facts;
- `clang/include/clang/AST/ExprCXX.h:1458-1517` — exact temporary destructor
  and `CXXBindTemporaryExpr`;
- `clang/include/clang/AST/ExprCXX.h:1540-1703` — resolved
  `CXXConstructExpr`;
- `clang/include/clang/AST/ExprCXX.h:3648-3698` —
  `ExprWithCleanups` boundary and explicit statement that the temporary set need
  not be separately stored;
- `clang/include/clang/AST/ExprCXX.h:4910-4989` — materialization, extending
  declaration and storage duration;
- `clang/include/clang/Analysis/CFG.h:1224-1271` and `365-528` — optional
  derived CFG elements;
- `clang/lib/CodeGen/CGDecl.cpp:1345-1352`, `2134-2216` — local cleanup is
  registered only after initialization returns;
- `clang/lib/CodeGen/CGClass.cpp:548-713` — base/member cleanup is pushed only
  after the individual initializer succeeds;
- `clang/lib/CodeGen/CGClass.cpp:2202-2263` and
  `clang/lib/CodeGen/CGDecl.cpp:2424-2602` — array committed-prefix cleanup;
- `clang/lib/Serialization/ASTWriterStmt.cpp:1763-1782`, `1946-1950`,
  `2025-2040`, `2295-2302` — semantic AST serialization, not CodeGen cleanup
  stack serialization.

The adopted AngelScript rule is therefore behavioral, not a copy of Clang's
single-backend storage architecture:

```text
initializer action starts       -> subject is pending, not cleanup-live
initializer succeeds            -> commit/activation makes subject live
later initializer fails         -> clean only earlier committed subjects
cleanup order                   -> strict reverse committed order
complete-object destructor      -> legal only after complete-object commit
array/aggregate failure         -> clean only the validated element prefix
```

Because AngelScript has Bytecode, TypedASTJIT/AOT, verification, snapshot and
Provider consumers, exact action/activation/region/construction facts live in
a versioned snapshot-owned Canonical lifetime protocol. One deterministic,
transient shared view derives edge liveness and cleanup order. Backend cleanup
stacks remain local. The view is never serialized, published, parsed from
dumps, or retained as a renamed HIR.

## Encodings locked for implementation

### Source location

- `asASTFileID` 0 is invalid; 1+ is snapshot-local.
- `asCSourceLocation` is `{fileID, offset}` (byte offset in that section buffer). Invalid = `{0,0}` with `fileID==0`.
- `asCSourceRange` is `[begin, end)`.
- Stable cache/public identity is `{logicalKey, origin, offset, length}`, remapped to new FileIDs on restore.
- Diagnostics still emit maintained section/row/column via SourceManager line tables.

This is Clang's split (compact loc vs manager tables) without 32-bit packed SLocEntry compression. Script sections can exceed 64KiB, so offset is 32-bit.

### QualType

Packed qualifier mask (`asDWORD`):

| Bit | Meaning |
| ---: | --- |
| 0 | const |
| 1 | handle |
| 2 | auto-handle |
| 3 | reference |
| 4-5 | param dir: 0 none, 1 in, 2 out, 3 inout |

Canonical `asCType` is interned in `asCASTContext` by `{kind, primitive token or stable type key, template args}`. `asCQualType` compares equal iff canonical type identity and mask match.

Runtime `asCDataType` / `asCTypeInfo*` / numeric typeId exist only behind `asCRuntimeTypeBridge` while the owning Engine is alive.

### Opaque IDs

Internal nodes live in context tables. Public and verifier IDs are 1-based indices (`0` invalid). IDs are snapshot-local. Foreign IDs from another context are verifier failures.

Clang uses pointers internally; we use table IDs internally as well so Cache DTOs, public V1, and Hot Reload leases share one numbering scheme and never leak arena addresses.

### Sealing

Mutable only while Sema owns the unsealed context. `Seal()` runs verifier; success freezes tables. Post-seal mutation returns `asEASTVerify_PostSealMutation`.

### Explicitly not copied from Clang

C++ templates/instantiation, PCH, Clang Modules, Objective-C, CUDA/OpenMP/HLSL, `Preprocessor` macro SLocEntries, `llvm::Value`, ORC, object cache, executable memory, public arena pointers.
