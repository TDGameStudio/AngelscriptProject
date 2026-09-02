# Wave B seal-gap matrix (SemaAuthority construction-API vs compile→seal)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Primary: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`.
Identity cutoff: **242** `TEST_METHOD`s (`NativeMemberRefRecordsResolvedFieldOnCompileSealPath` last). Live file now has **243** (see Bite 1).

This is **not** a 13.2 close. Do not check 13.2. Do not start Wave E–G. Do not invent a fifth exclusive bite.

Compile-seal path (authoritative):

```text
SetCompilerPipeline(CANONICAL)
  → AddScriptSection
  → SetASTRetentionPolicy(RETAIN)
  → Build()
  → GetCanonicalASTContext()
  → asCASTDump
```

Helper: `CanonicalASTSemaAuthorityTest::DumpSealedCanonicalAst` (calls `Module->Build()` then dump). Tests that `Build()` then `asCASTDump(*GetCanonicalASTContext())` without the helper are still **Build+retain**.

Not compile-seal:

- **construction-API** — `asCASTContext` + `asCSema.ActOn*` / `ActOnStart*` / `LookupCandidates`, no module `Build()`.
- **parse-fail** — `Parser.ParseScript` result `< 0`; dump of the mid-parse graph.
- **parse+seal** — `ParseScript == 0` + `Context.Seal()`, no `Build()`.

Filter: name contains `WithoutScriptNode` **or** `Sema*Action` **or** `ParserActOn*` **or** `SemaScopeLookup` **or** `SemaStart*`.
`ParserCapturingLambdaRecordsCaptureOnSealedDump` / `ParserSiblingLambdasEachRecordCaptureX` / `SequenceSameBeginDifferentEndInternsDistinctNodes` / `TemplateContainerTypeKeyIsArrayIntNotBareArray` do **not** match the filter; they are called out below.

Fork dialect for any new source: no script `funcdef` / `@` / `is`; mutable script globals rejected (`ConstGlobalTraitAndMutableReject`); use `const` globals.

---

## Counts

| Metric | N |
| --- | --- |
| Identity-cutoff `TEST_METHOD`s in file | 242 |
| Matching filter (matrix rows) | **163** |
| `WithoutScriptNode` in the name | **53** |
| Matching rows with compile-seal counterpart **NONE** (identity cutoff) | **33** |
| Live extra method after identity | `CompileSealAssignConversionDumpsNamedSrcAndDestTypes` (243rd; not in filter) |

The 33 NONE rows are Parser-action identity, intern-time lookup, foreach header, sequence, QualType template/const, lambda capture/identity, inner var, unary ++/--, typedef/interface, funcdef parse-seal, string-literal intern, and assign conversion **at identity cutoff**. Two extra foreach-**body** rows have ForEach kind NONE but already have call-overload compile-seal. Exclusive UBT only takes four of those facts (and Bite 1 is already on disk live).

---

## Callouts (do not mis-queue)

### Assign conversion — construction-API only at identity; live oracle already written

Identity 242: `SemaAssignActionInsertsNamedConversionWithoutScriptNode` (`ActOnAssignExpr(float x, int 3)` dumps `kind=Conversion dest=float src=int`). Parser assign tests only intern `kind=Assign` on `i = 1` (int=int). Call-arg `G(3)`→`G(float)` is **already** compile-seal (`IntArgumentToFloatParamRecordsConversionNode`, `CompileSealConversionDumpsNamedSrcAndDestTypes`). That is **not** assign conversion.

Live file (post-identity, 243rd method): `CompileSealAssignConversionDumpsNamedSrcAndDestTypes` already uses the suggested `float x = 3` source and asserts `dest=float src=int` on `DumpSealedCanonicalAst`. **Bite 1 corrected:** do **not** add a second assign-conversion compile-seal test. Run the existing method; if it PASSes, intern is already on the assign/`WalkOne` path — no production edit.

### Lambda capture — Parse+Seal vs Build()+retain

| Path | TEST_METHOD |
| --- | --- |
| construction-API | `SemaLambdaCaptureActionRecordsCaptureWithoutCodeGenWalk` (`captures=X` on DECL) |
| parse+seal | `ParserCapturingLambdaRecordsCaptureOnSealedDump` (DECL + CALL `captures=X`); `ParserSiblingLambdasEachRecordCaptureX` |
| parse+seal identity only (no capture) | `MultipleLambdasKeepDistinctStableKeys`; `ParserActOnLambdaDoesNotDuplicateOnSuccessfulParse`; `ParserActOnLambdaCallThroughRecordsCallee` |
| Build()+retain dump of `captures=` | **NONE** at identity 242 |
| Execute (out of this file) | `CanonicalCapturingLambdaBuildPublishesCodeGenAndExecutes` already GREEN |

Bite 2 **confirmed**. Suggested source: locals `int X = 21` inside `Entry` (not a mutable global).

### Inner shadowed VAR vs namespace FUNCTION overload

| Fact | Path | Counterpart |
| --- | --- | --- |
| Inner **function** `Game::F` vs global `F` | Build+retain `NamespaceOverloadSelectsScopedFunctionNotGlobal` (qualified `Game::F(3)` from global `Entry`); parse+seal `SemaScopeLookupSelectsInnerNamespaceFunctionNotGlobal` (unqualified `F(3)` inside `Game`) | function overload **already** compile-seal |
| Intern-time candidate list | construction-API `SemaScopeLookupReturnsBothOverloadCandidatesNotFirstName` | selected call dump, not sealed candidate **plan** |
| Inner **variable** `Game::x` float vs TU `x` int | construction-API **only** `SemaDeclRefExprActionSelectsInnerVarNotGlobalWithoutScriptNode` | **NONE** on compile-seal |

