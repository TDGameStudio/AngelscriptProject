## Context

The current root-level `asCDecl`, `asCStmt`, `asCExpr`, and `asCType` are wide records with a kind and many mutually exclusive fields. `asASTIsa` checks only exact enum equality. This provides a compact implementation path for a previous canonical pipeline, but it does not make invalid payload combinations unrepresentable or give Parser/Sema/consumers typed APIs.

The approved reconstruction explicitly selects genuine Clang-informed node inheritance. The new hierarchy is isolated under `source/frontend/`; the legacy records are not modified into wrappers or maintained as a synchronized graph.

## Goals / Non-Goals

**Goals:**

- Define concrete and appropriately factored `Decl`, `Stmt`, `Expr`, `Type`, and `Attr` subclasses.
- Establish one taxonomy source per family and exhaustive casts/visitor/verifier support.
- Own nodes, strings, arrays, attributes, and source leases through one context lifetime.
- Unique canonical types while retaining authored type-location structure separately.
- Freeze the graph after construction/semantic completion and expose const reads/projections.
- Preserve exact source ranges and explicit recovery nodes without preprocessing duplication.
- Allow UE core types inside the same ThirdParty module while excluding live runtime publication state.

**Non-Goals:**

- Implement Parser grammar, declaration collection/resolution, or body Sema.
- Build bytecode, JIT IR, reflection descriptors, or live engine/UObject objects.
- Redefine stable type keys, preserve the old sidecar wire format, or expose a public binary AST ABI.
- Copy Clang's complete C++ taxonomy, source-location encoding, allocator internals, or serialization IDs.
- Retain a long-term wide-record, `asCScriptNode`, or sidecar shadow authority.

## Decisions

### Use the exact namespace and file boundary

Every new declaration is inside `BEGIN_AS_NAMESPACE` and lowercase `namespace frontend`. Files live under:

```text
ThirdParty/angelscript/source/frontend/
├─ as_ast_fwd.h
├─ as_ast_context.h / as_frontend_ast_context.cpp
├─ as_ast_cast.h
├─ as_ast_visitor.h
├─ as_decl.h / as_frontend_decl.cpp
├─ as_stmt.h / as_frontend_stmt.cpp
├─ as_expr.h / as_frontend_expr.cpp
├─ as_type.{h,cpp}
├─ as_type_loc.{h,cpp}
├─ as_attr.{h,cpp}
├─ as_ast_projection.{h,cpp}
├─ as_ast_codec.{h,cpp}
├─ as_ast_verifier.h / as_frontend_ast_verifier.cpp
├─ as_decl_nodes.def
├─ as_stmt_nodes.def
├─ as_type_nodes.def
└─ as_attr_nodes.def
```

Public headers and C++ declarations use final leaf names, not `V2` variants. Namespace isolation permits familiar names such as `frontend::asCDecl` without overwriting the dormant root-level class. UBT requires unique `.cpp` basenames within one module, so implementation units whose basenames collide with preserved root-level sources use the mechanical `as_frontend_*.cpp` prefix; this does not change the public API or semantic owner.

### Model four typed families with Expr in the Stmt lineage

The initial hierarchy shape is:

```text
asCDecl
├─ asCNamedDecl
│  ├─ asCTypeDecl
│  │  ├─ asCClassDecl / asCStructDecl / asCInterfaceDecl
│  │  ├─ asCEnumDecl
│  │  ├─ asCTypedefDecl
│  │  └─ asCFuncdefDecl
│  ├─ asCValueDecl
│  │  ├─ asCFunctionDecl / asCMethodDecl
│  │  ├─ asCVarDecl / asCPropertyDecl / asCParamDecl
│  │  └─ asCEnumConstantDecl
│  └─ asCNamespaceDecl
└─ asCTranslationUnitDecl / explicit recovery declarations

asCDeclContext (orthogonal ownership/lookup role)
└─ translation-unit / namespace / record / function contexts

asCStmt
├─ compound/control/decl/return/transfer statements
├─ explicit recovery statements
└─ asCValueStmt
   └─ asCExpr
      ├─ literal/reference/member expressions
      ├─ call/construct expressions
      ├─ unary/binary/conditional/assignment/conversion expressions
      └─ explicit recovery expressions

asCType
└─ builtin/nominal/generic/function/error types

asCQualType                     // compact value: canonical Type reference + legal qualifiers
asCTypeLoc / asCTypeSourceInfo  // authored spelling and component ranges

asCAttr
└─ concrete language/UE annotation syntax and normalized attribute kinds
```

