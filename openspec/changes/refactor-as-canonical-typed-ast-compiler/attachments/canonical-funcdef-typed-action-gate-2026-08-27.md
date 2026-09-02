# Canonical funcdef typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-16 — dormant Parser `funcdef` declaration identity/signature and exact parameter ownership |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Semantic fixture | a direct typed `asSFuncDefSignatureAction` for `int Callback(int Value)` with the parameter created under the returned FuncDef DeclId |
| Dialect fixture | the maintained tokenizer continues to classify authored `funcdef` as an identifier, so script-level declarations remain rejected; host `RegisterFuncdef` remains the supported public route |
| Construction/sealed-AST assertion | the action creates exactly one `FuncDefDecl`, records canonical return type and parameter type/name, and produces the stable callable-type signature without any `asCScriptNode` input |
| Architecture assertion | `ParseFuncDef` publishes the typed signature before `ParseParameterList`, pushes the exact FuncDef DeclContext, top-level/class callbacks exclude the completed shell, and declaration Sema contains no `case snFuncDef:` decoder |
| Expected RED | no typed funcdef signature action exists; `ParseFuncDef` parses parameters in its outer context; top-level/class paths still call `NotifySema` on the completed `snFuncDef`; `WalkOne` reconstructs the declaration and walks its parameters |
| Production edit allowed after RED | yes, limited to the typed funcdef signature/start action, exact context scope, callback exclusions, and deletion of the old whole-node decoder |

## Locked design

1. This change does **not** enable script-level `funcdef`. The commented-out
   tokenizer keyword entry and all existing rejection diagnostics remain
   unchanged. Host `RegisterFuncdef` remains legal and is outside this Parser
   action path.
2. `asSFuncDefSignatureAction` carries only the authored name, canonical return
   `QualType`, and exact name range. It carries no Parser/Engine pointer,
   numeric TypeId, or durable snapshot-local reference.
3. Immediately after recognizing the name, `ParseFuncDef` calls
   `ActOnFuncDefSignatureAction`. Sema resolves the current lexical parent,
   creates/reuses exactly one `FuncDefDecl`, records its return type and named
   type dependency, and returns its DeclId.
4. Parser pushes that exact DeclId before parsing parameters. Existing typed
   parameter actions therefore attach directly to the funcdef instead of being
   reconstructed later from `snParameterList`.
5. The completed `snFuncDef` remains LEGACY/recovery syntax storage only. It is
   excluded from the generic top-level callback and the class-member callback;
   declaration Sema removes `case snFuncDef:` entirely.
6. Invalid/empty names, invalid return types, invalid ranges, or absent source
   state fail closed with a funcdef-action diagnostic and publish no fake
   declaration.

## Required evidence

1. test-only build and valid RED before production edits;
2. direct action semantic test plus static architecture mutation test;
3. Runtime/Editor build after repair;
4. focused CTA-S-16 GREEN and complete SemaAuthority GREEN;
5. existing script-funcdef rejection and host-registered-funcdef regression
   GREEN;
6. ProductionCodeGen GREEN, strict OpenSpec validation, and parent/plugin
   `git diff --check`;
7. every RED, runner/tool issue, root cause, repair, evidence and non-claim
   copied to the final issue/progress/task ledgers.

## Mutation checks

The permanent tests must fail if a future change:

- restores `NotifySema` for a completed `snFuncDef` at top level or in a class;
- restores `case snFuncDef:` in declaration Sema;
- parses parameters before entering the exact funcdef DeclContext;
- drops the canonical return type or attaches the parameter to the outer
  translation-unit/class context;
- enables the script `funcdef` keyword while claiming this bounded migration;
- changes host-registered funcdef behavior or its dynamic Runtime TypeId ABI.

## Non-claims

- This does not make script-level funcdef declarations part of the fork
  dialect.
- This does not replace dynamic host TypeId assignment, the Runtime funcdef
  registry, indirect-call cells, VM object registers, or CodeGen relocations.
- This does not migrate general type/parameter/default-expression actions.
- This does not complete Tasks `4.2`–`4.5`, detached CodeGen, TypedASTJIT, or
  the final CANONICAL-default cutover.