`ParserActOnScopedVariableAccessBeforeFunctionCloseFails` is qualified `Game::X` (`const int`) vs missing `}`; it is **not** inner-vs-global shadowing.

Bite 3 **confirmed** (variables). Use `const int x = 1` / `const float x = 2.0f` if mutable globals fail `Build()`.

### Unary ++ parse-fail vs successful Build

| Op | construction-API | parse-fail | Build+retain |
| --- | --- | --- | --- |
| `opNeg` | `SemaUnaryExprActionSelectsOpNegWithoutScriptNode` | `ParserActOnUnaryMinusSelectsOpNegBeforeFunctionCloseFails` | `OperatorUnaryMinusSelectsOpNegNotBuiltinUnary` |
| `opPostInc` | `SemaUnaryExprActionSelectsOpPostIncWithoutScriptNode` | `ParserActOnPostIncSelectsOpPostIncBeforeFunctionCloseFails` | **NONE** |
| `opPreInc` | `SemaUnaryExprActionSelectsOpPreIncWithoutScriptNode` | **NONE** | **NONE** |

Bite 4 **confirmed** (`callee=T::opPostInc()`, not `opPreInc`). VALUE `T v;` needs sibling Construct (dummy invent deleted). `opPreInc` is **later**, not a fifth exclusive bite.

### Foreach — construction-API vs compile-seal

`kind=ForEach` exists on construction-API (`SemaForeachStmtActionRecordsRangeWithoutScriptNode`) and parse-fail / parse+seal (`ParserActOnForeach*`). **No** SemaAuthority `Build()+retain` ForEach dump. **later**, not exclusive (do not invent a fifth bite). Body `callee=F(int)` is already compile-seal via call-overload tests.

### Sequence identity — construction-API only

`SemaSequenceExprActionRecordsKindWithoutScriptNode` dumps comma `kind=Sequence`. `SequenceSameBeginDifferentEndInternsDistinctNodes` (not in filter) locks kind+begin+**end** on construction-API. Compile-seal `kind=Sequence literal=opaque` (`IndexCompoundAssignRecordsOpaqueValueOnCompileSealPath`) is **OpaqueValue**, not comma-sequence identity. Do **not** tell exclusive to globally full-span `FindExistingExpr` / `FindExistingStmt`. **later / no.**

### QualType template/const — construction-API vs parse-seal

`SemaQualTypeActionInternsTemplateAndConstWithoutScriptNode` is construction-API (`type=array<int>`, const var `quals=1`). `TemplateContainerTypeKeyIsArrayIntNotBareArray` is **parse+seal** (`array<int> Values;`), not `Build()`. Primitive QualType+cast is already compile-seal (`CastConversionRecordsOnCompileSealPath`, `CompileSealConversionDumpsNamedSrcAndDestTypes`). Const **global** `quals=1` is compile-seal (`ConstGlobalTraitAndMutableReject`). **later / no.**

---

## Exclusive B-seal-facts bites — confirmed or corrected

| Bite | Coordinator claim | Verdict |
| --- | --- | --- |
| **1 assign-conv** | construction-API only; add `float x = 3` compile-seal | **Corrected.** Identity cutoff: NONE. Live: `CompileSealAssignConversionDumpsNamedSrcAndDestTypes` already on disk. Do not duplicate. If GREEN, skip impl. |
| **2 lambda-capture-retain** | API + Parse+Seal only; need `Build()` `captures=X` | **Confirmed.** |
| **3 inner-var** | construction-API only; function overload is not this bite | **Confirmed.** |
| **4 unary-postinc** | API + parse-fail only; `opNeg` already compile-seal | **Confirmed.** |
| fifth | — | **Do not invent.** `opPreInc` / foreach / sequence / QualType are **later**. |

---

## Build()+retain tests that already lock overload / conversion / call / lifetime

Coordinator `attachments/async-work.md` §4 verified and completed. Exclusive must **not** duplicate these.

