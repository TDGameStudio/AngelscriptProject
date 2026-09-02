# Read-only canonical AST diagnostics gate (2026-08-23)

## Purpose

Task 2.13 turns the Clang-inspired inspection work from internal helper APIs
into a host-neutral developer surface.  The surface is deliberately narrower
than Clang tooling: it provides deterministic `list`, filtered `dump`,
`verify`, exact `query`, and semantic `diff` operations over an already
retained canonical AST snapshot.  It is not a rewriter, serializer, Cache V2
input, or alternate compiler entry point.

## AST-first gate card

- **Task:** 2.13 read-only developer/commandlet diagnostics.
- **Source fixture:** two retained modules containing `int F() { return 42; }`
  and `int F() { return 43; }`, plus one discard-policy module.
- **AST-red tests:**
  - `FCanonicalASTDiagnosticsTests::ReadOnlyOperationsBalanceSnapshotLeasesAndExposeStableMetadata`
  - `FCanonicalASTDiagnosticsTests::FilteredDumpQueryVerifyAndDiffRemainMutationFree`
  - `FAngelscriptASTDiagnosticsRuntimeTests::RuntimeParserRejectsMutationAndRegistersDeveloperCommand`
  - `AngelscriptStandalone.CanonicalAST` diagnostic assertions.
- **Required sealed/public facts:** every successful operation obtains the V1
  snapshot from the module, observes a sealed context, identifies module,
  generation, current-generation state, and source/cache provenance, releases
  the operation-owned lease, and leaves the flat AST dump byte-identical.
  Query must return only exact matches; dump may retain structural closure.
  Diff must report the first deterministic semantic path.  Text and JSON must
  state `diagnosticOnly=true`, `cacheInput=false`, `readOnly=true`, and
  `mutation=refused` and contain neither addresses nor Engine-local IDs.
- **AST-red:** confirmed.  Runtime build
  `Saved/Build/cta-ast-diagnostics-red/20260823_220155_050_1e3456fe/RunMetadata.json`
  fails at the new test's first missing production surface,
  `Dump/AngelscriptASTDiagnostics.h`.  The common
  `as_ast_diagnostics.h`/`asCASTRunDiagnostics` surface is likewise absent;
  no production implementation existed at this point.
- **AST-green:** complete.  The common service supports all five operations;
  exact query does not include filtered-dump closure, repeated output is byte
  deterministic, and every operation emits valid JSON as well as text.
- **CodeGen/provenance-green:** not a CodeGen slice.  Required publisher fact
  is instead that diagnostics consume only the module's retained immutable
  snapshot; source-build and Cache V2 restore provenance are snapshot-owned
  diagnostic metadata and do not enter semantic identity.
- **Lifecycle-green:** complete.  An anchor lease observes the same internal
  reference count after each text and JSON operation; pre/post flat dumps are
  byte-identical.  A discard-policy module returns
  `retained-snapshot-unavailable` instead of borrowing the pending/raw
  context.  Existing old-generation/concurrent-acquire Snapshot tests remain
  9/9 green.
- **Focused-regression-green:** complete.  See the evidence below.

## Design boundary

The maintained standard-C++ layer owns request execution so Standalone and UE
produce compatible output.  UE Runtime owns argument parsing and the
`as.AST` developer console command.  An Editor commandlet may reuse that
Runtime parser; it must not gain direct mutable compiler access.  Public AST V1
stays unchanged: provenance and lease-balance observability remain internal
implementation/test details rather than new public ABI fields.

`DOT` remains reserved for the later typed-CFG tool described by `design.md`.
When added it must use the same diagnostic-only envelope.  Task 2.13 does not
invent an AST-DOT format or use a graph dump as Cache content.

## Implemented surfaces

The host-neutral layer is `as_ast_diagnostics.h/.cpp`.  It enumerates modules
through `asIScriptEngine`, finds exact module names without creating modules,
and always enters the internal sealed context through an acquired
`asIASTSnapshot` V1 lease.  `list` attempts a lease for every module and
reports unavailable retention explicitly; all other operations fail closed if
the requested retained snapshot is absent.

Every retained snapshot reports:

- module name and generation key;
- `source-build` or `cache-v2-restore` provenance;
- current-generation state;
- Decl/Type/Stmt/Expr counts;
- the command envelope's `diagnosticOnly=true`, `cacheInput=false`,
  `readOnly=true`, `mutation=refused`, and `lease=acquired-released` facts.

`dump` uses the 2.10 structural-closure filter.  `query` scans the same stable
node order but returns only exact matches.  `verify` calls the publication
verifier.  `diff` acquires both modules concurrently and invokes the 2.12 full
Source/Type/Decl/Stmt/Expr first-mismatch comparison.  JSON wraps the existing
structured payload in a valid command envelope rather than prefixing text to
JSON.

UE Runtime exposes:

```text
as.AST list [--json]
as.AST dump <module> [--json] [--key=...] [--node=D1] [--kind=...] [--source=...] [--snippets]
as.AST verify <module> [--json]
as.AST query <module> (--key=... | --node=D1 | --kind=... | --source=...) [--json]
as.AST diff <left-module> <right-module> [--json]
```

The Editor commandlet uses the same parser and adds only optional UTF-8 file
publication:

```powershell
Tools\RunCommandlet.ps1 `
  -Commandlet AngelscriptASTDiagnostics `
  -ExtraArgs list
```

Direct Unreal commandlet arguments may also add `-output=<path>`.  The output
file remains a diagnostic artifact; no Cache reader or compiler API accepts
it.  Unsupported verbs such as `mutate` or `rewrite`, unknown switches, a
query without a predicate, missing modules, and modules without retention all
fail closed.

## Verification evidence

- Expected missing-surface RED:
  `Saved/Build/cta-ast-diagnostics-red/20260823_220155_050_1e3456fe/RunMetadata.json`.
- Final Runtime/Editor build after JSON and commandlet publication support:
  `Saved/Build/cta-ast-diagnostics-json-commandlet-build/20260823_221836_841_803b72b9/RunMetadata.json` — exit 0.
- Focused Runtime integration, balanced leases, mutation-free graph, exact
  query, all-operation valid JSON, parser and console registration:
  `Saved/Tests/cta-ast-diagnostics-json-focused/20260823_221900_126_99ac9048/RunMetadata.json` — **3/3 PASS**.
- Public snapshot lifecycle/concurrency regressions:
  `Saved/Tests/cta-ast-diagnostics-snapshot/20260823_221229_244_6bd879f7/RunMetadata.json` — **9/9 PASS**.
- Cache V2 ExactWarm including restored provenance and diagnostic verify:
  `Saved/Tests/cta-ast-diagnostics-cache-exact-rerun/20260823_221310_198_b1bf7c45/RunMetadata.json` — **15/15 PASS**.
- Standalone compilation and complete CTest suite, including host-neutral
  list/query and lease balance:
  `Saved/StandaloneTests/cta-ast-diagnostics-standalone_01_Standalone/20260823_221535_824_3385b6a5/RunMetadata.json` — **21/21 PASS**.
- Real Editor commandlet `list` invocation:
  `Saved/Commandlet/cta-ast-diagnostics-commandlet-list-rerun/20260823_222059_389_7c68226f/RunMetadata.json` — exit 0.  The normal project modules use discard retention and are therefore truthfully listed with `provenance=unavailable`; retained source/cache fixtures are covered by the focused tests above.

An earlier commandlet attempt accidentally bound the trailing `list` token to
the PowerShell runner's `OutputRoot`, so the commandlet correctly rejected an
empty operation.  It is not green evidence; the explicit `-ExtraArgs list`
rerun above is the recorded result.
