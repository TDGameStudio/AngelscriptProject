# Canonical parameter typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-18 — ordinary callable parameter identity/type/direction/range before default parsing |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Semantic fixture | `int F(const int &in A = 40 + )` fails in the default expression after the complete parameter header |
| Construction/sealed-AST assertion | before the later default-expression failure, one exact `ParamDecl` named `A` exists under `F`, has canonical `const int&in`, and owns the exact half-open authored header range; it has no fabricated default init |
| Architecture assertion | `ParseParameterList` publishes `asSParameterDeclAction` with an explicit callable DeclId and calls a separately named default-expression adapter only after a complete default; the four-Parser-node `ActOnParsedParam` tuple is deleted |
| Expected RED | current Parser waits until default parsing succeeds before calling `ActOnParsedParam(typeNode, typeMod, nameNode, defaultNode, script)`, so `A` disappears on the malformed default and the source scan finds the node tuple instead of a typed action |
| Production edit allowed after RED | pointer-free action/API, explicit-owner validation, Parser publication before default parsing, named default adapter, ordinary/import/interface/funcdef call-site routing and obsolete tuple deletion |

## Locked design

1. Add `asSParameterDeclAction` containing only explicit callable DeclId,
   authored name, already-resolved `asCQualType`, and exact half-open offsets.
   No `asCScriptNode*`, Runtime pointer or numeric Runtime TypeId crosses it.
2. `ParseParameterList` accepts the exact callable DeclId created by the
   function/import/interface/funcdef signature action. LEGACY/no-Sema callers
   may pass an invalid default value; Canonical parsing must never recover an
   owner through `lastActedDecl`.
3. Publish the parameter immediately after its type/modifier/optional name are
   complete and before parsing an optional default expression. A later default
   syntax error therefore cannot erase the parameter header.
4. Sema validates the owner kind, local type identity and SourceManager range,
   creates the exact ParamDecl, and records named-type dependency on the
   callable. Callable kinds are function, method, constructor, destructor,
   mixin, import and funcdef.
5. Default parsing remains a separately named transitional expression-family
   adapter in this slice. It receives the exact Param DeclId and a completed
   default expression node; missing/failed defaults do not synthesize an init.
6. Lambda parameters still use the explicitly named lambda replay boundary
   until the lambda action slice. Generated lifecycle/accessor parameters keep
   their direct Sema construction route.

## Removed virtual-property scope reconciliation

The task ledger still uses historical wording that includes virtual
properties. The maintained fork has already removed authored virtual-property
syntax: `ParseVirtualPropertyDecl()` emits `TXT_VIRTUAL_PROPERTY_REMOVED` and
returns null, Builder `RegisterVirtualProperty` is documented unreachable, and
production Sema has no `snVirtualProperty` case or `ActOnPropertyDecl` caller.
CTA-S-18 must preserve that rejection boundary; it must not restore the deleted
syntax merely to satisfy stale umbrella wording. The remaining live property
work is registered accessor call rewriting/metadata and generated backing-field
accessors, which are separate CodeGen/Runtime gates.

## Required evidence

1. add the behavior and architecture tests before production edits;
2. test-only Runtime/Editor build;
3. valid owning-suite RED proving both the lost early parameter and obsolete
   Parser-node tuple;
4. production repair and Runtime/Editor build;
5. focused CTA-S-18 plus complete SemaAuthority GREEN;
6. ProductionCodeGen and Parser declarations GREEN;
7. default/named-argument and import/interface/funcdef boundary regressions as
   applicable;
8. strict OpenSpec validation plus parent/plugin `git diff --check`;
9. record RED, failures, root causes, corrections, evidence and non-claims in
   the final issue/execution/task/progress ledgers.

## Mutation checks

Permanent tests must fail if a future change:

- delays ParamDecl publication until a default expression or closing `)`;
- derives the owner from `lastActedDecl` instead of the exact callable action;
- loses const/reference/in/out/inout qualifiers or source range;
- reintroduces the four-node `ActOnParsedParam` semantic tuple;
- creates a fake default init after default parsing failed;
- restores deleted authored virtual-property syntax as part of this migration.

## Non-claims

- General `ActOnQualTypeFromNode` and type/template/name resolution remain
  transitional and belong to Task 4.3.
- Default expression decoding still uses a named Parser-node adapter; complete
  default/named-argument validation remains open.
- Lambda/list-pattern/body/expression/statement/lifetime actions remain open.
- This does not prove complete detached Runtime registration, CodeGen metadata,
  HIR retirement or production-entry/default cutover.
- Compiler default remains LEGACY and Cache V2 remains default-disabled.

## TDD and implementation result

Status: **resolved bounded slice**. This closes ordinary callable parameter
header publication only; the non-claims above remain open.

### RED established before production

Two permanent tests were added first:

- `ParserParameterHeaderSurvivesMalformedDefaultBeforeClose` uses
  `int F(const int &in A = 40 + )` and requires the exact `A` declaration,
  owner, qualified type and half-open range to survive the later malformed
  default without a fabricated init;