| Fact | TEST_METHOD (Build+retain) |
| --- | --- |
| Exact call overload int vs float | `CallSelectsExactIntOverloadNotFirstName`; `CompileSealCallDumpsNamedResultTypeKey` |
| Call-arg int→float / float→int | `IntArgumentToFloatParamRecordsConversionNode`; `FloatArgumentToIntParamRecordsConversionNode` |
| Named dest=/src= on **call-arg** Conversion | `CompileSealConversionDumpsNamedSrcAndDestTypes`; `ConversionDumpRecordsDestTypeKey` |
| Cast conversion | `CastConversionRecordsOnCompileSealPath` |
| Ternary arm conversion | `ConditionalMismatchedArmsRecordConversionOnCompileSealPath` |
| Ctor overload | `ConstructorOverloadsSelectExactCtorNotFirstName` |
| Operators opAdd/opSub/opMul/opDiv/opMod/opNeg/opEquals/opCmp | `OperatorPlusSelectsOpAddNotBuiltinBinary`; `OperatorMinusSelectsOpSubNotBuiltinBinary`; `OperatorStarSelectsOpMulNotBuiltinBinary`; `OperatorSlashSelectsOpDivNotBuiltinBinary`; `OperatorPercentSelectsOpModNotBuiltinBinary`; `OperatorUnaryMinusSelectsOpNegNotBuiltinUnary`; `OperatorEqualSelectsOpEqualsNotBuiltinBinary`; `OperatorLessSelectsOpCmpNotBuiltinBinary` |
| Logical && | `LogicalShortCircuitRecordsOnCompileSealPath`; `LogicalAndRecordsNamedOperandsOnCompileSealPath` |
| Hidden arg inject | `HiddenArgumentInjectedOnNativeCallee` |
| Method `receiver=` | `ThisOrReceiverMetadataOnMethodCall`; `MixinCallBindsReceiverNotFreeGlobal`; `MemberPostfixCallInternsOnceWithoutReceiverLessCallOnCompileSealPath` |
| Import route | `ImportCallKeepsImportRouteDistinctFromGlobal` |
| Property Get/Set rewrite | `PropertyReadWriteRewritesToAccessors`; `PropertyCompoundAssignEvaluatesReceiverOnceOnCompileSealPath` |
| MemberRef field + offset | `NativeMemberRefRecordsResolvedFieldOnCompileSealPath` |
| Index / opIndex | `IndexOnCompileSealPathRecordsIndexNode`; `IndexCompoundAssignEvaluatesBaseOnce`; `IndexCompoundAssignRecordsOpaqueValueOnCompileSealPath` |
| InitPlan typed assign | `UserCtorMemberDefaultFortyPlusOneRecordsTypedAssignBeforeBodyOnCompileSealPath` |
| VALUE temp Materialize+Cleanup | `ValueTemporaryRecordsMaterializeAndCleanup` |
| Destructor callee | `DestructorCallSiteRecordsCallee` |
| Default / named args | `DefaultArgumentIsRecordedOnCallPlan`; `NamedArgumentReordersIntoFormalSlots`; `ReverseFormalChildrenMatchStoredOrder` |
| Namespace **function** overload | `NamespaceOverloadSelectsScopedFunctionNotGlobal`; `ScopedCallInternsOnceOnCompileSealPath` |
| Mixin kind + call | `MixinFunctionKeepsMixinKindAndSignature`; `MixinCallBindsReceiverNotFreeGlobal` |
| Generated accessors | `GeneratedAccessorsHaveGeneratedTraitAndCallPlan` |
| List-pattern **expr** `{1,2}` | `ListPatternRecordsStructuredNodes` |
| Local DeclStmt + sibling Assign | `LocalDeclAndExprStmtAreSiblingsOnCompileSealPath` |
| Control targets / phases / safepoint | `ContinueTargetsEnclosingWhileOnCompileSealPath`; `BreakTargetsNearestSwitchNotOuterLoop`; `FallthroughTargetsNextCase`; `ForStmtRecordsNamedPhasesOnCompileSealPath`; `ForLoopRecordsInitCondIncrBodyPhasesOnCompileSeal`; `IfStmtRecordsNamedThenElseOnCompileSealPath`; `DoWhileStmtRecordsNamedBodyTrailingCondOnCompileSealPath`; `SwitchDefaultCaseIsLastAndHasNoExprOnCompileSealPath`; `LoopReturnCallAndTransferRecordSafePointRolesOnCompileSealPath` |
| NullLiteral | `StringLiteralAndNullLiteralKeepKindsOnCompileSeal` (string half is parse+seal) |
| Const global trait | `ConstGlobalTraitAndMutableReject` (const `Build()`; mutable rejected) |
| Param identity keys | `ParamQualifiersKeepDistinctStableKeysOnCompileSeal`; `InOutParamOverloadsKeepDistinctStableKeysOnCompileSeal`; `ConstMethodOverloadKeepsDistinctStableKeysOnCompileSeal`; `EnumParamOnCompileSealPathInternsEnumKind` |
| **Assign** dest=/src= | identity **NONE**; live `CompileSealAssignConversionDumpsNamedSrcAndDestTypes` |

`AmbiguousOverloadIsRejectedNotFirstName` is **parse+seal** (not Build+retain).

---

## Matrix (163 matching `TEST_METHOD`s)

Path: construction-API / parse-fail / parse+seal / Build+retain.
Fact: overload / conversion / call / lifetime / control / identity / recovery.
Exclusive: `1` assign-conv / `2` lambda-capture-retain / `3` inner-var / `4` unary-postinc / `later` / `no`.

