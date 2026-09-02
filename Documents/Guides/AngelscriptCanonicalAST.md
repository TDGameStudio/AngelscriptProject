# Canonical typed AST

Chinese version: [AngelscriptCanonicalAST_ZH.md](AngelscriptCanonicalAST_ZH.md)

This is the embedding and product migration note for the canonical Parser / Sema /
sealed-AST compiler pipeline. The source lineage and fork policy remain in
`AngelscriptForkStrategy.md`. LLVM and Clang are architecture references only;
production and Standalone do not link, include, or copy `llvm::` or Clang AST types.

## Pipeline

New engines currently default to `asCOMPILER_PIPELINE_LEGACY`. An embedding client may
select `asCOMPILER_PIPELINE_CANONICAL` explicitly before compiling. For a CANONICAL
module build, Parser actions populate Sema, Sema seals and verifies the Canonical AST,
and `asCBytecodeCodeGen::Generate()` publishes Bytecode from that same graph. A
CANONICAL `CompileFunction` uses an ephemeral sealed function-closure AST and
`GenerateFunction()`. Unsupported Canonical forms fail closed; they do not silently
fall back to `asCCompiler` or merge LEGACY facts. There is no production `dual` mode.

The target frontend is Clang-shaped without an LLVM dependency:

```text
SourceManager → Parser typed actions → Sema scopes/types/calls/lifetimes
              → interned QualType AST → verifier seal
              → detached Bytecode artifact or direct TypedASTJIT/AOT visitor
```

- Public AST V1 exposes snapshot-owned opaque IDs plus capacity-negotiated POD views.
  Concrete nodes, the mutable ASTContext, Engine pointers, Runtime TypeIds, and
  generation-local bindings remain private.
- The native AngelScript Parser tree, Builder, and compiler remain available for
  syntax/recovery, explicit LEGACY comparison, differential tests, and rollback. They
  are not a CANONICAL backend transport.
- HIR has been physically removed. AST dumps and diagnostics are observers only; no
  dump, HIR replay, or serialized text is an AST-to-Bytecode/AOT transport.
- `SaveByteCode()` and VM `FunctionBody` archives contain executable Bytecode, not AST
  bytes. Optional Cache V2 `ASTBodySidecar` records are a separate pointer-free
  snapshot DTO boundary.

Use `asCModule::GetLastBytecodePublisher()` in maintained-fork diagnostics/tests when
publisher proof is required. A selected pipeline flag by itself is not proof that a
particular generation was published by that backend.

TypedASTJIT consumes a retained sealed AST snapshot directly. Matching-profile
generation leases the primary compiled graph and does not build a dump/HIR sibling
compiler pipeline.

## Public API V1 contract

| Area | Contract |
| --- | --- |
| Header / product version | Compile against the plugin's current `angelscript.h`. The product version is `Unreal AngelScript 1.0.0` (`10000`); a vanilla `23300` header is not this public ABI. |
| ABI placement | The three module AST methods are trailing `asIScriptModule` virtual slots, preserving the positions of pre-existing product 1.0.0 methods. Concrete node classes are not public ABI. |
| Policy timing | Call `SetASTRetentionPolicy()` before the first `Build()`. The default is `asAST_DISCARD_AFTER_CODEGEN`; policy freezes when the build starts, and an in-place post-build change returns `asNOT_SUPPORTED`. |
| Retain | `asAST_RETAIN_SNAPSHOT` publishes only a sealed, verified snapshot after a successful complete source build. Discard policy releases the construction graph after CodeGen. |
| Acquire / null | `AcquireASTSnapshot(asAST_API_VERSION_1)` returns one retained lease or null. Null is normal for discard policy, no successful retained/restored generation, unsupported API version, or a generation retired because it no longer describes the module. |
| Lease | Every non-null snapshot is already AddRef'd for the caller. Always call `Release()`. View strings and opaque IDs are valid only while that exact lease is held. A lease may outlive module discard. |
| Current generation | `IsCurrentGeneration()` is true only for the latest successful complete publication. Successful replacement makes an old held lease non-current but still traversable. Failed replacement preserves the previous generation as current. |
| View negotiation | Zero-initialize a view, set `structSize` to the caller's writable capacity, and set `apiVersion` to zero (V1 convenience) or `asAST_API_VERSION_1`. An unsupported non-zero version or undersized required prefix fails without overwriting caller bytes. V1 extensions are append-only. |
| Opaque IDs | IDs are snapshot-owned, not globally stable. Passing an ID from another snapshot fails closed. Persist complete stable keys/source identity instead of numeric IDs, pointers, or `asASTTypeRef` values. |
| `CompileFunction` | CANONICAL compilation uses an ephemeral sealed AST complete only for that function closure. Detached success leaves the module snapshot unchanged. Successful `asCOMP_ADD_TO_MODULE` changes the module declaration set and therefore retires the old snapshot without publishing an incomplete replacement. Failure preserves the prior executable/snapshot generation. A later complete `Build()` may publish a new snapshot. |
| Cache / `SaveByteCode` | `SaveByteCode()` is a VM-bytecode boundary, not an AST archive. Cache V2 AST sidecars are optional, pointer-free, content/profile checked, and published only under retain policy after restore validation. Do not infer AST availability from successful bytecode load alone. |