## TDD and implementation result

The two permanent tests were added before production edits:

- `SemaFuncDefSignatureActionRecordsTypedCallableWithoutScriptNode` constructs
  `int Callback(int Value)` from an `asSFuncDefSignatureAction`, attaches the
  parameter under the returned FuncDef DeclId, seals the graph and checks the
  unique stable dump;
- `ParserFuncDefUsesTypedSignatureActionWithoutWholeNodeReplay` pins the action
  order, exact context scope, callback exclusions, decoder deletion and the
  maintained tokenizer rejection.

The test-only build produced the intended compile RED because
`asSFuncDefSignatureAction` and `ActOnFuncDefSignatureAction` did not yet
exist. This is a valid API-absence RED, not a runner or environment failure:

`Saved/Build/cta-funcdef-typed-action-red-test-build/20260827_123726_803_20efe23b/RunMetadata.json`

Production then added the pointer-free signature payload and start/action APIs,
published the exact FuncDef identity and canonical return type before parameter
parsing, pushed the returned DeclContext, excluded completed `snFuncDef` shells
from top-level/class callbacks, and deleted `WalkOne(case snFuncDef)`. The
first repair build passed:

`Saved/Build/cta-funcdef-typed-action-first-fix-build/20260827_123856_518_dbd7fbdf/RunMetadata.json`

Two initial focused invocations omitted CQTest's
`FCanonicalASTSemaAuthorityTests` class segment and matched zero tests:

- `Saved/Tests/cta-funcdef-typed-action-semantic-green/20260827_123932_150_bf5011e2/RunMetadata.json`;
- `Saved/Tests/cta-funcdef-typed-action-architecture-green/20260827_124000_900_612fffb0/RunMetadata.json`.

They are invalid runner prefixes, not product failures. The complete suite
proved both tests were registered, and corrected exact prefixes then passed:

| Gate | Result | Evidence |
|---|---:|---|
| Complete SemaAuthority | **326/326 PASS** | `Saved/Tests/cta-funcdef-typed-action-sema-authority-first-green/20260827_124057_950_c982e472/Report/index.json` |
| Direct typed-action semantic fixture | **1/1 PASS** | `Saved/Tests/cta-funcdef-typed-action-semantic-focused-green/20260827_124146_765_c7d51f9f/Report/index.json` |
| Parser/Sema architecture fixture | **1/1 PASS** | `Saved/Tests/cta-funcdef-typed-action-architecture-focused-green/20260827_124215_052_f9ff04c3/Report/index.json` |
| Parser script-funcdef rejection | **1/1 PASS** | `Saved/Tests/cta-funcdef-script-parser-rejection-green/20260827_124300_141_33f74657/Report/index.json` |
| Language script-funcdef boundary | **1/1 PASS** | `Saved/Tests/cta-funcdef-script-language-boundary-green/20260827_124328_547_56714320/Report/index.json` |
| Host registration/call/rebuild | **1/1 PASS** | `Saved/Tests/cta-funcdef-host-registration-green/20260827_124357_078_a0104cd3/Report/index.json` |
| Complete ProductionCodeGen | **114/114 PASS** | `Saved/Tests/cta-funcdef-typed-action-production-codegen-green/20260827_124444_513_6580b8bf/Report/index.json` |

The final maintained-fork scan finds zero `case snFuncDef:` decoders and zero
class-member `NotifySema(node->lastChild)` callback. Direct line-bearing
`asCScriptNode` references are declaration **83**, expression **42**, statement
**20**, and core Sema **3**, down from CTA-S-15's **84/42/20/3**. Strict
OpenSpec validation and separate parent/plugin `git diff --check` both exit
**0**; existing LF/CRLF conversion notices are the only output.

CTA-S-16 closes only the retained Parser family's declaration
identity/signature replay. Authored script `funcdef` remains tokenizer-rejected,
while host `RegisterFuncdef`, dynamic Runtime TypeId projection, indirect-call
cells and VM ABI remain unchanged. General type/parameter/default-expression,
property/access-group/lambda/body/expression/statement/lifetime authority,
detached CodeGen completeness, TypedASTJIT HIR retirement and final default
cutover remain open.