| TEST_METHOD | Path | Fact | Compile-seal counterpart | Exclusive |
| --- | --- | --- | --- | --- |
| ParserSemaActionsRecordFirstFunctionWhenLaterSyntaxFails | parse-fail | recovery | NONE (Parser identity) | no |
| ParserActOnFunctionDeclBeforeBodyParseFails | parse-fail | identity | CallSelectsExactIntOverloadNotFirstName (kind=Function incidental) | no |
| ParserActOnFunctionDeclDoesNotDuplicateOnSuccessfulParse | parse+seal | identity | same incidental Function intern | no |
| SemaStartParamDeclActionRecordsParamWithoutScriptNode | construction-API | identity | ParamQualifiersKeepDistinctStableKeysOnCompileSeal | no |
| SemaStartEnumeratorDeclActionRecordsEnumeratorWithoutScriptNode | construction-API | identity | EnumParamOnCompileSealPathInternsEnumKind (host enum; not script enumerator) | no |
| ParserActOnParamBeforeParameterListCloseFails | parse-fail | identity | ParamQualifiersKeepDistinctStableKeysOnCompileSeal | no |
| ParserActOnParamDoesNotDuplicateOnSuccessfulParse | parse+seal | identity | ParamQualifiersKeepDistinctStableKeysOnCompileSeal | no |
| ParserActOnClassAndMethodDeclBeforeMemberBodyFails | parse-fail | identity | PropertyReadWriteRewritesToAccessors | no |
| ParserActOnClassAndMethodDoesNotDuplicateOnSuccessfulParse | parse+seal | identity | PropertyReadWriteRewritesToAccessors | no |
| ParserActOnBodyStatementBeforeBodyParseFails | parse-fail | recovery | LocalDeclAndExprStmtAreSiblingsOnCompileSealPath | no |
| ParserActOnNamespaceDeclBeforeInnerBodyFails | parse-fail | identity | NamespaceOverloadSelectsScopedFunctionNotGlobal | no |
| ParserActOnNamespaceDoesNotDuplicateOnSuccessfulParse | parse+seal | identity | NamespaceOverloadSelectsScopedFunctionNotGlobal | no |
| ParserActOnNestedNamespaceDeclBeforeInnerBodyFails | parse-fail | identity | NamespaceOverloadSelectsScopedFunctionNotGlobal | no |
| ParserActOnEnumDeclAndEnumeratorBeforeListCloseFails | parse-fail | identity | EnumParamOnCompileSealPathInternsEnumKind | no |
| ParserActOnEnumDoesNotDuplicateOnSuccessfulParse | parse+seal | identity | EnumParamOnCompileSealPathInternsEnumKind | no |
| ParserActOnInterfaceAndMethodDeclBeforeSignatureFails | parse-fail | identity | NONE | no |
| ParserActOnInterfaceDoesNotDuplicateOnSuccessfulParse | parse+seal | identity | NONE | no |
| ParserActOnMixinFunctionDeclBeforeBodyFails | parse-fail | identity | MixinFunctionKeepsMixinKindAndSignature | no |
| ParserActOnMixinDoesNotDuplicateOnSuccessfulParse | parse+seal | identity | MixinFunctionKeepsMixinKindAndSignature | no |
| SemaScopeLookupPrefersCurrentContextThenOuterAfterPop | construction-API | identity | NONE (intern-time LookupCandidates; not a sealed plan) | no |
| SemaScopeLookupReturnsBothOverloadCandidatesNotFirstName | construction-API | overload | CallSelectsExactIntOverloadNotFirstName (selection dump, not candidate list) | no |
| SemaCallExprActionSelectsIntOverloadWithoutScriptNode | construction-API | overload | CallSelectsExactIntOverloadNotFirstName; CompileSealCallDumpsNamedResultTypeKey | no |
| SemaCallExprActionInsertsNamedConversionWithoutScriptNode | construction-API | conversion | IntArgumentToFloatParamRecordsConversionNode; CompileSealConversionDumpsNamedSrcAndDestTypes | no |
| SemaCastActionInsertsNamedConversionWithoutScriptNode | construction-API | conversion | CastConversionRecordsOnCompileSealPath | no |
| SemaConstructActionSelectsIntCtorWithoutScriptNode | construction-API | overload | ConstructorOverloadsSelectExactCtorNotFirstName | no |
| SemaReturnStmtActionRecordsValueWithoutScriptNode | construction-API | control | IfStmtRecordsNamedThenElseOnCompileSealPath (Return on compile-seal) | no |
| SemaReturnStmtActionDoesNotStealFunctionBody | construction-API | identity | NONE (ownership; parse+seal ParserActOnIfThenReturnIsIfChildNotFunctionBody) | no |
| SemaAssignActionInsertsNamedConversionWithoutScriptNode | construction-API | conversion | identity NONE; live CompileSealAssignConversionDumpsNamedSrcAndDestTypes | **1** (live: already written) |
| SemaAssignActionRewritesPropertySetWithoutScriptNode | construction-API | call | PropertyReadWriteRewritesToAccessors | no |
| SemaBinaryActionSelectsOpSubWithoutScriptNode | construction-API | overload | OperatorMinusSelectsOpSubNotBuiltinBinary | no |
| SemaLogicalActionRecordsShortCircuitWithoutScriptNode | construction-API | control | LogicalShortCircuitRecordsOnCompileSealPath; LogicalAndRecordsNamedOperandsOnCompileSealPath | no |
| SemaIfStmtActionRecordsCondWithoutScriptNode | construction-API | control | IfStmtRecordsNamedThenElseOnCompileSealPath | no |
| SemaIfStmtActionFillsThenOnExistingStub | construction-API | identity | NONE (FindExistingStmt kind+begin fill; do not full-span) | no |
| SemaWhileStmtActionRecordsCondWithoutScriptNode | construction-API | control | ContinueTargetsEnclosingWhileOnCompileSealPath | no |
| SemaForStmtActionRecordsPhasesWithoutScriptNode | construction-API | control | ForStmtRecordsNamedPhasesOnCompileSealPath; ForLoopRecordsInitCondIncrBodyPhasesOnCompileSeal | no |
| SemaSwitchStmtActionRecordsCondWithoutScriptNode | construction-API | control | SwitchDefaultCaseIsLastAndHasNoExprOnCompileSealPath | no |
| SemaDoWhileStmtActionRecordsCondWithoutScriptNode | construction-API | control | DoWhileStmtRecordsNamedBodyTrailingCondOnCompileSealPath | no |
| SemaForeachStmtActionRecordsRangeWithoutScriptNode | construction-API | control | NONE | later |
| SemaLambdaExprActionRecordsDeclWithoutScriptNode | construction-API | identity | NONE Build+retain (`MultipleLambdasKeepDistinctStableKeys` is parse+seal) | no |
| SemaLambdaCaptureActionRecordsCaptureWithoutCodeGenWalk | construction-API | lifetime | NONE Build+retain (`ParserCapturingLambdaRecordsCaptureOnSealedDump` is parse+seal) | **2** |
| SemaMemberExprActionRewritesPropertyGetWithoutScriptNode | construction-API | call | PropertyReadWriteRewritesToAccessors | no |
| SemaIndexExprActionSelectsOpIndexWithoutScriptNode | construction-API | overload | IndexOnCompileSealPathRecordsIndexNode | no |
| SemaUnaryExprActionSelectsOpNegWithoutScriptNode | construction-API | overload | OperatorUnaryMinusSelectsOpNegNotBuiltinUnary | no |
| SemaUnaryExprActionSelectsOpPostIncWithoutScriptNode | construction-API | overload | NONE | **4** |
| SemaUnaryExprActionSelectsOpPreIncWithoutScriptNode | construction-API | overload | NONE | later |
| SemaQualTypeActionInternsPrimitiveWithoutScriptNode | construction-API | conversion | CastConversionRecordsOnCompileSealPath | no |
| SemaQualTypeActionInternsTemplateAndConstWithoutScriptNode | construction-API | identity | NONE Build+retain (`TemplateContainerTypeKeyIsArrayIntNotBareArray` is parse+seal) | later |
| SemaDeclRefExprActionSelectsInnerVarNotGlobalWithoutScriptNode | construction-API | overload | NONE (`NamespaceOverloadSelectsScopedFunctionNotGlobal` is **function**) | **3** |
| SemaLocalDeclStmtActionRecordsVarAndInitWithoutScriptNode | construction-API | identity | LocalDeclAndExprStmtAreSiblingsOnCompileSealPath | no |
| SemaInitListActionRecordsListPatternWithoutScriptNode | construction-API | identity | ListPatternRecordsStructuredNodes | no |
| SemaBreakStmtActionRecordsWhileTargetWithoutScriptNode | construction-API | control | ParserActOnBreakRecordsWhileTargetBeforeBodyCloseFails is parse-fail; compile-seal while-break incidental via ContinueTargets / LoopReturn…; dedicated switch-break is BreakTargetsNearestSwitchNotOuterLoop | no |
| SemaContinueStmtActionRecordsForTargetWithoutScriptNode | construction-API | control | ContinueTargetsEnclosingWhileOnCompileSealPath (while, not for); ForStmtRecordsNamedPhasesOnCompileSealPath | no |
| SemaFallthroughStmtActionRecordsKindWithoutScriptNode | construction-API | control | FallthroughTargetsNextCase | no |
| SemaConditionalExprActionRecordsTernaryWithoutScriptNode | construction-API | overload | ConditionalMismatchedArmsRecordConversionOnCompileSealPath | no |
| SemaFloatLiteralActionRecordsKindWithoutScriptNode | construction-API | identity | ConversionDumpRecordsDestTypeKey / call-arg tests (float literals incidental) | no |
| SemaStringLiteralActionRecordsKindWithoutScriptNode | construction-API | identity | NONE Build+retain (string half of StringLiteralAndNullLiteralKeepKindsOnCompileSeal is parse+seal) | no |
| SemaNullLiteralActionRecordsKindWithoutScriptNode | construction-API | identity | StringLiteralAndNullLiteralKeepKindsOnCompileSeal | no |
| SemaExpressionStmtActionRecordsCallWithoutScriptNode | construction-API | overload | CallSelectsExactIntOverloadNotFirstName | no |
| SemaCaseStmtActionRecordsValueWithoutScriptNode | construction-API | control | SwitchDefaultCaseIsLastAndHasNoExprOnCompileSealPath; FallthroughTargetsNextCase | no |
| SemaCompoundStmtActionRecordsChildrenWithoutScriptNode | construction-API | identity | LocalDeclAndExprStmtAreSiblingsOnCompileSealPath | no |
| SemaCompoundStmtActionAttachesBlockAsFunctionBody | construction-API | identity | LocalDeclAndExprStmtAreSiblingsOnCompileSealPath | no |
| SemaStartNamespaceDeclActionRecordsKindWithoutScriptNode | construction-API | identity | NamespaceOverloadSelectsScopedFunctionNotGlobal | no |
| SemaStartClassDeclActionRecordsKindWithoutScriptNode | construction-API | identity | PropertyReadWriteRewritesToAccessors | no |
| SemaStartEnumDeclActionRecordsKindWithoutScriptNode | construction-API | identity | EnumParamOnCompileSealPathInternsEnumKind | no |
| SemaStartInterfaceDeclActionRecordsKindWithoutScriptNode | construction-API | identity | NONE | no |
| SemaStartTypedefDeclActionRecordsKindWithoutScriptNode | construction-API | identity | NONE | no |
| SemaStartImportDeclActionRecordsKindWithoutScriptNode | construction-API | identity | ImportCallKeepsImportRouteDistinctFromGlobal | no |
| SemaStartFunctionDeclActionRecordsKindWithoutScriptNode | construction-API | identity | CallSelectsExactIntOverloadNotFirstName | no |
| SemaStartMethodDeclActionRecordsKindWithoutScriptNode | construction-API | identity | ThisOrReceiverMetadataOnMethodCall | no |
| SemaStartVarDeclActionRecordsKindWithoutScriptNode | construction-API | identity | LocalDeclAndExprStmtAreSiblingsOnCompileSealPath | no |
| SemaStartConstructorDeclActionRecordsKindWithoutScriptNode | construction-API | identity | ConstructorOverloadsSelectExactCtorNotFirstName | no |
| SemaStartDestructorDeclActionRecordsKindWithoutScriptNode | construction-API | identity | DestructorCallSiteRecordsCallee | no |
| SemaStartMixinDeclActionRecordsKindWithoutScriptNode | construction-API | identity | MixinFunctionKeepsMixinKindAndSignature | no |
| SemaStartConstructorDeclOverloadsDoNotCollapseByName | construction-API | overload | ConstructorOverloadsSelectExactCtorNotFirstName | no |
| SemaListPatternDeclActionRecordsStructuredOriginWithoutScriptNode | construction-API | identity | ListPatternRecordsStructuredNodes (expr `literal=list-pattern`, not DECL `origin=`) | no |
| SemaPostfixCallExprActionSelectsIntOverloadWithoutScriptNode | construction-API | overload | CallSelectsExactIntOverloadNotFirstName; MemberPostfixCallInternsOnceWithoutReceiverLessCallOnCompileSealPath | no |
| SemaSequenceExprActionRecordsKindWithoutScriptNode | construction-API | identity | NONE (OpaqueValue Sequence is not comma Sequence) | later |
| SemaScopeLookupSelectsInnerNamespaceFunctionNotGlobal | parse+seal | overload | NamespaceOverloadSelectsScopedFunctionNotGlobal | no |
| SemaScopeLookupRequiresEnumScopeForEnumerator | parse+seal (+ unqualified dump) | identity | EnumParamOnCompileSealPathInternsEnumKind | no |
| ParserActOnImportDeclBeforeFromFails | parse-fail | identity | ImportCallKeepsImportRouteDistinctFromGlobal | no |
| ParserActOnImportDoesNotDuplicateOnSuccessfulParse | parse+seal | identity | ImportCallKeepsImportRouteDistinctFromGlobal | no |
| ParserActOnTypedefDeclBeforeSemicolonFails | parse-fail | identity | NONE | no |
| ParserActOnTypedefDoesNotDuplicateOnSuccessfulParse | parse+seal | identity | NONE | no |
| ParserActOnLambdaDeclBeforeBodyParseFails | parse-fail | identity | NONE Build+retain | no |
| ParserActOnLambdaDoesNotDuplicateOnSuccessfulParse | parse+seal | identity | NONE Build+retain | no |
| ParserActOnCallExprBeforeArgListCloseFails | parse-fail | call | CallSelectsExactIntOverloadNotFirstName | no |
| ParserActOnCallDoesNotDuplicateOnSuccessfulParse | parse+seal | call | CallSelectsExactIntOverloadNotFirstName | no |
| ParserActOnScopedCallDoesNotDuplicateOnSuccessfulParse | parse+seal | overload | ScopedCallInternsOnceOnCompileSealPath; NamespaceOverloadSelectsScopedFunctionNotGlobal | no |
| ParserActOnUnresolvedCallDoesNotDuplicateOnSuccessfulParse | parse+seal | recovery | UnresolvedCallDoesNotPublishFakeIntSuccess | no |
| ParserActOnCallSelectsIntOverloadBeforeFunctionCloseFails | parse-fail | overload | CallSelectsExactIntOverloadNotFirstName | no |
| ParserActOnConversionBeforeArgListCloseFails | parse-fail | conversion | IntArgumentToFloatParamRecordsConversionNode; CompileSealConversionDumpsNamedSrcAndDestTypes | no |
| ParserActOnConstructTemporaryBeforeArgListCloseFails | parse-fail | overload | ConstructorOverloadsSelectExactCtorNotFirstName | no |
| ParserActOnReturnStmtBeforeSemicolonFails | parse-fail | control | IfStmtRecordsNamedThenElseOnCompileSealPath | no |
| ParserActOnReturnDoesNotDuplicateOnSuccessfulParse | parse+seal | control | IfStmtRecordsNamedThenElseOnCompileSealPath | no |
| ParserActOnIfBeforeCloseParenFails | parse-fail | control | IfStmtRecordsNamedThenElseOnCompileSealPath | no |
| ParserActOnIfDoesNotDuplicateOnSuccessfulParse | parse+seal | control | IfStmtRecordsNamedThenElseOnCompileSealPath | no |
| ParserActOnIfThenReturnIsIfChildNotFunctionBody | parse+seal | identity | IfStmtRecordsNamedThenElseOnCompileSealPath | no |
| ParserActOnIfElseReturnsAreIfChildren | parse+seal | identity | IfStmtRecordsNamedThenElseOnCompileSealPath | no |
| ParserActOnWhileReturnIsWhileChildNotFunctionBody | parse+seal | identity | ContinueTargetsEnclosingWhileOnCompileSealPath | no |
| ParserActOnSwitchCaseReturnIsCaseChild | parse+seal | identity | SwitchDefaultCaseIsLastAndHasNoExprOnCompileSealPath | no |
| ParserActOnWhileBeforeCloseParenFails | parse-fail | control | ContinueTargetsEnclosingWhileOnCompileSealPath | no |
| ParserActOnSwitchBeforeCloseParenFails | parse-fail | control | SwitchDefaultCaseIsLastAndHasNoExprOnCompileSealPath | no |
| ParserActOnAssignBeforeSemicolonFails | parse-fail | identity | LocalDeclAndExprStmtAreSiblingsOnCompileSealPath (`kind=Assign`, **not** dest=/src=) | no |
| ParserActOnAssignDoesNotDuplicateOnSuccessfulParse | parse+seal | identity | LocalDeclAndExprStmtAreSiblingsOnCompileSealPath | no |
| ParserActOnForBeforeConditionCloseFails | parse-fail | control | ForStmtRecordsNamedPhasesOnCompileSealPath | no |
| ParserActOnForDoesNotDuplicateOnSuccessfulParse | parse+seal | control | ForStmtRecordsNamedPhasesOnCompileSealPath | no |
| ParserActOnDoWhileBeforeCloseParenFails | parse-fail | control | DoWhileStmtRecordsNamedBodyTrailingCondOnCompileSealPath | no |
| ParserActOnDoWhileDoesNotDuplicateOnSuccessfulParse | parse+seal | control | DoWhileStmtRecordsNamedBodyTrailingCondOnCompileSealPath | no |
| ParserActOnForeachBeforeColonFails | parse-fail | control | NONE | later |
| ParserActOnForeachDoesNotDuplicateOnSuccessfulParse | parse+seal | control | NONE | later |
| ParserActOnForeachBodyBeforeBlockCloseFails | parse-fail | overload | CallSelectsExactIntOverloadNotFirstName (call only); ForEach kind NONE | later |
| ParserActOnForeachBodyRecordsSelectedCallOnSuccessfulParse | parse+seal | overload | CallSelectsExactIntOverloadNotFirstName (call only); ForEach kind NONE | later |
| ParserActOnIfBodyBeforeBlockCloseFails | parse-fail | overload | CallSelectsExactIntOverloadNotFirstName; IfStmtRecordsNamedThenElseOnCompileSealPath | no |
| ParserActOnIfBodyRecordsSelectedCallOnSuccessfulParse | parse+seal | overload | CallSelectsExactIntOverloadNotFirstName; IfStmtRecordsNamedThenElseOnCompileSealPath | no |
| ParserActOnWhileBodyBeforeBlockCloseFails | parse-fail | overload | CallSelectsExactIntOverloadNotFirstName | no |
| ParserActOnWhileBodyRecordsSelectedCallOnSuccessfulParse | parse+seal | overload | CallSelectsExactIntOverloadNotFirstName | no |
| ParserActOnForBodyBeforeBlockCloseFails | parse-fail | overload | CallSelectsExactIntOverloadNotFirstName; ForStmtRecordsNamedPhasesOnCompileSealPath | no |
| ParserActOnForBodyRecordsSelectedCallOnSuccessfulParse | parse+seal | overload | CallSelectsExactIntOverloadNotFirstName; ForStmtRecordsNamedPhasesOnCompileSealPath | no |
| ParserActOnDoWhileBodyBeforeBlockCloseFails | parse-fail | overload | CallSelectsExactIntOverloadNotFirstName; DoWhileStmtRecordsNamedBodyTrailingCondOnCompileSealPath | no |
| ParserActOnDoWhileBodyRecordsSelectedCallOnSuccessfulParse | parse+seal | overload | CallSelectsExactIntOverloadNotFirstName | no |
| ParserActOnSwitchBodyBeforeBlockCloseFails | parse-fail | overload | CallSelectsExactIntOverloadNotFirstName; SwitchDefaultCaseIsLastAndHasNoExprOnCompileSealPath | no |
| ParserActOnSwitchBodyRecordsSelectedCallOnSuccessfulParse | parse+seal | overload | CallSelectsExactIntOverloadNotFirstName | no |
| ParserActOnFuncdefParamCallRecordsCallee | parse+seal | call | NONE (host funcdef; do not intern script funcdef) | no |
| ParserActOnFuncdefLocalCallRecordsCallee | parse+seal | conversion | NONE | no |
| ParserActOnNamedCallConvertsFunctionToFuncdef | parse+seal | conversion | NONE | no |
| ParserActOnCastBeforeCloseParenFails | parse-fail | conversion | CastConversionRecordsOnCompileSealPath | no |
| ParserActOnCastRecordsConversionOnSuccessfulParse | parse+seal | conversion | CastConversionRecordsOnCompileSealPath | no |
| ParserActOnIndexBeforeCloseBracketFails | parse-fail | overload | IndexOnCompileSealPathRecordsIndexNode | no |
| ParserActOnIndexRecordsOpIndexOnSuccessfulParse | parse+seal | overload | IndexOnCompileSealPathRecordsIndexNode | no |
| ParserActOnLogicalBeforeRhsCloseFails | parse-fail | control | LogicalShortCircuitRecordsOnCompileSealPath | no |
| ParserActOnLogicalRecordsShortCircuitOnSuccessfulParse | parse+seal | control | LogicalShortCircuitRecordsOnCompileSealPath | no |
| ParserActOnConditionalBeforeElseCloseFails | parse-fail | control | ConditionalMismatchedArmsRecordConversionOnCompileSealPath | no |
| ParserActOnConditionalRecordsTernaryOnSuccessfulParse | parse+seal | control | ConditionalMismatchedArmsRecordConversionOnCompileSealPath | no |
| ParserActOnLambdaCallThroughRecordsCallee | parse+seal | call | NONE Build+retain | no |
| ParserActOnExprStmtSuccessBeforeFunctionCloseFails | parse-fail | identity | CallSelectsExactIntOverloadNotFirstName | no |
| ParserActOnExprStmtDoesNotDuplicateOnSuccessfulParse | parse+seal | identity | CallSelectsExactIntOverloadNotFirstName | no |
| ParserActOnBreakBeforeFunctionCloseFails | parse-fail | control | BreakTargetsNearestSwitchNotOuterLoop | no |
| ParserActOnBreakBeforeSemicolonFails | parse-fail | control | BreakTargetsNearestSwitchNotOuterLoop | no |
| ParserActOnContinueBeforeFunctionCloseFails | parse-fail | control | ContinueTargetsEnclosingWhileOnCompileSealPath | no |
| ParserActOnFallthroughBeforeFunctionCloseFails | parse-fail | control | FallthroughTargetsNextCase | no |
| ParserActOnBreakDoesNotDuplicateOnSuccessfulParse | parse+seal | control | BreakTargetsNearestSwitchNotOuterLoop | no |
| ParserActOnContinueDoesNotDuplicateOnSuccessfulParse | parse+seal | control | ContinueTargetsEnclosingWhileOnCompileSealPath | no |
| ParserActOnFallthroughDoesNotDuplicateOnSuccessfulParse | parse+seal | control | FallthroughTargetsNextCase | no |
| ParserActOnUnaryMinusBeforeFunctionCloseFails | parse-fail | identity | OperatorUnaryMinusSelectsOpNegNotBuiltinUnary | no |
| ParserActOnUnaryMinusSelectsOpNegBeforeFunctionCloseFails | parse-fail | overload | OperatorUnaryMinusSelectsOpNegNotBuiltinUnary | no |
| ParserActOnPostIncSelectsOpPostIncBeforeFunctionCloseFails | parse-fail | overload | NONE | **4** |
| ParserActOnAssignSuccessBeforeFunctionCloseFails | parse-fail | identity | LocalDeclAndExprStmtAreSiblingsOnCompileSealPath | no |
| ParserActOnVariableAccessBeforeFunctionCloseFails | parse-fail | identity | ConstGlobalTraitAndMutableReject / local DeclRef incidental | no |
| ParserActOnScopedVariableAccessBeforeFunctionCloseFails | parse-fail | identity | NamespaceOverloadSelectsScopedFunctionNotGlobal is **function**; qualified `Game::X` const var NONE compile-seal (not bite 3 shadowing) | no |
| ParserActOnVariableAccessDoesNotDuplicateOnSuccessfulParse | parse+seal | identity | LocalDeclAndExprStmtAreSiblingsOnCompileSealPath | no |
| ParserActOnBareReturnBeforeFunctionCloseFails | parse-fail | control | IfStmtRecordsNamedThenElseOnCompileSealPath | no |
| ParserActOnNestedReturnDoesNotStealFunctionBody | parse-fail | identity | IfStmtRecordsNamedThenElseOnCompileSealPath | no |
| ParserActOnConstructCallBeforeArgListCloseFails | parse-fail | overload | ConstructorOverloadsSelectExactCtorNotFirstName | no |
| ParserActOnBreakRecordsWhileTargetBeforeBodyCloseFails | parse-fail | control | ContinueTargetsEnclosingWhileOnCompileSealPath (while present); BreakTargetsNearestSwitchNotOuterLoop is switch | no |
| ParserActOnContinueRecordsForTargetBeforeBodyCloseFails | parse-fail | control | ForStmtRecordsNamedPhasesOnCompileSealPath | no |
| ParserActOnBreakRecordsSwitchTargetOnSuccessfulParse | parse+seal | control | BreakTargetsNearestSwitchNotOuterLoop | no |
| ParserActOnMemberOverloadCallBeforeArgListCloseFails | parse-fail | overload | MemberPostfixCallInternsOnceWithoutReceiverLessCallOnCompileSealPath | no |
| ParserActOnBinaryOverloadBeforeFunctionCloseFails | parse-fail | overload | OperatorMinusSelectsOpSubNotBuiltinBinary | no |
| ParserActOnListPatternBeforeBlockCloseFails | parse-fail | identity | ListPatternRecordsStructuredNodes | no |
| SemaStartParamDeclDistinctRangeDuplicateCreatesSecondParam | construction-API | identity | NONE (duplicate-param diagnostic; Seal structural) | no |
| SemaStartParamDeclAnonymousParamsStayDistinct | construction-API | identity | NONE | no |
| SemaStartParamDeclSameAuthoredRangeReplayReusesWithoutDuplicateDiagnostic | construction-API | identity | NONE | no |
| SemaStartEnumeratorDeclDistinctRangeDuplicateCreatesSecondVar | construction-API | identity | NONE | no |