Exact node inventory follows the accepted AngelScript grammar and semantic requirements when tasks implement the `.def` files. Leaf classes are `final` unless real shared behavior requires an intermediate base. A concrete class stores only its own payload and inherited common fields.

### Generate family mechanics from `.def` taxonomies

The `.def` files are simple checked-in X-macro taxonomies, not a new code generator or build-time dependency. They drive:

- kind enum and diagnostic spelling;
- forward declarations and base relationships;
- `classof` ranges or predicates;
- visitor dispatch and exhaustive kind lists;
- verifier and projection coverage tests.

`as_stmt_nodes.def` includes the Expr lineage so the `Stmt` kind space and child traversal preserve the inheritance relationship. Adding a node without updating the required construction/visitor/verifier cases fails compilation or focused tests.

### Use context-owned arena allocation and stable snapshot handles

`frontend::asCASTContext` owns arena blocks, interned strings, uniqued canonical types, node lists, attribute storage, and the immutable source snapshot lease. Concrete nodes use non-public or protected constructors and context factory methods. Node addresses remain stable until context destruction.

Inside the context, typed pointers are legitimate and efficient. Any cross-snapshot/public/persisted boundary uses owner-checked snapshot-local handles or an explicit projection; it never persists node pointers. One root artifact may hold `TSharedPtr<const frontend::asCASTContext>` or an equivalent lease. Nodes do not each hold a `TSharedPtr`.

The state boundary is:

```text
Building -> SemanticCompletion -> StructuralSeal -> ConstConsumption
```

This Change implements the context mechanics and structural seal. Later declaration/body Sema Changes own the actual semantic transitions and publication-level proof. A sealed context is not a runtime generation.

### Provide checked casts without requiring virtual RTTI

Each family base contains its compact kind. Concrete classes provide `classof`; `as_ast_cast.h` exposes `isa`, checked `cast`, and nullable `dyn_cast` equivalents. The implementation may remain non-polymorphic and arena-friendly; genuine inheritance does not require a virtual method on every node.

Unchecked `static_cast` is confined to cast-helper implementation after a successful kind/hierarchy test. Cross-family reinterpretation is forbidden.

### Separate owning child traversal from cross references

The canonical visitor traverses owning syntax/semantic children in documented order:

1. declaration attributes and owned declarations;
2. type/use edges required by that node;
3. statement/expression children in evaluation/source order;
4. node-specific trailing values.

Resolved declaration references, override relations, control-flow targets, and other non-owning edges are visited only through explicit hooks and do not recursively create cycles. A visitor can opt into types/attributes, but defaults are deterministic and exhaustively generated.

### Keep Type, QualType, and Attr roles distinct

Concrete `asCType` subclasses represent canonical semantic type forms and consume the preceding stable type identity contract. `asCQualType` is a compact value containing a canonical type reference plus legal qualifiers; it is not a node subclass. `asCTypeLoc` and `asCTypeSourceInfo` preserve authored spelling and component ranges independently, matching Clang's separation of semantic type from written type syntax. Ordered generic arguments are structural child type uses. Parameter direction, call transfer, and lifetime ownership are stored on their owning edges, not in general qualifiers.

ASTContext uniques equivalent canonical types so repeated construction returns one context-local object. This pointer equality is only an in-context optimization; cross-snapshot identity continues to use the canonical stable witnesses established by the identity Change.

Concrete `asCAttr` nodes preserve authored source range and typed arguments. Sema may attach normalized facts, but arbitrary string maps do not decide codegen or reflection semantics. Target-kind legality is verifier-owned. Cross-snapshot type identity comes from the preceding stable-identity contract; the AST adds typed semantic structure without becoming a second key producer.

### Keep source and preprocessing products separate