- `ParserParameterListUsesTypedActionWithoutParsedNodeTuple` requires the
  pointer-free parameter action, the separately named default adapter and the
  physical absence of `ActOnParsedParam`.

The test-only Runtime/Editor build passed at
`Saved/Build/cta-parameter-typed-action-red-test-build/20260827_142027_896_3c176d98/RunMetadata.json`.
The complete owning suite then produced the intended **329/331 PASS, 2 FAIL**
at
`Saved/Tests/cta-parameter-typed-action-red/20260827_142049_419_75f5ca58/RunMetadata.json`.
Both failures were the new tests: the old implementation waited for a complete
default and called the four-node
`ActOnParsedParam(typeNode, typeMod, nameNode, defaultNode, script)`, so the
otherwise complete parameter header disappeared when the default failed.

### Production repair

`asSParameterDeclAction` now carries the exact callable DeclId, canonical
qualified type, optional authored name and exact offsets. `ParseParameterList`
receives the callable created by the import, funcdef, ordinary-function or
interface-method signature action and publishes the parameter immediately
after its complete header. Sema validates the callable kind, type and range,
creates the exact ParamDecl and records the named-type dependency. A complete
default is attached later only through
`ActOnParameterDefaultFromNode(parameterDecl, ...)`; a failed/missing default
does not invent one. The old `ActOnParsedParam` API and its `lastActedDecl`
owner fallback are deleted. Lambda parameters deliberately retain their named
walker boundary until the lambda slice.

The first production build passed at
`Saved/Build/cta-parameter-typed-action-first-fix-build/20260827_142519_725_119d8014/RunMetadata.json`,
and the two new focused tests were **2/2 PASS** at
`Saved/Tests/cta-parameter-typed-action-focused-first-green/20260827_142609_776_934a4b23/RunMetadata.json`.

### GREEN-stage findings and corrections

The first complete SemaAuthority run was **330/331 PASS** at
`Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority/20260827_142744_257_3606f338/RunMetadata.json`.
The only failure was the pre-existing static architecture test
`ParserFuncDefUsesTypedSignatureActionWithoutWholeNodeReplay`: it searched for
the obsolete text `ParseParameterList()`. Its protected ordering remained
correct and had become stricter—the funcdef now passes the exact declaration—
so the oracle was updated to require
`ParseParameterList(canonicalFuncDef)`. No production behavior was weakened.
The corrected test build passed at
`Saved/Build/cta-parameter-typed-action-regression-test-fix-build/20260827_142859_406_3c76fefe/RunMetadata.json`.

Two build invocations were invalid and are not product evidence:

1. an outer command-string escaping mistake transformed
   `Tools/RunBuild.ps1` into `ToolsRunBuild.ps1`, so no project runner started
   and no metadata was produced;
2. a later invocation used unsupported build argument `-ReportOutputPath`.
   It was consumed as an UBT target and failed before compilation with
   `RulesError`; its diagnostic metadata is
   `Saved/Build/build/20260827_142846_643_6e51c19f/RunMetadata.json`.

The corrected build command uses `-Label`, as shown by the successful build
above. Neither invalid attempt is counted as RED or GREEN.

### Final evidence

| Gate | Result | Evidence |
|---|---:|---|
| Complete SemaAuthority | **331/331 PASS** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority/20260827_142918_046_591fd064/RunMetadata.json` |
| Complete ProductionCodeGen | **114/114 PASS** | `Saved/Tests/cta-parameter-typed-action-production-codegen-green/20260827_143021_524_803323d9/RunMetadata.json` |
| Parser declarations | **18/18 PASS** | `Saved/Tests/cta-parameter-typed-action-parser-declarations-green/20260827_143058_819_19718c0f/RunMetadata.json` |

The complete Sema group includes default-argument ownership, named-argument
formal-slot reordering, parameter qualifier/stable-key distinction, import,
interface and funcdef parameter boundaries. ProductionCodeGen includes value
parameters, import execution, host funcdef execution, generated setter
ownership and prepared Runtime signature normalization.

Final maintained-fork scans show:

- zero `ActOnParsedParam` occurrences;
- exactly one `ParseParameterList` definition whose Canonical call sites pass
  import, funcdef, ordinary-function and interface-method DeclIds;
- typed parameter-header publication occurs before optional default parsing,
  and the default adapter is separately named;
- direct line-bearing `asCScriptNode` sites remain declaration **83**,
  expression **42**, statement **20**, and core Sema **3**. This raw count is
  unchanged from CTA-S-17 because one named default-expression adapter remains;
- `ParseVirtualPropertyDecl` still emits `TXT_VIRTUAL_PROPERTY_REMOVED`, Sema
  has no `snVirtualProperty` case, and `ActOnPropertyDecl` has no production
  caller. The deleted syntax was not restored.

`openspec validate refactor-as-canonical-typed-ast-compiler --strict` passes.
Parent and plugin `git diff --check` both exit **0** with existing LF/CRLF
conversion warnings only. Compiler default remains LEGACY and Cache V2 remains
default-disabled.