`SemaStart*` / mid-parse fail / DoesNotDuplicate rows are **Parser action identity**. Leave them. They are not missing compile-seal overload/conversion/call/lifetime oracles except where Exclusive is `1`/`2`/`3`/`4`/`later`.

---

## Out-of-filter companions (not matrix rows)

| TEST_METHOD | Path | Note |
| --- | --- | --- |
| ParserCapturingLambdaRecordsCaptureOnSealedDump | parse+seal | Bite 2 fixture; not `Build()` |
| ParserSiblingLambdasEachRecordCaptureX | parse+seal | sibling `captures=X` |
| MultipleLambdasKeepDistinctStableKeys | parse+seal | lambda **keys**, no capture |
| TemplateContainerTypeKeyIsArrayIntNotBareArray | parse+seal | `type=array<int>`; not compile-seal |
| SequenceSameBeginDifferentEndInternsDistinctNodes | construction-API | kind+begin+end; do not globally full-span FindExistingExpr |
| CompileSealAssignConversionDumpsNamedSrcAndDestTypes | Build+retain | **243rd**, post-identity Bite 1 oracle |

---

## Return

- Matrix path: `D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\attachments\wave-b-seal-gap.md`
- Matching filter rows: **163**
- `WithoutScriptNode` tests: **53**
- Matching rows with no compile-seal counterpart at identity cutoff: **33**
- Exclusive bites: **1 corrected** (live oracle already on disk — do not duplicate); **2, 3, 4 confirmed**. No fifth bite. Not 13.2.