Source-backed nodes carry half-open UTF-8 ranges from the immutable source snapshot. They do not copy preprocessing IDs. Conditional context is obtained by range query against the sibling preprocessing result. Generated nodes without an honest authored range carry an explicit source-origin relation supplied by the source model.

### Use compact family storage deliberately

Common flags use bitfields where measurement and layout assertions show value. Variable-size node data uses context-owned trailing or inline payload rather than universal arrays on every base node. These are Clang-informed storage techniques, not permission to copy Clang's complete `TrailingObjects` implementation or assume one ABI layout. Focused size/allocation tests keep the optimization honest.

### Make projections read-only, versioned, and non-authoritative

`as_ast_projection` supplies narrow value projections for external/module consumers that cannot depend on internal node classes. A projection is derived from one sealed graph, preserves owner/generation identity, and cannot be written back. It must not recreate the old wide record as a mutable parallel AST.

`as_ast_codec` defines a new explicitly versioned, pointer-free flat representation for this hierarchy. Projection-local indices encode graph edges after bounds validation; stable source anchors and type/declaration witnesses encode cross-snapshot meaning. Decoding enforces count, byte, nesting, enum, index, and version budgets before exposing a complete result. Equivalent sealed graphs encode deterministically.

The codec intentionally does not read or reproduce the current Canonical AST Sidecar/Public View wire layout. An old or unknown version fails as incompatible without constructing a partial typed graph. A separately scoped future migration tool may translate old artifacts, but compatibility does not constrain the new in-memory object model.

## Compatibility and Migration

The new hierarchy is the only AST target for the reconstructed Parser and Sema. Existing root-level canonical files and `asCScriptNode` remain dormant reference inputs during the migration and are not updated in lockstep. Later declaration/body Changes begin producing the new nodes; later consumers migrate through typed traversal or projection.

The CQTest foundation, immutable source model, and stable type identity contract must be present before implementation starts. Declaration Sema, body Sema, and reflection/dependency output are downstream consumers and are not prerequisites for defining the hierarchy.

## Failure Modes and Verification

Structural seal rejects:

- a kind/class mismatch or node not allocated by the owning context;
- missing required payload or illegal attribute target;
- invalid/foreign source range or type use;
- duplicate owning edges, cycles in owning traversal, or foreign child nodes;
- a reachable recovery/error node from an accepted semantic root;
- invalid projection indices, unsupported codec versions, budget overflow, or pointer/runtime fields in serialized data;
- mutation after seal.

Diagnostics identify the concrete node kind, source range when available, and violated invariant. Verification never fills missing facts or consults live runtime state.

## Risks / Trade-offs

- More classes and files increase taxonomy maintenance. `.def`-driven mechanics and exhaustive tests make the cost visible and bounded.
- Inheritance plus arena allocation can produce subtle destruction rules. Arena-owned payload must use context-managed cleanup for non-trivial UE containers, with lifetime tests covering release.
- Internal typed pointers are not stable serialization handles. Projections and the preceding stable identity contract keep those domains separate.
- A new codec creates an explicit compatibility break with the current wide-record sidecar. Failing closed is intentional; implicit layout compatibility would preserve the architecture being replaced.
- UE containers simplify same-module development but may inflate nodes if used indiscriminately. Concrete per-kind payloads and later measurement avoid the current universal wide-record cost.
- Cross-Change prerequisites cannot appear in the local DAG; the coordinator gates Task 1.1 explicitly.

## Rejected Alternatives

- Rename the current wide records and continue treating `kind + optional fields` as a genuine typed hierarchy.
- Add only typed facade/view wrappers while retaining a mutable wide record as the new frontend authority.
- Keep `asCScriptNode`, a generic IR/sidecar, and the typed AST as permanently synchronized semantic graphs.
- Copy all of Clang's C++ node taxonomy, virtual behavior, trailing-storage patterns, TableGen pipeline, or serialization format.
- Persist node pointers, `FName` indices, raw source encodings, or context-local IDs without an owning snapshot.
- Put preprocessing trees, runtime IDs, engine pointers, or UObject references in ordinary AST nodes.
- Add `V2` suffixes or an uppercase `Frontend` namespace that would preserve ambiguous duplicate naming.
