# Canonical function-family typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-11 — ordinary function-family typed signature/traits/body phases |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Source fixtures | class method with two params and `private`/`const`/`final` followed by an incomplete body; existing complete global/method/ctor/dtor/mixin/local/interface fixtures |
| Sealed-AST assertion | method identity, exact two-param key and all header traits exist before body recovery fails; successful functions remain unique with their authored body |
| Architecture assertion | `ParseFunction()` and `ParseInterfaceMethod()` publish typed signature and traits actions without `NotifySema(node)`; complete bodies use one explicit body adapter; the generic declaration completion excludes ordinary `snFunction`; `WalkOne(case snFunction)` retains lambda handling only |
| Expected RED | trailing `const`/`final` is visible only through completed whole-function replay, so an incomplete body leaves the early method with only `private`; Parser source also lacks typed function action APIs and still calls `NotifySema(node)` |
| Production edit allowed after RED | yes, limited to function-family signature/trait/body phase ownership, exact parameter context, and the existing Stage-2 shell identity carry |

## Locked design

Parser publishes an ordinary function family in three phases:

1. after name recognition, publish a pointer-free signature payload containing
   recognized name, exact name range, canonical return QualType and a bounded
   kind hint for function/method/mixin/destructor; Sema uses the current
   DeclContext to distinguish a constructor from an ordinary method;
2. parse parameters under that exact function DeclContext, then publish a
   pointer-free AST trait mask after trailing `const` and method attributes but
   before `;` or body parsing;
3. on a complete authored body, pass only `(function DeclId, body node)` to an
   explicitly named statement-family adapter. It may decode the statement tree
   during migration but may not rediscover function identity, type, parameters
   or traits.

The same start/traits contract covers global functions, class methods,
constructors/destructors, mixins, local functions and interface methods.
Parser still builds `snFunction` for the explicit LEGACY oracle and recovery.
Lambda expressions retain their separate `ActOnLambdaFromNode` transitional
path and are not redesigned in this slice.

## Transitional dependencies made explicit

- Return type construction still uses `ActOnQualTypeFromNode` before filling
  the typed signature payload. This remains Task 4.3/13.2 debt.
- Each parameter still uses `ActOnParsedParam`; typed type/name/default payloads
  remain Task 4.4/13.2 debt.
- Function body attachment still uses a body-node adapter; statement/control/
  lifetime actions remain Tasks 5.5–5.9/13.2 debt.
- The Parser shell may be bound to the already-built DeclId solely for current
  Builder/Runtime producer identity. No semantic field may be decoded through
  that identity map.

## Required evidence

1. test build and focused architecture + early-traits RED before production;
2. Runtime/Editor build after the bounded implementation;
3. focused architecture, early-traits, existing global/mixin/interface and
   constructor/destructor behavior GREEN;
4. complete SemaAuthority and ProductionCodeGen GREEN;
5. source scans, strict OpenSpec validation and parent/plugin `diff --check`;
6. every invalid runner/build/product RED and repair recorded in this gate and
   the final issue/progress/task ledgers without checking umbrellas.

## Non-claims

- General typed type/parameter/default payloads are not complete.
- Lambda/closure Sema is not migrated here.
- Function statements, calls, control targets and lifetime plans are not made
  action-only by the explicit body adapter.
- Class/interface declaration/base/member replay remains separate work.
- Compiler default remains LEGACY and Cache V2 remains default-disabled.

## TDD and implementation record

The two permanent tests were added before the production edit:

- `ParserActOnMethodTraitsBeforeBodyParseFails` requires a broken class method
  to publish `kind=Method name=F`, stable key
  `Probe::F(int,double) const`, both named parameters and trait mask `21`
  before body recovery fails;
- `ParserFunctionFamilyUsesTypedActionsWithoutOrdinaryFunctionReplay` scans the
  Parser/Sema boundary for the three typed phases, excludes ordinary
  `snFunction` from generic completion, limits `WalkOne(case snFunction)` to
  lambdas and, in its strengthened form, requires the obsolete static
  `ActOnFunctionLike` decoder to be physically absent.

The test-only build passed at
`Saved/Build/cta-function-typed-action-red-test-build/20260827_093250_370_4bb52018/RunMetadata.json`.
Three attempted focused commands were invalid evidence because the CQTest
registration path includes `FCanonicalASTSemaAuthorityTests`:

