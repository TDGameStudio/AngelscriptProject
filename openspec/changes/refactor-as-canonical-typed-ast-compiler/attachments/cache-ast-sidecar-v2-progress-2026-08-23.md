# Cache ASTBodySidecar V2 progress — 2026-08-23

## Scope of this increment

This increment closes the false DTO boundary that review R04 identified and
finishes the first end-to-end Cache V2 vertical for a module containing global
functions.  A retained Canonical AST can now survive a cold capture and an
Exact Startup restore without Parser, Sema, or bytecode CodeGen work.  This is
not a replacement for the VM cache: the VM `FunctionBody` record remains the
only executable cache payload.

## What changed

`asCASTEncodeSidecar` / `asCASTDecodeSidecar` now use schema V2, a
pointer-free graph DTO rather than V1's textual AST dump plus declaration
skeleton:

```
source sections ─┐
interned types   ├─> declarations ─> statements / expressions / references
stable identity  ┘                         │
                                         source ranges
```

The payload serializes source identity and bytes, primitive/type identities,
declarations, source ranges, declaration relationships, statement graphs,
expression graphs, literals, dependencies, default arguments, and target
profile/function-key identity.  Decode creates a fresh `asCASTContext`,
rebuilds the graph by IDs local to that context, seals/verifies it, and resets
the temporary context on any failure.  A V1 payload is a safe miss.

The per-function sidecar fingerprint now includes the target profile and the
semantic closure of the function body, rather than just declaration fields.
Changing `return 7` to `return 8`, or changing the target profile, changes the
record identity.

The UE wrapper is now a strict persistence boundary:

```
caller V2 DTO
    │  decode + seal + verify against FunctionKey/Profile
    ├── failure ──> no output bytes published
    └── success ──> byte-for-byte same V2 DTO in the Cache record
```

It no longer accepts an arbitrary non-empty `CanonicalAstBytes` placeholder
and replaces it with a newly made empty translation unit.

## Cache V2 integration and Exact Startup policy

`ASTBodySidecar` is now an ordinary Cache V2 content-addressed record.  Its
link is optional in `FAngelscriptCachedFunctionBody` schema V2, so an existing
or V1 cache is a safe miss rather than a migration hazard.  When a sealed
Canonical AST is explicitly requested at capture time, every function body in
the module links to the same full-module sidecar record:

```text
SourceIndex --> ModuleInterface / TypeSchema / ModuleState --> FunctionBody (VM execution)
      |                                                          |
      |                                                          +--> DebugSidecar (optional)
      |                                                          +--> ASTBodySidecar (one module DTO)
      +----------------------------------------------------------> ModuleSnapshot
```

The manifest/module-graph validation checks that every linked target is an
`ASTBodySidecar`, that its content hash is non-zero, and that all function
bodies of a retained module use one identical record.  This makes a mixed or
partially linked module a safe Cache V2 miss before it can mutate the target
engine.

Exact Startup has two deliberately distinct policies:

| Consumer AST policy | Cache work | Result |
| --- | --- | --- |
| `discard` (default) | Validates the bounded record envelope, content hash, V2 header, and graph link, but does not reconstruct/adopt/publish the AST DTO | The normal VM-only zero-frontend restore remains unchanged. |
| `retain snapshot` | Strictly verifies owner key, target profile, schema, hash, and decoded/sealed DTO; adopts it into the staging module | Publishes one immutable `asIASTSnapshot` only after the whole restore batch is validated. |

The retained path decodes into a new `asCASTContext`, validates the owner as
`module:<ModuleKeyHash>` and the profile as `profile:<TargetProfileHash>`, then
adopts the context only into a staging `asCModule`.  Publication happens before
the final module-map swap; any invalid/missing/mixed sidecar or snapshot
publication failure discards the staging batch.  An AST is therefore never
partially published into a live engine, and the last good snapshot remains
untouched.

The sidecar is still outside `SaveByteCode` / `LoadByteCode`; no VM bytecode
archive format or execution ABI was changed.

This split is intentional: optional AST retention must not add graph
materialization cost to the common VM-only warm path.  Cache admission still
does bounded structural work (record hash/kind/length, V2 magic/version,
owner/profile header, and FunctionBody link), while a truncated or semantically
invalid body is strictly rejected before it can be adopted when `retain
snapshot` is requested.

## Evidence

Red tests established the missing behavior first:

- Complete source/function/return/literal V2 round-trip initially failed,
  because V1 restore had zero source sections and declaration skeletons only.
- The runtime wrapper test initially accepted `{1}` and regenerated a distinct
  empty DTO.

Green verification after implementation:

```text
Build: Saved/Build/cta-cache-sidecar-dto-green-build/
       20260823_084254_975_c673bfb8/RunMetadata.json
       AngelscriptProjectEditor Win64 Development: PASS

Test:  Saved/Tests/cta-cache-sidecar-dto-green-bucket/
       20260823_084420_397_eb86be77/RunMetadata.json
       Angelscript.TestModule.Cache.ASTBodySidecar: 9/9 PASS

Build: Saved/Build/cta-cache-runtime-wrapper-green-build/
       20260823_084650_196_4d272478/RunMetadata.json
       AngelscriptProjectEditor Win64 Development: PASS

Test:  Saved/Tests/cta-cache-runtime-wrapper-green/
       20260823_084705_775_39f6adba/RunMetadata.json
       Angelscript.TestModule.Cache.ASTBodySidecar: 9/9 PASS

Build: Saved/Build/build/
       20260823_091359_975_d73230d7/RunMetadata.json
       AngelscriptProjectEditor Win64 Development: PASS (167/167 actions)

Test:  Saved/Tests/cta-cache-retained-ast-restore-green/
       20260823_091915_281_916ff4c1/RunMetadata.json
       Angelscript.TestModule.Cache.ExactWarmStartup: 6/6 PASS

Build: Saved/Build/build/
       20260823_092627_734_007db059/RunMetadata.json
       AngelscriptProjectEditor Win64 Development: PASS (37/37 actions)

Test:  Saved/Tests/cta-cache-ast-lazy-admission-green/
       20260823_092749_553_37258947/RunMetadata.json
       Angelscript.TestModule.Cache.ASTBodySidecar: 10/10 PASS

Test:  Saved/Tests/cta-cache-ast-lazy-exact-warm-green/
       20260823_092843_925_92a9444f/RunMetadata.json
       Angelscript.TestModule.Cache.ExactWarmStartup: 6/6 PASS

Build: Saved/Build/build/
       20260823_093452_468_4cf404ff/RunMetadata.json
       AngelscriptProjectEditor Win64 Development: PASS (4/4 actions)

Test:  Saved/Tests/cta-cache-root-ast-sidecar-green/
       20260823_093512_194_515a3719/RunMetadata.json
       Angelscript.TestModule.Cache.RootClassRestore: 1/1 PASS
       14/14 graph records; one ASTBodySidecar; restored reflected call = 42

Build: Saved/Build/build/
       20260823_093626_392_0de85475/RunMetadata.json
       AngelscriptProjectEditor Win64 Development: PASS (4/4 actions)

Test:  Saved/Tests/cta-cache-classgraph-ast-sidecar-green/
       20260823_093754_115_5aa3b4af/RunMetadata.json
       Angelscript.TestModule.Cache.ClassGraphInheritanceRestore: 1/1 PASS
       36/36 graph records; one ASTBodySidecar; restored 3 types, 14 functions,
       VFT owners, overrides, and super calls

Build: Saved/Build/cta-cache-complex-ast-publish-build-fix-support/
       20260823_094505_896_b4f8a526/RunMetadata.json
       AngelscriptProjectEditor Win64 Development: PASS (28/28 actions)

Test:  Saved/Tests/cta-cache-root-ast-publish-green/
       20260823_094603_944_e96c903a/RunMetadata.json
       Angelscript.TestModule.Cache.RootClassRestore: 1/1 PASS
       retain-snapshot consumer: restored 1 type / 4 functions and acquired
       a non-null immutable Canonical AST snapshot

Test:  Saved/Tests/cta-cache-classgraph-ast-publish-green/
       20260823_094652_635_5b3c4375/RunMetadata.json
       Angelscript.TestModule.Cache.ClassGraphInheritanceRestore: 1/1 PASS
       retain-snapshot consumer: restored 3 types / 14 functions, VFT override
       and super-call behavior, and acquired a non-null immutable AST snapshot

Build: Saved/Build/cta-canonical-member-init-green-build/
       20260823_095119_181_189743e1/RunMetadata.json
       AngelscriptProjectEditor Win64 Development: PASS (4/4 actions)

Test:  Saved/Tests/cta-canonical-member-init-red/
       20260823_095012_748_c32360dd/RunMetadata.json
       Angelscript.TestModule.Cache.RootClassRestore: 0/1 (expected red)
       class `int Value = 37` failed in legacy ParseVarInit at the RHS token:
       expected `=` or `(`, found integer constant

Test:  Saved/Tests/cta-canonical-member-init-green/
       20260823_095130_787_0eb275f9/RunMetadata.json
       Angelscript.TestModule.Cache.RootClassRestore: 1/1 PASS
       initialized reflected member, VM restore, reflected call = 42, and
       retained immutable Canonical AST snapshot all verified together

The final exact-warm test generated eight pointer-free Cache V2 records
(previous VM-only vertical: seven), restored the executable `Answer()` body,
and acquired a non-null immutable `asIASTSnapshot` when the consumer asked to
retain it.  The existing default-policy exact-warm test continued to prove zero
frontend work and no cache-store publication; it now also explicitly asserts
that the AST snapshot is absent under `discard`.
```

## Broader module-shape capture

The capture boundary is now shared by all three established clean-capture
verticals rather than being a special case of global functions:

```text
global-function module ─┐
root reflected class    ├─> one sealed Canonical AST context
class inheritance graph ┘        │
                                  └─> one ASTBodySidecar record
                                      linked from every FunctionBody
```

The sidecar is emitted only when the source compilation retained a sealed
Canonical AST.  The record is content addressed once per module; it is not
duplicated once per function.  The existing graph validator proves that all
function bodies in that module point to the same valid `ASTBodySidecar` record,
so the capture cannot publish a partly linked class graph.

This gives Cache V2 a complete capture model for the current global-function,
root-class, and base-before-derived class-graph paths.  It does **not** make
Canonical AST the execution authority: their `FunctionBody` VM bytecode is
still restored and executed exactly as before.

The generic RestoreBatch implementation is already shape-independent at the
snapshot boundary.  When the consumer requests `retain snapshot`, it strictly
decodes the one linked sidecar, adopts it into the private staging module, and
publishes the snapshot before the sole module-map swap.  Consequently the
same transactional adoption/publication mechanism is available for the root
and class-graph shapes; it is not a global-function-only branch.  The
global-function fixture remains the proof for the top-level Exact Startup entry
point.  Root-class and class-graph regression tests now additionally prove the
same strict decode/adopt/publish transaction through the generic
`RestoreAngelscriptCacheModule` entry point.

The root-class test now deliberately keeps `UPROPERTY() int Value = 37` and a
method that reads it.  It exposed a transition-boundary defect: canonical
parsing consumed `=` before constructing the full RHS expression, while the
still-active legacy compiler later reparsed the same initializer node starting
at that node's recorded source offset and therefore saw `37` where it required
`=`.  The parser now anchors the fully parsed initializer node at the `=` token.
Canonical Sema retains the complete RHS; legacy `ParseVarInit` receives its
established input contract.  This is a bridge fix, not a change to member
initialization semantics or Cache V2 persistence.

## Still deliberately open

The global-function Exact Startup fixture, root-class restore fixture, and
three-level class-graph restore fixture now all execute strict sidecar decode,
staging-module AST adoption, and immutable snapshot publication.  The latter
two use the generic restore API rather than the outer Exact Startup coordinator;
that distinction is deliberate and documented by the tests.

While enabling those regressions, the test module exposed an incomplete common
test-support refactor.  `ENativeEvidence` / `AS_NATIVE_PRODUCT*` were defined
in case support while many Core-support clients did not receive that contract;
the generic `PrintGeneratedAsSource` helper also lived in language-only
support.  The contract and generic logging helper are now owned by Core
support, preserving the language helper as a higher-level dependency.  The
full target build passed afterwards; this is a test-infrastructure ownership
correction, not a Cache V2 format or execution-path change.

Still required:

- extend transactional retained-AST restore coverage to imports and other
  module shapes;
- negative corruption coverage that proves an owner/profile mismatch is a
  safe miss;
- incremental rematerialization and cross-engine adapter coverage;
- further canonical Parser/Sema coverage for the remaining supported legacy
  syntax beyond the repaired class-member initializer bridge;
- the later CodeGen cutover that makes Canonical AST, rather than
  `asCScriptNode`, the production semantic/code-generation authority.

Those follow-up tasks do not weaken the strict format or transactional restore
boundary established here.

## Capture lifetime gate（2026-08-23）

Cache Clean Capture 的 `TryCaptureCanonicalASTBodySidecar()` 已不再借用
`asCModule::GetCanonicalASTContext()` 返回的裸指针。它现在取得并持有 Public AST V1 snapshot
lease，再从 `asCASTSnapshot` 获得 context，直到 Sidecar 编码和记录验证全部完成才释放。这样
与 Cache Restore 的 staging/adopt/publish 原子性相对应：capture 也不会越过 generation
publication 边界读取一个无所有者的旧 context。

这不改变“仅 retained sealed AST 才输出 Sidecar”的语义；`AcquireASTSnapshot()` 为 null 仍是
normal absence，Cache 只保留 VM 记录。它也不让 Cache 执行 AST：FunctionBody 的 VM bytecode
仍是执行权威。

该消费者约束由 Standalone 架构测试锁定，并已通过 Runtime 编译、Standalone **21/21** 和
`Cache.ASTBodySidecar + Cache.ExactWarmStartup` **16/16** 运行时回归。完整证据和红灯步骤见
`snapshot-publication-protocol-audit-2026-08-23.md`。