`GetCompilerPipeline()` / `SetCompilerPipeline()` are maintained-fork Engine APIs, not
a second AST ABI. Unknown and dual values are rejected and leave the selected pipeline
unchanged. The product default remains LEGACY until the complete OpenSpec cutover gate
is green; LEGACY remains an explicit rollback selection after that transition.

## Embedding-client migration checklist

1. Rebuild the embedding client against the current plugin `angelscript.h`; do not
   combine the V1 interfaces with vanilla 2.33 headers or a separately distributed
   incomplete/pre-release AST header.
2. Treat compiler selection and AST retention as independent choices. Select
   CANONICAL explicitly only when desired, then set retention before `Build()`.
3. Handle `Build()` failure before acquisition. Treat a null snapshot as a supported
   state, not as permission to inspect a private ASTContext or replay a dump.
4. For every `Get*View`, provide the caller's real `structSize` and requested V1
   version. Read only fields within that capacity, and keep the lease alive while
   using returned strings or child/source IDs.
5. Use stable declaration/type/source identities for stored tooling data. Never store
   snapshot-local IDs, Runtime TypeIds, node addresses, or view string pointers across
   lease, Engine, Hot Reload, Cache, or process boundaries.
6. On Hot Reload or rebuild, acquire a fresh lease when current data is required.
   Existing leases remain safe historical generations; check `IsCurrentGeneration()`
   instead of comparing pointers.
7. After `CompileFunction(asCOMP_ADD_TO_MODULE)`, expect acquisition to return null
   until a complete retained `Build()` republishes the module. Detached compilation
   does not have this effect.
8. Keep AST tooling separate from `SaveByteCode()`, Cache executable records, StaticJIT
   Provider ABI, and Runtime binding tables. Exchange only their documented stable,
   pointer-free identities.
9. Release every acquired snapshot exactly once. Do not cache a module-owned raw
   implementation pointer as a substitute for a lease.

The AST V1 surface was developed inside product 1.0.0. If an external binary was built
against an older incomplete V1 header that placed methods differently, rebuild it
against the current header; this document does not claim binary compatibility with an
unreleased or separately distributed broken layout.

## Retained native compiler boundary

`asCScriptNode`, the native Parser tree, `asCBuilder`, and `asCCompiler` are intentionally
retained for grammar coverage, recovery, explicit LEGACY operation, comparison, and
rollback. Their later physical removal is a separate OpenSpec. HIR is not retained.
CANONICAL Sema and its backends consume typed actions and the sealed AST directly.

## Dumps and diagnostics

State dump and developer AST diagnostics are read-only observers. They are never Cache,
Provider, Bytecode, or AOT inputs and do not take ownership of AST, Sema, CodeGen,
Runtime, or Editor objects.