- `Saved/Tests/cta-function-typed-action-architecture-red/20260827_093314_894_04d14902/RunMetadata.json`
  found zero tests;
- `Saved/Tests/cta-function-typed-action-architecture-red-valid/20260827_093540_901_53fc8540/RunMetadata.json`
  still omitted the class segment and found zero tests;
- `Saved/Tests/cta-function-typed-action-behavior-red/20260827_093609_643_f8ab96b6/RunMetadata.json`
  also found zero tests.

They are runner-discovery mistakes, not product REDs. The valid full discovery
run produced the intended **313/315 PASS, 2 FAIL** at
`Saved/Tests/cta-function-typed-action-sema-red-discovery/20260827_093733_885_1291771c/Report/index.json`,
with exactly the two new tests failing.

The bounded implementation adds `asSFunctionSignatureAction` and
`asEFunctionActionKind`, plus
`ActOnFunctionSignatureAction`/`ActOnFunctionTraitsAction`/
`ActOnFunctionBodyFromNode`. `ParseFunction()` and
`ParseInterfaceMethod()` publish the signature as soon as the name is known,
push the exact function DeclContext while parameters attach, publish all
recognized access/mixin/const/final/override/external traits before `;` or the
body, and attach a complete body only through the explicit statement adapter.
Constructors are derived from exact owner/name rather than a Parser-node walk.
Local functions reuse `ParseFunction`, and ordinary global/method/constructor/
destructor/mixin/interface families no longer call the generic whole-node
completion route.

The first production build passed at
`Saved/Build/cta-function-typed-action-first-fix-build/20260827_094508_820_746bbafa/RunMetadata.json`.
The early-traits and architecture tests were **1/1 PASS** at
`Saved/Tests/cta-function-typed-action-traits-focused-green/20260827_094727_582_fd4e9937/Report/index.json`
and
`Saved/Tests/cta-function-typed-action-architecture-focused-green/20260827_094757_000_d52f206c/Report/index.json`.
The first complete regressions were SemaAuthority **315/315 PASS** at
`Saved/Tests/cta-function-typed-action-sema-full-first/20260827_094834_166_04bc4542/Report/index.json`
and ProductionCodeGen **114/114 PASS** at
`Saved/Tests/cta-function-typed-action-production-full-first/20260827_094924_186_d456b6b4/Report/index.json`.

The implementation had made the old `ActOnFunctionLike` unreachable but had
not deleted it. The strengthened architecture assertion was built at
`Saved/Build/cta-function-decoder-removal-red-test-build/20260827_095035_684_d709264f/RunMetadata.json`
and produced a valid **0/1 RED** at
`Saved/Tests/cta-function-decoder-removal-red/20260827_095054_021_217a9da5/Report/index.json`.
The repair deleted the decoder rather than weakening the test. The repair
build passed at
`Saved/Build/cta-function-decoder-removal-fix-build/20260827_095153_486_abb703d6/RunMetadata.json`.

## Final evidence

- strengthened architecture **1/1 PASS**:
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.ParserFunctionFamilyUsesTypedActionsWithoutOrdinaryFunctionReplay/20260827_095332_595_acba8304/Report/index.json`;
- complete SemaAuthority **315/315 PASS**:
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority/20260827_095410_756_d26fc2b1/Report/index.json`;
- complete ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen/20260827_095453_925_a4db9176/Report/index.json`;
- Parser declarations **18/18 PASS**:
  `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Frontend.Parser.Declarations/20260827_095707_103_82667e93/Report/index.json`.

Final source scans find two Parser signature-action sites, two trait-action
sites, one body-adapter call and zero `ActOnFunctionLike` sites. The remaining
direct `asCScriptNode` references are declaration **100**, expression **42**,
statement **27** and core Sema **3**; these are the next migration inventory,
not a line-count completion metric. Strict OpenSpec validation and separate
parent/plugin `git diff --check` both pass; the diff checks emit only the
worktree's existing LF/CRLF conversion notices.

This closes CTA-S-11 as a bounded implementation slice. It advances Tasks
`4.2`, `4.3`, `4.4` and `13.2` but closes none of those umbrellas: return types
still cross `ActOnQualTypeFromNode`, parameters/defaults still cross
`ActOnParsedParam`, complete bodies still cross a statement-node adapter, and
lambda/class/interface declaration-body semantics remain separate. No task
checkbox is changed by this slice.
