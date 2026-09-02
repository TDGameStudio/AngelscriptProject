# Wave B results (SemaAuthority)

Worktree: `D:\as-cta`. Do not treat this as 5.9 complete-language Sema. Do not check 13.2 / 4.2 / 5.9 from these greens.

## B-packed-exec (2026-08-23) — LANDED execute 1934/902, not 13.2

Packed int8/int16 WRTV1/WRTV2 **execute** now matches opcode. Root cause was **not** WRTV4 smash and **not** int8 padding.

TDD:

- Restore `RunPacked()==1934` / `RunPair16()==902`. RED `wave-b-packed-exec-red-prod2` **47/48** `got=0` (assert path hid execute-ok).
- Probe `wave-b-packed-probe`: **ran=1 got=1000**. Opcode WRTV1/RDR1 on SetB/GetA. RunPacked bytecode had **one MULi and no ADDi** — return interned as `p.A * 1000` only. WRTV1 path writes A.
- After BINARY spanning-range (op mismatch vs `*`): **got=1009034**. Full ADD/MUL emitted but **left-to-right** intern of flat `snExpression` (`(A*1000+B)*1000 + C*10 + D`).
- Fix: intern `snExpression` with the same shunting-yard precedence as `asCCompiler::ConvertToPostFix` / `GetPrecedence`. WalkOne `snExpression` calls `ActOnExprFromNode`. Do **not** globally full-span `FindExistingExpr`.

RED: `Saved/Tests/wave-b-packed-exec-red-prod2/20260823_001310_787_b803f29b`. Probe: `Saved/Tests/wave-b-packed-probe/20260823_001652_919_465b0534` got=1000; `wave-b-packed-probe2` got=1009034.

GREEN:

| Prefix | Label | Result | Report |
| --- | --- | --- | --- |
| ProductionCodeGen | `wave-b-packed-exec-prod` | **48/48** (RunPacked 1934, RunPair16 902, WRTV1/WRTV2 opcode lock) | `Saved/Tests/wave-b-packed-exec-prod/20260823_002843_247_9f93bbb5` |
| CanonicalAST | `wave-b-packed-exec-canonicalast` | **321/321** | `Saved/Tests/wave-b-packed-exec-canonicalast/20260823_002917_849_eb2de15a` |
| Compiler | `wave-b-packed-exec-compiler` | **511/511** (ReportJson; TypedSemanticIR SourceProvenance may warn) | `Saved/Tests/wave-b-packed-exec-compiler/20260823_003000_825_096f9b5d` |

Scratch: `{SCRATCH}/wave-b-packed-exec/`.

**13.2 stays `[ ]`.** LEGACY still `asCCompiler`. 9.2 remains 虚标 until rereview (12-byte COPY / register 4-or-8 leftovers). Packed execute is a slice.

## B-construct-init (2026-08-22) — LANDED, not 13.2

`HasConstructAssignTo` consumes VAR `inits` CONSTRUCT (unwrap Materialize/Cleanup). No `GetStmtCount` scan. `AppendDefaultValueConstruct` / explicit local init `AddDeclInit`. `PropertyFromFieldDecl` matches sealed `byteOffset` (fail-closed if `< 0`). `EmitMember` / `EmitMemberStore` sealed offset only.

RED: SemaAuthority `wave-b-construct-init-red-sema` — `CompileSealValueLocalDefaultConstructRecordsInitOnVar` (`FValue Object;` dump had no `init=` on VAR).

Packed execute TDD: ProductionCodeGen `wave-b-packed-exec-red-prod` **47/48** — `CanonicalPackedInt8MemberStoreUsesWrtv1NotWrtv4` execute `got=0` vs 1934. Opcode WRTV1 still GREEN. Execute oracles **reverted** so prefixes stay green. Report: `Saved/Tests/wave-b-packed-exec-red-prod/20260822_234717_191_3cdf7074`. **OPEN.**

GREEN:

| Prefix | Label | Result | Report |
| --- | --- | --- | --- |
| SemaAuthority | `wave-b-construct-init-sema` | **250/250** | `Saved/Tests/wave-b-construct-init-sema/20260822_234506_050_24dbe1b2` |
| ProductionCodeGen | `wave-b-construct-init-prod` | **48/48** | `Saved/Tests/wave-b-construct-init-prod/20260822_234556_610_de66c128` |
| CanonicalAST | `wave-b-construct-init-canonicalast` | **321/321** | `Saved/Tests/wave-b-construct-init-canonicalast/20260822_235221_471_bd52dfa4` |
| Compiler | `wave-b-construct-init-compiler` | **511/511** (ReportJson; runner may `succeededWithWarnings=1`) | `Saved/Tests/wave-b-construct-init-compiler/20260822_235313_198_5e97b76a` |

**13.2 stays `[ ]`.** LEGACY still `asCCompiler`. Packed execute 1934 OPEN. Accessor name-strip / `fieldOffsets[]` miss remain.

## B-global-bind (2026-08-22) — LANDED, not 13.2

Host globals intern and bind by unique signature (name + param/return types + in-out), not first SYSTEM name+arity. `InternNativeGlobals` no longer skips `HostPick(int)` after `HostPick(bool)`. `FindRegisteredGlobalFunction` unique-matches like methods. Did **not** store `asCScriptFunction*` on sealed decls.

RED: ProductionCodeGen `wave-b-global-bind-red-prod` **47/48** fail 1 — `CanonicalNativeSameArityGlobalExecutesSelectedNotFirstRegistered` (`unresolved-callee:HostPick`, intern skipped same-arity). Report: `Saved/Tests/wave-b-global-bind-red-prod/20260822_233327_879_bcb5e23e`.

GREEN:

| Prefix | Label | Result | Report |
| --- | --- | --- | --- |
| ProductionCodeGen | `wave-b-global-bind-prod` | **48/48** (`HostPick(41)` execute 42, CALLSYS int not bool) | `Saved/Tests/wave-b-global-bind-prod/20260822_233549_310_4d478e25` |
| SemaAuthority | `wave-b-global-bind-sema` | **249/249** | `Saved/Tests/wave-b-global-bind-sema/20260822_233631_289_f919cfb7` |
| CanonicalAST | `wave-b-global-bind-canonicalast` | **320/320** | `Saved/Tests/wave-b-global-bind-canonicalast/20260822_233718_448_deef8a88` |
| Compiler | `wave-b-global-bind-compiler` | **510/510** (`succeeded=509`, `succeededWithWarnings=1`) | `Saved/Tests/wave-b-global-bind-compiler/20260822_233807_864_0c9931b6` |

Scratch: `{SCRATCH}/wave-b-global-bind/`.

**13.2 stays `[ ]`.** LEGACY still `asCCompiler`. `HasConstructAssignTo` scan and ordinal field remain.

## B-declcontext (2026-08-22) — LANDED, not 13.2

`LookupInScope` grovels sealed `scope->children` by name (Clang `DeclContext::lookup` / `localUncachedLookup` shape). Intern-time `symbols[]` is no longer the lookup source. Construction-API `CreateDecl(FUNCTION)` without `InsertSymbol` resolves.

RED: SemaAuthority `wave-b-declcontext-red-sema` **248/249** fail 1 — `SemaLookupInScopeFindsChildFunctionWithoutInsertSymbol` (`LookupInScope must grovel TU children, not only symbols[]`). Report: `Saved/Tests/wave-b-declcontext-red-sema/20260822_232505_535_c4b76a2b`.

GREEN:

| Prefix | Label | Result | Report |
| --- | --- | --- | --- |
| SemaAuthority | `wave-b-declcontext-sema` | **249/249** | `Saved/Tests/wave-b-declcontext-sema/20260822_232638_984_8e75e1e4` |
| CanonicalAST | `wave-b-declcontext-canonicalast` | **319/319** | `Saved/Tests/wave-b-declcontext-canonicalast/20260822_232729_167_7be7bfef` |
| Compiler | `wave-b-declcontext-compiler` | **509/509** (`succeeded=508`, `succeededWithWarnings=1`) | `Saved/Tests/wave-b-declcontext-compiler/20260822_232819_095_a3c3c27e` |

Scratch copies: `{SCRATCH}/wave-b-declcontext/*-Summary.json`.

**13.2 stays `[ ]`.** LEGACY still `asCCompiler`. Global bind still name+arity. `HasConstructAssignTo` scan and ordinal field remain.

## B-sealed-env (2026-08-22) — LANDED, not 13.2

CodeGen consumes sealed `break`/`continue` `target=`. `EmitSwitch` + `PushLoop(switchId, end, continueLabel=-1)`. `FindBreakLabel` / `FindContinueLabel` no longer return `loops[last]`. Execute `while { switch { break } }` is **21** (`1+10+10`), not while-break **1**. After-switch `n=7` is **7**, not while-break **0**.

RED (tests first, no `EmitSwitch`): ProductionCodeGen `wave-b-sealed-env-prod` **45/47** fail 2 — both new methods `Build != 0` on `STMT_SWITCH` default.

GREEN:

| Prefix | Label | Result | Report |
| --- | --- | --- | --- |
| ProductionCodeGen | `wave-b-sealed-env-prod` | **47/47** | `Saved/Tests/wave-b-sealed-env-prod/20260822_231740_277_92ebbedb` |
| SemaAuthority | `wave-b-sealed-env-sema` | **248/248** | `Saved/Tests/wave-b-sealed-env-sema/20260822_231850_753_1b9e3f55` |
| CanonicalAST | `wave-b-sealed-env-canonicalast` | **318/318** | `Saved/Tests/wave-b-sealed-env-canonicalast/20260822_231938_056_5745430a` |
| Compiler | `wave-b-sealed-env-compiler` | **508/508** (`succeeded=507`, `succeededWithWarnings=1`) | `Saved/Tests/wave-b-sealed-env-compiler/20260822_232026_105_078bc2de` |

Scratch copies: `{SCRATCH}/wave-b-sealed-env/*-Summary.json`.

**13.2 stays `[ ]`.** LEGACY still `asCCompiler`. `LookupInScope` still `symbols[]`. `FindRegisteredGlobalFunction` still name+arity. 9.3 remains 虚标 (one switch fixture, not full control matrix).

## B-authority-types (2026-08-22)

Compile→seal dumps now print interned QualType keys on expressions (`type=int` / `dest=float` / `src=int`) instead of snapshot-local numeric intern ids. Mixin dump stays valid when CodeGen fail-closes `DECL_MIXIN`. Production CodeGen CALL of `Entry()` matches dump-selected `F(int)`, not first-name `F(float)`.

- RED SemaAuthority `wave-b-authority-red`: **130/127/3** — `CompileSealCallDumpsNamedResultTypeKey`, `CompileSealConversionDumpsNamedSrcAndDestTypes` (Build-required; later dump-even-if-fail-closed), and F1-regressed `MixinFunctionKeepsMixinKindAndSignature`.
- GREEN SemaAuthority `wave-b-authority-green`: **130/130** — `D:\as-cta\Saved\Tests\wave-b-authority-green\20260822_051151_098_c76968bd`
- GREEN ProductionCodeGen `wave-b-overload-id`: **25/25** — `D:\as-cta\Saved\Tests\wave-b-overload-id\20260822_051231_911_0e63aab4`
- GREEN CanonicalAST `wave-b-canonicalast-authority`: **170/170** — `D:\as-cta\Saved\Tests\wave-b-canonicalast-authority\20260822_051312_986_a51af471`

**13.2 / 13.3 stay `[ ]`.** Parser `ActOnParsed*` is still FromNode. LEGACY Bytecode still `asCCompiler`. Identity 8/8 is still snapshot FunctionKey↔AST, not a 13.3 close.

## B-acton-walkone (2026-08-22)

Move remaining WalkOne-only list-pattern intern onto Parser Sema actions. Incomplete `{1, 2` (missing `}`) now intern `literal=list-pattern` + `args=1,2` without a complete function body WalkOne. Member overload `v.Get(3` and binary `v - 3` were already interned during parse (locks, not new FromNode).

- RED SemaAuthority `wave-b-acton-red`: **132/133** — only `ParserActOnListPatternBeforeBlockCloseFails`
- GREEN SemaAuthority `wave-b-acton-green`: **133/133**
- GREEN CanonicalAST `wave-b-acton-canonical`: **173/173**
- GREEN Compiler `wave-b-acton-compiler`: **361/361**

Parser: local `ParseDeclaration` calls `ActOnParsedStmt` after `ParseInitList` (including syntax-error lists). `ParseExprTerm` init-list arms call `ActOnParsedExpr`. Sema reuses list-pattern CONSTRUCT by range so complete-body WalkOne does not duplicate.

**Still not 13.2 / 13.3.** Do not check those boxes.

## B-call-expr (2026-08-22)

Dedicated Clang-shaped `asCSema::ActOnCallExpr(owner, name, args, range, implicitReceiver)`. Tests intern selected overload and named conversion **without** a script node / FromNode. `snFunctionCall` FromNode now reorders named/default args then returns `ActOnCallExpr`.

- RED SemaAuthority `wave-b-call-expr-red`: **133/135** — only `SemaCallExprActionSelectsIntOverloadWithoutScriptNode` and `SemaCallExprActionInsertsNamedConversionWithoutScriptNode` (`IsValid` false while stub returned empty id).
- GREEN SemaAuthority `wave-b-call-expr-green`: **135/135** — `D:\as-cta\Saved\Tests\wave-b-call-expr-green\20260822_053200_808_fb229432`
- Post-wiring re-run (Task 1, exclusive UBT `B-dedicated-actions`):
  - SemaAuthority `wave-b-call-expr-sema-rerun`: **135/135** — `D:\as-cta\Saved\Tests\wave-b-call-expr-sema-rerun\20260822_054331_863_6031d322` (`Summary.json` next to the label dir)
  - CanonicalAST `wave-b-call-expr-canonical`: **175/175** — `D:\as-cta\Saved\Tests\wave-b-call-expr-canonical\20260822_054420_115_a296a891` (was 173 pre-`ActOnCallExpr`; +2 dedicated CallExpr methods; ProductionCodeGen still 25)
  - Compiler `wave-b-call-expr-compiler`: **363/363** — `D:\as-cta\Saved\Tests\wave-b-call-expr-compiler\20260822_054501_427_d075ca76` (was 361 pre-`ActOnCallExpr`)

`ActOnParsedExpr` / `ActOnParsedStmt` still call FromNode for every listed kind and default. Cast / construct / return intern still FromNode. **13.2 / 13.3 stay `[ ]`.**

## B-dedicated-actions (2026-08-22)

Clang-shaped dedicated Sema actions intern cast / construct / return without `ActOn*FromNode`. `ActOnParsedExpr` / `ActOnParsedStmt` dispatch `snCast` / `snConstructCall` / `snReturn` to those APIs. FromNode remains recovery for leftover kinds.

- RED `wave-b-dedicated-red` (build): compile fail `C2039: ActOnCastExpr is not a member of asCSema` at `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp(2413)` — `D:\as-cta\Saved\Build\wave-b-dedicated-red\20260822_054750_183_5be9428d`. Tests were added before `as_sema*` implementation.
- GREEN SemaAuthority `wave-b-dedicated-green`: **138/138** — `D:\as-cta\Saved\Tests\wave-b-dedicated-green\20260822_055134_681_92fc290c` (135 + 3: `SemaCastActionInsertsNamedConversionWithoutScriptNode`, `SemaConstructActionSelectsIntCtorWithoutScriptNode`, `SemaReturnStmtActionRecordsValueWithoutScriptNode`)
- GREEN CanonicalAST `wave-b-dedicated-canonical`: **178/178** — `D:\as-cta\Saved\Tests\wave-b-dedicated-canonical\20260822_055216_728_37a2b908`
- GREEN Compiler `wave-b-dedicated-compiler`: **366/366** — `D:\as-cta\Saved\Tests\wave-b-dedicated-compiler\20260822_055256_447_df3c1363`

Dedicated `ActOnCastExpr` interns Conversion (`dest=float` `src=int`) with no script node. `ActOnConstruct` already selected `T::T(int)` over first-name `T::T(float)`. `ActOnReturnStmt` dumps `kind=Return` with no FromNode. `ActOnParsedExpr` dispatches `snCast` / `snConstructCall` to those actions; `snFunctionCall` still ends in `ActOnCallExpr`. `ActOnParsedStmt` dispatches `snReturn` to `ActOnReturnStmt`. FromNode remains recovery for leftover kinds (assignment, control, lambda, members, logical, conditional, foreach, …). LEGACY Bytecode still `asCCompiler`.

**13.2 / 13.3 / 4.2 / 5.9 stay `[ ]`.**

## B-assign-expr (2026-08-22)

Dedicated `asCSema::ActOnAssignExpr(lhs, rhs, range)` intern conversion and property Set without FromNode. `ActOnParsedExpr` `snAssignment` extracts children then calls `ActOnAssignExpr`. FromNode `snAssignment` also returns `ActOnAssignExpr`.

- RED `wave-b-assign-red` (build): compile fail `C2039: ActOnAssignExpr is not a member of asCSema` at both new tests — `D:\as-cta\Saved\Build\wave-b-assign-red\20260822_055619_621_3cde877b`
- GREEN SemaAuthority `wave-b-assign-green`: **140/140** — `D:\as-cta\Saved\Tests\wave-b-assign-green\20260822_055727_208_c44d8747` (138 + `SemaAssignActionInsertsNamedConversionWithoutScriptNode` + `SemaAssignActionRewritesPropertySetWithoutScriptNode`)
- GREEN CanonicalAST `wave-b-assign-canonical`: **180/180** — `D:\as-cta\Saved\Tests\wave-b-assign-canonical\20260822_055809_132_92e3e238`
- GREEN Compiler `wave-b-assign-compiler`: **368/368** — `D:\as-cta\Saved\Tests\wave-b-assign-compiler\20260822_055849_419_39aa73d6`

**13.2 / 13.3 stay `[ ]`.** Next leftover was binary/logical (now landed).

## B-binary-logical (2026-08-22)

Dedicated `asCSema::ActOnBinaryExpr(lhs, op, rhs, range)` selects operator methods (`T::opSub(int)` not first-name float). `ActOnLogicalExpr` intern `kind=Logical`. `ActOnParsedExpr` dispatches `snExpression`. `snAssignment` leftover: 3-child assign and 2-child incomplete `i =` go through `ActOnAssignExpr`; 1-child ParseAssignment wrapper is pass-through (not an Assign intern).

- RED `wave-b-binary-red` (build): compile fail `C2039: ActOnBinaryExpr` / `ActOnLogicalExpr` — `D:\as-cta\Saved\Build\wave-b-binary-red\20260822_060249_818_e41cbfa6`
- Intermediate RED SemaAuthority `wave-b-binary-green` first run: **123/142** — 1-child `snAssignment` wrappers were interned as Assign with an empty rhs (`expr-operand`). Fixed by pass-through.
- GREEN SemaAuthority `wave-b-binary-green`: **142/142** — `D:\as-cta\Saved\Tests\wave-b-binary-green\20260822_060927_515_0de2ba8a`
- GREEN CanonicalAST `wave-b-binary-canonical`: **182/182** — `D:\as-cta\Saved\Tests\wave-b-binary-canonical\20260822_061008_075_c5689613`
- GREEN Compiler `wave-b-binary-compiler`: **370/370** — `D:\as-cta\Saved\Tests\wave-b-binary-compiler\20260822_061059_732_1eabf18f`

**13.2 / 13.3 stay `[ ]`.** Next leftover was if/loop/switch (now landed).

## B-control-stmt (2026-08-22)

Dedicated `ActOnIfStmt` / `ActOnWhileStmt` / `ActOnForStmt` / `ActOnSwitchStmt` intern control without FromNode. `ActOnParsedStmt` dispatches `snIf` / `snWhile` / `snFor` / `snSwitch`. WalkOne early-returns a filled If/Switch so then/case children are not interned twice (first GREEN attempt **139/146** failed Seal with `stmt-multi-owner` / unsealed publication).

- RED `wave-b-control-red` (build): C2039 `ActOnIfStmt` / `ActOnWhileStmt` / `ActOnForStmt` / `ActOnSwitchStmt` — `D:\as-cta\Saved\Build\wave-b-control-red\20260822_061457_150_67688a4a`
- GREEN SemaAuthority `wave-b-control-green`: **146/146** — `D:\as-cta\Saved\Tests\wave-b-control-green\20260822_062049_260_a9fbc18f`
- GREEN CanonicalAST `wave-b-control-canonical`: **186/186** — `D:\as-cta\Saved\Tests\wave-b-control-canonical\20260822_062131_182_edf7fb2d`
- GREEN Compiler `wave-b-control-compiler`: **374/374** — `D:\as-cta\Saved\Tests\wave-b-control-compiler\20260822_062213_837_c90380dd`

**13.2 / 13.3 stay `[ ]`.** Next leftover was do-while / foreach / lambda (now landed).

## B-dowhile-foreach-lambda (2026-08-22)

Dedicated `ActOnDoWhileStmt` / `ActOnForeachStmt` / `ActOnLambdaExpr` intern without FromNode. `ActOnParsedStmt` dispatches `snDoWhile` / `snForEach`. `ActOnLambdaFromNode` extracts then `ActOnLambdaExpr`. WalkOne `snFunction` with identifier `function` uses the lambda path. Named functions stay on `ActOnFunctionLike`.

- RED `wave-b-dfl-red` (build): C2039 `ActOnDoWhileStmt` / `ActOnForeachStmt` / `ActOnLambdaExpr` — `D:\as-cta\Saved\Build\wave-b-dfl-red\20260822_062612_433_f6d7cbff`
- GREEN SemaAuthority `wave-b-dfl-green`: **149/149** — `D:\as-cta\Saved\Tests\wave-b-dfl-green\20260822_063949_024_c369af51` (146 + `SemaDoWhileStmtActionRecordsCondWithoutScriptNode` + `SemaForeachStmtActionRecordsRangeWithoutScriptNode` + `SemaLambdaExprActionRecordsDeclWithoutScriptNode`)
- GREEN CanonicalAST `wave-b-dfl-canonical`: **189/189** — `D:\as-cta\Saved\Tests\wave-b-dfl-canonical\20260822_064035_430_b95b5394`
- GREEN Compiler `wave-b-dfl-compiler`: **377/377** — `D:\as-cta\Saved\Tests\wave-b-dfl-compiler\20260822_064117_228_4ac34d5b`

**13.2 / 13.3 stay `[ ]`.** Next leftover was `snExprTerm` member/index/unary (now landed).

## B-member-index-unary (2026-08-22)

Dedicated `ActOnMemberExpr` / `ActOnIndexExpr` / `ActOnUnaryExpr` intern property Get (`T::GetValue()`), selected `T::opIndex(int)`, and `T::opNeg()` without FromNode. `snExprTerm` FromNode extract now calls those APIs.

- RED `wave-b-member-red` (build): C2039 `ActOnMemberExpr` / `ActOnIndexExpr` / `ActOnUnaryExpr` — `D:\as-cta\Saved\Build\wave-b-member-red\20260822_064408_352_e2b1d354`
- GREEN SemaAuthority `wave-b-member-green`: **152/152** — `D:\as-cta\Saved\Tests\wave-b-member-green\20260822_064613_006_5a651da2` (149 + 3)
- GREEN CanonicalAST `wave-b-member-canonical`: **192/192** — `D:\as-cta\Saved\Tests\wave-b-member-canonical\20260822_064657_512_b397ac0b`
- GREEN Compiler `wave-b-member-compiler`: **380/380** — `D:\as-cta\Saved\Tests\wave-b-member-compiler\20260822_064749_172_9bc71edf`

**13.2 / 13.3 stay `[ ]`.** Next leftover was `ActOnQualType` (now landed).

## B-qualtype (2026-08-22)

Dedicated `ActOnQualType(key, quals)` intern primitive / const / `array<int>` template keys without a script node. `ActOnQualTypeFromNode` extracts then `ActOnQualType`.

- RED `wave-b-qualtype-red` (build): C2039 `ActOnQualType` — `D:\as-cta\Saved\Build\wave-b-qualtype-red\20260822_065120_516_77d25810`
- GREEN SemaAuthority `wave-b-qualtype-green`: **154/154** — `D:\as-cta\Saved\Tests\wave-b-qualtype-green\20260822_065228_812_cbd76a44`
- GREEN CanonicalAST `wave-b-qualtype-canonical`: **194/194** — `D:\as-cta\Saved\Tests\wave-b-qualtype-canonical\20260822_065312_317_1f20d118`
- GREEN Compiler `wave-b-qualtype-compiler`: **382/382** — `D:\as-cta\Saved\Tests\wave-b-qualtype-compiler\20260822_065355_711_49f2ceba`

**13.2 / 13.3 stay `[ ]`.** Next leftover was `ActOnDeclRefExpr` (now landed).

## B-declref (2026-08-22)

Dedicated `ActOnDeclRefExpr(owner, name, range)` intern lookup via `LookupCandidatesFrom`, preferring `VAR`. Inner namespace `Game::x` (`float`) wins over outer `x` (`int`). `snVariableAccess` FromNode extract then `ActOnDeclRefExpr`.

- RED `wave-b-declref-red` (build): C2039 `ActOnDeclRefExpr` — `D:\as-cta\Saved\Build\wave-b-declref-red\20260822_065602_882_311dc228`
- GREEN SemaAuthority `wave-b-declref-green`: **155/155** — `D:\as-cta\Saved\Tests\wave-b-declref-green\20260822_065721_469_26a55a1d`
- GREEN CanonicalAST `wave-b-declref-canonical`: **195/195** — `D:\as-cta\Saved\Tests\wave-b-declref-canonical\20260822_065806_069_137165e7`
- GREEN Compiler `wave-b-declref-compiler`: **383/383** — `D:\as-cta\Saved\Tests\wave-b-declref-compiler\20260822_065851_097_aee9e223`

**13.2 / 13.3 stay `[ ]`.** Next leftover was local decl / init-list (now landed).

## B-local-initlist (2026-08-22)

Dedicated `ActOnLocalDeclStmt` / `ActOnInitList` intern a local `Var name=i` plus sibling Assign, and `literal=list-pattern args=1,2`, without FromNode. `ActOnParsedStmt` `snDeclaration` and `ActOnParsedExpr` `snInitList` extract then dedicated. CodeGen `STMT_DECL` only allocates a slot; init assign is a sibling `STMT_EXPR` (`EmitLocalDeclStmts`). Nested Block children hid those siblings (CanonicalAST **187/197**); flat siblings restored production assign.

- RED `wave-b-local-red` (build): C2039 `ActOnLocalDeclStmt` / `ActOnInitList`
- GREEN SemaAuthority `wave-b-local-green`: **157/157** — `D:\as-cta\Saved\Tests\wave-b-local-green\20260822_070630_759_74e17105`
- GREEN CanonicalAST `wave-b-local-canonical2`: **197/197** — `D:\as-cta\Saved\Tests\wave-b-local-canonical2\20260822_070924_650_b943120f`
- GREEN Compiler `wave-b-local-compiler`: **385/385** — `D:\as-cta\Saved\Tests\wave-b-local-compiler\20260822_071011_966_89725f18`

**13.2 / 13.3 stay `[ ]`.** Next leftover: Break / Continue / Fallthrough (`attachments/wave-b-control-jump-next.md`).

## B-control-jump (2026-08-22)

Dedicated `ActOnBreakStmt` / `ActOnContinueStmt` / `ActOnFallthroughStmt` intern control jumps without FromNode. Tests `PushControl` the filled While/For after `ActOnWhileStmt`/`ActOnForStmt` Pop, then `NearestControl` records `target=`. Fallthrough intern is `kind=Fallthrough` only (`target=` stays FinishSwitchStmt / 5.6). `ActOnParsedStmt` dispatches `snBreak`/`snContinue`/`snFallthrough`; FromNode leftover extract-then-dedicated. FindExisting so WalkOne does not intern twice.

- RED `wave-b-ctrl-red` (build): C2039 `ActOnBreakStmt` / `ActOnContinueStmt` / `ActOnFallthroughStmt` — `D:\as-cta\Saved\Build\wave-b-ctrl-red\20260822_072128_777_b92ad4c4`
- Impl build `wave-b-ctrl-impl`: `D:\as-cta\Saved\Build\wave-b-ctrl-impl\20260822_072437_099_5a8eb91b`
- GREEN SemaAuthority `wave-b-ctrl-green`: **160/160** — `D:\as-cta\Saved\Tests\wave-b-ctrl-green\20260822_072515_075_3d0a4d9c` (`Summary.json` under the label dir). First same-label run `20260822_072304_495_15011da8` was **157/157** on the pre-impl binary (RunTests does not UBT).
- GREEN CanonicalAST `wave-b-ctrl-canonical`: **200/200** — `D:\as-cta\Saved\Tests\wave-b-ctrl-canonical\20260822_072602_586_ac225b7c`
- GREEN Compiler `wave-b-ctrl-compiler`: **388/388** — `D:\as-cta\Saved\Tests\wave-b-ctrl-compiler\20260822_072642_078_5b0fe3f8`

**13.2 / 13.3 / 10.2 / 9.5 / 5.6 stay `[ ]`.** FromNode remains recovery for ternary, float/string/`nullptr` literals, expr-stmt, Case, and WalkOne body leftover. LEGACY Bytecode still `asCCompiler`.

## B-conditional-expr (2026-08-22)

Dedicated `ActOnConditionalExpr(cond, then, else, range)` intern `kind=Conditional` without FromNode. Arms keep already-selected `callee=F(int)` / `callee=G(int)` (not first-name `F(float)`). Result QualType comes from the then-arm; mismatched else is `ActOnConversion`. `ActOnParsedExpr` `snCondition` extract-then-dedicated; incomplete `?:` still first-child recovery. FindExisting so WalkOne does not intern twice.

- RED `wave-b-cond-red` (build): C2039 `ActOnConditionalExpr` — `D:\as-cta\Saved\Build\wave-b-cond-red\20260822_073112_261_6218f242`
- Impl build `wave-b-cond-impl`: `D:\as-cta\Saved\Build\wave-b-cond-impl\20260822_073257_787_87fc3b6c`
- Stale SemaAuthority `wave-b-cond-green` **160/160** was pre-impl binary (`RunTests.ps1` does not UBT)
- GREEN SemaAuthority `wave-b-cond-sema`: **161/161** — `D:\as-cta\Saved\Tests\wave-b-cond-sema\20260822_073325_294_4c929fed`
- GREEN CanonicalAST `wave-b-cond-canonical`: **201/201** — `D:\as-cta\Saved\Tests\wave-b-cond-canonical\20260822_073405_158_4ef1111f`
- GREEN Compiler `wave-b-cond-compiler`: **389/389** — `D:\as-cta\Saved\Tests\wave-b-cond-compiler\20260822_073445_437_57e47702`

**13.2 / 13.3 / 10.2 / 9.5 / 5.6 stay `[ ]`.** Next leftover: float/string/`nullptr` literals, then ExprStmt / Case / WalkOne body.

## B-literal-rest (2026-08-22)

Dedicated `ActOnFloatLiteral` / `ActOnStringLiteral` / `ActOnNullLiteral` intern float/string/`nullptr` without FromNode. Fork token is `nullptr` (`ttNull`); do not intern script `null` as a language feature. `ActOnParsedExpr` `snConstant` extract-then-dedicated; FromNode leftover extract-then-dedicated. int/bool stay on already-landed `ActOnIntegerLiteral` / `ActOnBoolLiteral`.

- RED `wave-b-lit-red` (build): C2039 `ActOnFloatLiteral` / `ActOnStringLiteral` / `ActOnNullLiteral` — `D:\as-cta\Saved\Build\wave-b-lit-red\20260822_073926_255_39a68290`
- Impl build `wave-b-lit-impl`: `D:\as-cta\Saved\Build\wave-b-lit-impl\20260822_074014_123_b3bbf470`
- GREEN SemaAuthority `wave-b-lit-sema`: **164/164** — `D:\as-cta\Saved\Tests\wave-b-lit-sema\20260822_074043_720_f0c75cfe`
- GREEN CanonicalAST `wave-b-lit-canonical`: **204/204** — `D:\as-cta\Saved\Tests\wave-b-lit-canonical\20260822_074127_085_194cab96`
- GREEN Compiler `wave-b-lit-compiler`: **392/392** — `D:\as-cta\Saved\Tests\wave-b-lit-compiler\20260822_074208_275_3d7768aa`

**13.2 / 13.3 / 10.2 / 9.5 / 5.6 stay `[ ]`.** Next leftover: ExprStmt dispatch / Case peel / WalkOne body attach.

## B-exprstmt-case-body (2026-08-22)

Dedicated `ActOnExpressionStmt` / `ActOnCaseStmt` / `ActOnCompoundStmt` intern ExprStmt / Case / Block without FromNode as intern. `ActOnParsedStmt` dispatches `snExpressionStatement` / `snCase`. FromNode leftover extract-then-dedicated. WalkOne `SetBody` attaches the interned compound; block intern uses `ActOnCompoundStmt` so locals stay flat siblings.

- RED `wave-b-stmt-red` (build): C2039 `ActOnExpressionStmt` / `ActOnCaseStmt` / `ActOnCompoundStmt` — `D:\as-cta\Saved\Build\wave-b-stmt-red\20260822_074712_333_41b7df5c`
- Impl build `wave-b-stmt-impl`: `D:\as-cta\Saved\Build\wave-b-stmt-impl\20260822_074925_115_d8af3116`
- GREEN SemaAuthority `wave-b-stmt-sema`: **167/167** — `D:\as-cta\Saved\Tests\wave-b-stmt-sema\20260822_074952_524_57c73121`
- GREEN CanonicalAST `wave-b-stmt-canonical`: **207/207** — `D:\as-cta\Saved\Tests\wave-b-stmt-canonical\20260822_075034_363_27f79567`
- GREEN Compiler `wave-b-stmt-compiler`: **395/395** — `D:\as-cta\Saved\Tests\wave-b-stmt-compiler\20260822_075116_480_521734e0`

**13.2 / 13.3 / 10.2 / 9.5 / 5.6 stay `[ ]`.** Next leftover: named-decl WalkOne extract.

## B-walkone-decl (2026-08-22)

Dedicated Clang-shaped `ActOnStartNamespaceDecl` / `ActOnStartClassDecl` / `ActOnStartEnumDecl` intern named decls without WalkOne as intern. FindExisting so Parser ActOn + WalkOne do not intern twice. WalkOne `snNamespace` / `snClass` / `snEnum` extract-then-dedicated. Class still generates lifecycle/accessors after intern. Enumerators still `ActOnVarDecl` under the enum.

- RED `wave-b-decl-red` (build): C2039 `ActOnStartNamespaceDecl` / `ActOnStartClassDecl` / `ActOnStartEnumDecl` — `D:\as-cta\Saved\Build\wave-b-decl-red\20260822_075531_496_2d65d4d8`
- Impl build `wave-b-decl-impl`: `D:\as-cta\Saved\Build\wave-b-decl-impl\20260822_075633_190_ec3f9af9`
- GREEN SemaAuthority `wave-b-decl-sema`: **170/170** — `D:\as-cta\Saved\Tests\wave-b-decl-sema\20260822_075706_279_36227df2`
- GREEN CanonicalAST `wave-b-decl-canonical`: **210/210** — `D:\as-cta\Saved\Tests\wave-b-decl-canonical\20260822_075758_008_8b77773a`
- GREEN Compiler `wave-b-decl-compiler`: **398/398** — `D:\as-cta\Saved\Tests\wave-b-decl-compiler\20260822_075844_631_2dca8608`

**13.2 / 13.3 / 10.2 / 9.5 / 5.6 stay `[ ]`.** Next leftover: interface/typedef/import WalkOne extract.

## B-walkone-decl-rest (2026-08-22)

Dedicated Clang-shaped `ActOnStartInterfaceDecl` / `ActOnStartTypedefDecl` / `ActOnStartImportDecl` intern those named decls without WalkOne as intern. FindExisting by name+kind so Parser ActOn + WalkOne do not intern twice. WalkOne `snInterface` / `snTypedef` / `snImport` extract-then-dedicated. Interface still records bases and walks members. Import still sets origin/type/params after intern. Script `funcdef` stays fork-rejected.

- RED `wave-b-decl-rest-red` (build): C2039 `ActOnStartInterfaceDecl` / `ActOnStartTypedefDecl` / `ActOnStartImportDecl` at SemaAuthority tests — `D:\as-cta\Saved\Build\wave-b-decl-rest-red\20260822_080316_872_180641cc`
- Impl build `wave-b-decl-rest-impl`: `D:\as-cta\Saved\Build\wave-b-decl-rest-impl\20260822_080707_137_f19f1d71`
- GREEN SemaAuthority `wave-b-decl-rest-sema`: **173/173** — `D:\as-cta\Saved\Tests\wave-b-decl-rest-sema\20260822_080744_633_d2d98f48`
- GREEN CanonicalAST `wave-b-decl-rest-canonical`: **213/213** — `D:\as-cta\Saved\Tests\wave-b-decl-rest-canonical\20260822_080832_169_18f4b70e`
- GREEN Compiler `wave-b-decl-rest-compiler`: **401/401** — `D:\as-cta\Saved\Tests\wave-b-decl-rest-compiler\20260822_080928_515_9a72bc13`

Scratch copies: `C:\Users\scottmei\AppData\Local\Temp\grok-goal-cafa12c46849\implementer\wave-b-decl-rest\`.

**13.2 / 13.3 / 10.2 / 9.5 / 5.6 stay `[ ]`.** Next leftover: function-like / global-var WalkOne extract, then `snExprTerm` postfix `()` / sequence.

## B-fn-var (2026-08-22)

Dedicated Clang-shaped `ActOnStartFunctionDecl` / `ActOnStartMethodDecl` / `ActOnStartVarDecl` intern those decls without WalkOne as intern. Function/method intern does **not** FindExisting by name (overloads). Var intern FindExisting by name+`VAR`. `ActOnFunctionLike` extract then dedicated; WalkOne global `snDeclaration` extract then `ActOnStartVarDecl`. Body attach still `ActOnStmtFromNode` → dedicated compound.

- RED `wave-b-fn-var-red` (build): C2039 `ActOnStartFunctionDecl` / `ActOnStartMethodDecl` / `ActOnStartVarDecl` — `D:\as-cta\Saved\Build\wave-b-fn-var-red\20260822_081354_103_ca7bf505`
- Impl build `wave-b-fn-var-impl`: `D:\as-cta\Saved\Build\wave-b-fn-var-impl\20260822_081452_623_97d480b2`
- GREEN SemaAuthority `wave-b-fn-var-sema`: **176/176** — `D:\as-cta\Saved\Tests\wave-b-fn-var-sema\20260822_081518_525_ded34c6b`
- GREEN CanonicalAST `wave-b-fn-var-canonical`: **216/216** — `D:\as-cta\Saved\Tests\wave-b-fn-var-canonical\20260822_081605_136_759e87a6`
- GREEN Compiler `wave-b-fn-var-compiler`: **404/404** — `D:\as-cta\Saved\Tests\wave-b-fn-var-compiler\20260822_081655_636_e998c6dc`

**13.2 / 13.3 / 10.2 / 9.5 / 5.6 stay `[ ]`.** Next leftover: `snExprTerm` postfix `()` / sequence (must reuse `ActOnCallExpr`, not builder `ActOnCall`).

## B-exprterm-postfix (2026-08-22)

Dedicated `ActOnPostfixCallExpr` intern leftover `snExprTerm` postfix `()` through already-landed `ActOnCallExpr` (overload re-select), not builder `ActOnCall` on the lhs `resolvedDecl`. Dedicated `ActOnSequenceExpr` intern `kind=Sequence`. FromNode extract-then-dedicated. First GREEN attempt **177/178**: CALL intern was `callee=F(int)`, but DeclRef still dumps first-name `callee=F(float)`; assertion tightened to the Call line.

- RED `wave-b-postfix-red` (build): C2039 `ActOnPostfixCallExpr` / `ActOnSequenceExpr` — `D:\as-cta\Saved\Build\wave-b-postfix-red\20260822_082156_321_ec4ee835`
- Impl build `wave-b-postfix-impl`: `D:\as-cta\Saved\Build\wave-b-postfix-impl\20260822_082342_903_fa4d956d`
- Assertion fix build `wave-b-postfix-testfix`: `D:\as-cta\Saved\Build\wave-b-postfix-testfix\20260822_082543_737_f640e1e1`
- GREEN SemaAuthority `wave-b-postfix-sema`: **178/178** — `D:\as-cta\Saved\Tests\wave-b-postfix-sema\20260822_082610_427_9b4be007`
- GREEN CanonicalAST `wave-b-postfix-canonical`: **218/218** — `D:\as-cta\Saved\Tests\wave-b-postfix-canonical\20260822_082655_912_0367abd3`
- GREEN Compiler `wave-b-postfix-compiler`: **406/406** — `D:\as-cta\Saved\Tests\wave-b-postfix-compiler\20260822_082745_075_caab99e7`

**13.2 / 13.3 / 10.2 / 9.5 / 5.6 stay `[ ]`.** Sixth-pass F1 (class VALUE vs REF) is CodeGen ABI, not this intern slice. Next exclusive UBT: freeze int-fixture generalization (`reviews/implementation-rereview-2026-08-22-sixth-pass.md` F1).

---

## B-parser-next (2026-08-21)

Parser ActOn for namespace / script enum / interface / mixin function, plus first-class `InsertSymbol` / `LookupCandidates`. Production `Build()` still `asCCompiler`. `Ready()` false. Default LEGACY.

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

- Label `wave-b-parser-next-green3`
- Report: `D:\as-cta\Saved\Tests\wave-b-parser-next-green3\20260821_184530_219_68c8a3d8\Report\index.json`
- **total=49 passed=49 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST`

- Label `wave-b-parser-next-canonical`
- Report: `D:\as-cta\Saved\Tests\wave-b-parser-next-canonical\20260821_184616_884_4a2607d2\Report\index.json`
- **total=64 passed=64 failed=0 skipped=0**

RED before impl: `wave-b-parser-next-red` total=49 passed=38 failed=11 (new Parser-action and LookupCandidates methods; `SemaScopeLookupSelectsInnerNamespaceFunctionNotGlobal` already green via WalkOne as predicted).

Notes:

- Do not `NotifySema` the whole `snEnum` after each enumerator while the enum is the current decl context (nests `ETeam::ETeam`). Enumerator `snIdentifier` ActOn under the enum instead.
- `FindBestCallee(..., "opAdd")` must pass `this` so LookupCandidatesFrom runs.
- Script `interface` was a commented-out tokenizer keyword (`as_tokendef.h`); re-enabled so `ParseInterface` is reachable. `funcdef` / `is` stay disabled.

## B-parser-import-typedef (2026-08-21)

Parser ActOn for `import` after name+params (before `from`) and `typedef` after identifier (before `;`). Script `typedef` keyword re-enabled (`as_tokendef.h`; `funcdef` / `is` stay disabled). Production `Build()` still `asCCompiler`. `Ready()` false. Default LEGACY. **13.2 stays `[ ]`.**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

- Label `wave-b-import-typedef-green`
- Report: `D:\as-cta\Saved\Tests\wave-b-import-typedef-green\20260821_185530_920_aa2e1946\Report\index.json`
- **total=53 passed=53 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST`

- Label `wave-b-import-typedef-canonical`
- Report: `D:\as-cta\Saved\Tests\wave-b-import-typedef-canonical\20260821_185622_065_49225f5b\Report\index.json`
- **total=68 passed=68 failed=0 skipped=0**

RED before impl: `wave-b-import-typedef-red` total=53 passed=50 failed=3 (`ParserActOnImportDeclBeforeFromFails` empty of Import; both typedef methods — `typedef` tokenizer was still commented). `ParserActOnImportDoesNotDuplicateOnSuccessfulParse` was already green via complete WalkOne.

Notes:

- `ParseImport` NotifySema after `ParseFunctionDefinition` and again after the module string.
- `ParseTypedef` NotifySema after the identifier, before `;`.
- WalkOne `snImport` / `snTypedef` uses `FindExistingNamedDecl`; skip `WalkParameterList` when params already exist.
- Do not treat this as 4.2 / 13.2 close. Lambdas and expression/statement bodies still WalkOne. Script `funcdef` stays fork-rejected.

## B-parser-lambda (2026-08-21)

Parser ActOn for script lambda after params, before an incomplete body. `function` identifier is a child; params are wrapped in `snParameterList`. FindExisting maps `"function"` to `"<lambda>"` and distinguishes same-signature lambdas by source offset. Production `Build()` still `asCCompiler`. `Ready()` false. Default LEGACY. **13.2 stays `[ ]`.**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

- RED: `wave-b-parser-lambda-red` — `D:\as-cta\Saved\Tests\wave-b-parser-lambda-red\20260821_191056_895_53b8296c\Report\index.json` — **total=55 passed=54 failed=1** (`ParserActOnLambdaDeclBeforeBodyParseFails` only; duplicate-on-success already green via WalkOne)
- GREEN: `wave-b-parser-lambda-green2` — `D:\as-cta\Saved\Tests\wave-b-parser-lambda-green2\20260821_191509_616_bfaf2b8c\Report\index.json` — **total=55 passed=55 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST`

- Label `wave-b-parser-lambda-canonical`
- Report: `D:\as-cta\Saved\Tests\wave-b-parser-lambda-canonical\20260821_191553_911_928fc2fe\Report\index.json`
- **total=70 passed=70 failed=0 skipped=0**

Notes:

- Naive FindExisting by name+param-types reused `function(int x)` for `function(int y)` (`MultipleLambdasKeepDistinctStableKeys` 54/55). Offset match is required.
- First GREEN attempt without offset match: `wave-b-parser-lambda-green` 54/55.
- Expression/call/lifetime still `ActOn*FromNode`. Script `funcdef` stays fork-rejected.

## B-parser-expr (2026-08-21)

Parser `ActOnParsedExpr` on `ParseFunctionCall` after the argument list, including missing `)`. Incomplete `return F(1, 2` intern `callee=F(int,int)` `nargs=2` reverse-formal. Call reuse requires a resolved callee and identifier offset (do not reuse `tokenPos==0` empty Calls — that broke mixin/method `receiver=`). Production `Build()` still `asCCompiler`. **13.2 stays `[ ]`.**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

- RED: `wave-b-parser-expr-red` — `D:\as-cta\Saved\Tests\wave-b-parser-expr-red\20260821_191757_951_cce9ddb3\Report\index.json` — **total=57 passed=56 failed=1** (`ParserActOnCallExprBeforeArgListCloseFails` only)
- First GREEN attempt reused empty Calls: `wave-b-parser-expr-green` **55/57** (`MixinCallBindsReceiverNotFreeGlobal`, `ThisOrReceiverMetadataOnMethodCall`)
- GREEN: `wave-b-parser-expr-green2` — `D:\as-cta\Saved\Tests\wave-b-parser-expr-green2\20260821_192344_706_60777cb7\Report\index.json` — **total=57 passed=57 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST`

- Label `wave-b-parser-expr-canonical`
- Report: `D:\as-cta\Saved\Tests\wave-b-parser-expr-canonical\20260821_192440_051_013c4bf3\Report\index.json`
- **total=72 passed=72 failed=0 skipped=0**

Other expr/stmt forms still WalkOne. Not 13.2 close.

## B-parser-stmt-lifetime (2026-08-21)

Incomplete conversion `G(3` already greened via call ActOn. Incomplete `return FValue(` now binds generated `FValue::FValue()` after dropping unparsed arg-list children, plus MaterializeTemporary/Cleanup. Incomplete `return 1` intern `kind=Return` via `ActOnParsedStmt` after the value, before `;`. Production `Build()` still `asCCompiler`. **13.2 stays `[ ]`.**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

- RED: `wave-b-parser-stmt-red` — `D:\as-cta\Saved\Tests\wave-b-parser-stmt-red\20260821_192943_711_26d0cbba\Report\index.json` — **total=61 passed=59 failed=2** (construct callee empty; return missing). Conversion and return-duplicate already green.
- GREEN: `wave-b-parser-stmt-green` — `D:\as-cta\Saved\Tests\wave-b-parser-stmt-green\20260821_193330_362_37d727cd\Report\index.json` — **total=61 passed=61 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST`

- Label `wave-b-parser-stmt-canonical`
- Report: `D:\as-cta\Saved\Tests\wave-b-parser-stmt-canonical\20260821_193414_101_04b002c8\Report\index.json`
- **total=76 passed=76 failed=0 skipped=0**

if/while/switch/assignment still WalkOne. Not 13.2 close.

## B-parser-ctrl-assign (2026-08-21)

Incomplete `if (1` / `while (1` / `switch (x` intern `kind=If` / `While` / `Switch` after the condition, before `)`. Incomplete `i = 1` intern `kind=Assign` after both sides, before `;`. ActOn only on the missing-token error path so complete WalkOne still owns then/body. Production `Build()` still `asCCompiler`. **13.2 stays `[ ]`.**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

- RED: `wave-b-parser-ctrl-red` — `D:\as-cta\Saved\Tests\wave-b-parser-ctrl-red\20260821_193848_902_5fb0e316\Report\index.json` — **total=67 passed=62 failed=5**. Duplicate-if already green. Duplicate-assign failed because `int i = 0` also dumps `kind=Assign`; fixture changed to `int Entry(int i)`.
- GREEN: `wave-b-parser-ctrl-green` — `D:\as-cta\Saved\Tests\wave-b-parser-ctrl-green\20260821_194155_802_4ff42cb1\Report\index.json` — **total=67 passed=67 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST`

- Label `wave-b-parser-ctrl-canonical`
- Report: `D:\as-cta\Saved\Tests\wave-b-parser-ctrl-canonical\20260821_194242_118_73954d48\Report\index.json`
- **total=82 passed=82 failed=0 skipped=0**

for/do-while still WalkOne. Not 13.2 close.

## B-parser-for (2026-08-21)

Incomplete `for (int i = 0; i < 1` intern `kind=For` + `kind=Var name=i` after init+condition, before `)`. Incomplete `do { return 1; } while (1` intern `kind=DoWhile` + `kind=IntegerLiteral` after the condition, before `)`. ActOn only on the missing-token error path. WalkOne reuses For/DoWhile by range. Local `int Y` from Parser NotifySema is reused on WalkOne (duplicate Y made Isolated While return garbage 7). Production `Build()` still `asCCompiler`. **13.2 stays `[ ]`.**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

- RED: `wave-b-parser-for-red` — `D:\as-cta\Saved\Tests\wave-b-parser-for-red\20260821_195215_408_5e0d2b68\Report\index.json` — **total=71 passed=69 failed=2** (only incomplete for/do-while; duplicates already green via WalkOne)
- GREEN: `wave-b-parser-for-green` — `D:\as-cta\Saved\Tests\wave-b-parser-for-green\20260821_195356_882_ca12274a\Report\index.json` — **total=71 passed=71 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST`

- Isolated While first failed `legacy=3 canonical=7` (duplicate `Y`). Fix: `FindExistingVar` in `as_sema_stmt.cpp`. IsolatedDifferential **3/3** (`wave-b-parser-for-isolated-green`).
- Label `wave-b-parser-for-canonical-green` — `D:\as-cta\Saved\Tests\wave-b-parser-for-canonical-green\20260821_200915_710_36cb7049\Report\index.json` — **total=86 passed=86 failed=0 skipped=0**

foreach still WalkOne. Not 13.2 close.

## B-parser-foreach (2026-08-21)

Clang-shaped `asAST_STMT_FOREACH` (dump `kind=ForEach`). Incomplete `foreach (int x :` intern `kind=ForEach` + `kind=Var name=x`. Complete parse plus WalkOne intern one ForEach. ActOn on missing `:` / range / `)` only. Production `Build()` still `asCCompiler`. **13.2 stays `[ ]`.**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

- RED: `wave-b-parser-foreach-red` — `D:\as-cta\Saved\Tests\wave-b-parser-foreach-red\20260821_202236_896_5a6cf94d\Report\index.json` — **total=75 passed=73 failed=2** (both incomplete and complete; no `snForEach` WalkOne yet)
- GREEN: `wave-b-parser-foreach-green` — `D:\as-cta\Saved\Tests\wave-b-parser-foreach-green\20260821_202548_334_c930c258\Report\index.json` — **total=75 passed=75 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST`

- Label `wave-b-parser-foreach-canonical`
- Report: `D:\as-cta\Saved\Tests\wave-b-parser-foreach-canonical\20260821_202636_252_b0119df6\Report\index.json`
- **total=90 passed=90 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler`

- First run after foreach: 277/278 — `ForkDeclarationRejectionsRemainAtomicAndRecover` still expected parse-time rejection of script `interface` (stale after Wave B re-enabled the keyword). Test updated to expect successful parse; mutable-global rejection unchanged.
- GREEN: `wave-b-parser-foreach-compiler-green` — `D:\as-cta\Saved\Tests\wave-b-parser-foreach-compiler-green\20260821_203052_766_98000a36\Report\index.json` — **total=278 passed=278 failed=0 skipped=0**

Complete bodies still WalkOne. Not 13.2 close.

## B-parser-foreach-body (2026-08-21)

ParseForeach `ActOnParsedStmt` after `ParseStatement` on syntax error **and** success. Incomplete `{ n = F(1` dumps `kind=ForEach`, `kind=Var name=x`, `callee=F(int)` not `F(float)`. Did **not** ActOn after `)` before body (empty intern + FindExisting drops body). Production `Build()` still `asCCompiler`. **13.2 stays `[ ]`.**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

- RED: `wave-b-foreach-body-red` — `D:\as-cta\Saved\Tests\wave-b-foreach-body-red\20260821_203657_879_7d3266b0\Report\index.json` — **total=77 passed=76 failed=1** (only `ParserActOnForeachBodyBeforeBlockCloseFails`; success selected-call already green via WalkOne)
- GREEN: `wave-b-foreach-body-green` — `D:\as-cta\Saved\Tests\wave-b-foreach-body-green\20260821_203818_656_0a939a5b\Report\index.json` — **total=77 passed=77 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST`

- Label `wave-b-foreach-body-canonical`
- Report: `D:\as-cta\Saved\Tests\wave-b-foreach-body-canonical\20260821_203911_176_c0741eef\Report\index.json`
- **total=92 passed=92 failed=0 skipped=0**

Complete if/while/for/do-while/switch still WalkOne. Not 13.2 close.

## B-parser-control-body (2026-08-21)

Parser `ActOnParsedStmt` after complete then/body/cases (and on body parse error) for if/while/for/do-while/switch. Incomplete `{ n = F(1` dumps the control kind plus `callee=F(int)` not `F(float)`. Did **not** ActOn after `)` / `{` before then/body/cases. If-else ActOn only after else is parsed, or after then when there is no else. Production `Build()` still `asCCompiler`. **13.2 stays `[ ]`.**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

- RED: `wave-b-control-body-red` — `D:\as-cta\Saved\Tests\wave-b-control-body-red\20260821_204941_793_3cc5dabe\Report\index.json` — **total=87 passed=82 failed=5** (only incomplete if/while/for/do-while/switch bodies; success selected-call already green via WalkOne)
- GREEN: `wave-b-control-body-green` — `D:\as-cta\Saved\Tests\wave-b-control-body-green\20260821_205119_645_d8559110\Report\index.json` — **total=87 passed=87 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST`

- Label `wave-b-control-body-canonical`
- Report: `D:\as-cta\Saved\Tests\wave-b-control-body-canonical\20260821_205205_005_d67ceaf5\Report\index.json`
- **total=102 passed=102 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler`

- Label `wave-b-control-body-compiler`
- Report: `D:\as-cta\Saved\Tests\wave-b-control-body-compiler\20260821_205306_245_510abcf0\Report\index.json`
- **total=290 passed=290 failed=0 skipped=0**

Not 13.2 close: criterion (4) production backends still `asCCompiler`.

## B-sema-identity (2026-08-21)

Param qualifier keys: `ByVal(int)` vs `ByRef(const int&in)`, `InF(int&in)` vs `OutF(int&out)`. Trailing method `const` is only the token after the parameter list (`TRAIT_CONST_METHOD` no longer leaks from `const int &in`). Production `Build()` still `asCCompiler`. **13.2 / 13.3 stay `[ ]`** (StaticJIT identity still fail-closed).

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

- RED: `wave-b-sema-identity-red` — `D:\as-cta\Saved\Tests\wave-b-sema-identity-red\20260821_201059_124_0227585a\Report\index.json` — **total=73 passed=71 failed=2** (`ByRef(int) const` plus `&in`/`&out` same-name overload did not compile; fixture became `InF`/`OutF`)
- GREEN: `wave-b-sema-identity-green` — `D:\as-cta\Saved\Tests\wave-b-sema-identity-green\20260821_201358_550_f74138d0\Report\index.json` — **total=73 passed=73 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST`

- Label `wave-b-sema-identity-canonical`
- Report: `D:\as-cta\Saved\Tests\wave-b-sema-identity-canonical\20260821_201518_973_e914e7d2\Report\index.json`
- **total=88 passed=88 failed=0 skipped=0**

## Gate

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

- Label `wave-b-sema-authority-green`
- Report: `D:\as-cta\Saved\Tests\wave-b-sema-authority-green\20260821_123443_663_13ae189d\Report\index.json`
- **total=2 passed=2 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST` (includes Cutover + SemaAuthority):

- Label `wave-b-canonical-ast`
- Report: `D:\as-cta\Saved\Tests\wave-b-canonical-ast\20260821_123534_621_628aa9af\Report\index.json`
- **total=17 passed=17 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler`:

- Label `wave-b-compiler`
- Report: `D:\as-cta\Saved\Tests\wave-b-compiler\20260821_123624_756_4f4b06e8\Report\index.json`
- **total=205 passed=205 failed=0 skipped=0**

Retain-policy CANONICAL `Build()` dumps now contain:

- `key=F(int)` / `key=F(float)` as distinct overloads
- `callee=F(int)` for `F(3)` (not the first same-name `F(float)`)
- `kind=Conversion` and `callee=G(float)` for `G(3)`

## Root cause (attach → param types → FinishDecl → dump)

Attach, param walk, and `FinishDecl(parent)` after `ActOnParamDecl` were already producing function keys with parameter types. Two dump-spelling bugs hid that:

1. **TU prefix.** `FinishDecl` qualified every function with the translation-unit module name (`SemaOverload::F(int)`). Tests look for `key=F(int)`. Translation units are module containers, not lexical namespaces. Fix: skip `asAST_DECL_TRANSLATION_UNIT` when qualifying keys. Namespaces/classes still prefix.

2. **`float` → `double` intern.** Parser `ResolveFloatTypeWidth` rewrites `ttFloat` to `ttFloat64` when `ep.floatIsFloat64`. `CanonicalPrimitiveToken` maps that to `ttDouble`, intern key `"double"`. Dump was `key=F(double)` / `callee=G(double)`. Fix: intern from source spelling so written `float` stays `float`.

Dump captured on the failing run before fix 2: `key=F(double)`, `callee=F(int)` already selected; conversion node already present.

## Identity dumps (ctor / mixin / lambda / lifetime)

SemaAuthority **6/6** (`wave-b-identity-green5`):

- `key=T::T()` / `key=T::T(int)` / `key=T::~T()` and `callee=T::T(int)` for `T v(3)`
- `kind=Mixin` + `key=MixHelper(int)`
- two `<lambda>(int)@offset` keys
- `kind=MaterializeTemporary` + `kind=Cleanup` + `callee=FValue::FValue()` for `FValue()`

CanonicalAST after identity: **21/21** (`wave-b-canonical-ast-identity`).

## Still not Wave B complete

- 4.2–5.9 / 13.2–13.3 remain `[ ]`. SemaAuthority is **17/17** on compile→seal dumps; that is still not 5.9 complete-language Sema (templates, import route, list patterns, generated accessors, full Parser-Sema-action architecture remain).
- Production Bytecode is still `asCCompiler`. Do not start Wave D CodeGen.

## Four Sema/dump facts (`wave-b-sema-plans-green`)

Worktree: `D:\as-cta`. Do not treat this as 5.9 complete-language Sema. `tasks.md` boxes were not marked.

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

- Label `wave-b-sema-plans-green`
- Report: `D:\as-cta\Saved\Tests\wave-b-sema-plans-green\20260821_131924_546_01e007f3\Report\index.json`
- **total=10 passed=10 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST`

- Label `wave-b-canonical-ast-plans`
- Report: `D:\as-cta\Saved\Tests\wave-b-canonical-ast-plans\20260821_132014_951_588bae0d\Report\index.json`
- **total=25 passed=25 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover`

- Label `wave-b-cutover-honest`
- Report: `D:\as-cta\Saved\Tests\wave-b-cutover-honest\20260821_132052_796_7d164320\Report\index.json`
- **total=5 passed=5 failed=0 skipped=0**

Cutover stayed honest: LEGACY default, Ready false, CANONICAL `Build()` publisher COMPILER.

Dump tokens now present (retain-policy CANONICAL `Build()`):

- `key=Game::F(int)` / `key=F(int)` and `callee=Game::F(int)` for `Game::F(3)` (not `callee=F(int)`)
- `key=T::opAdd(int)` and `callee=T::opAdd(int)` for `v + 3`
- `default=7`, `callee=F(int,int)`, `literal=default:7`, `nargs=2`, `reverse-formal` for `F(3)` with `int b = 7`
- Continue `STMT ... kind=Continue target=<id>` with `kind=While` and `target` Atoi > 0

Build: `wave-b-sema-plans` compiled `Module.AngelscriptRuntime.43.cpp` / `.49.cpp` and relinked Runtime (not an adaptive skip).

## Named args + mixin receiver (after 10/10)

Independent re-run of the four dumps: `goal-sema-authority-verify` **10/10**. Then TDD:

- `NamedArgumentReordersIntoFormalSlots` red (`goal-named-arg-red` 10/11) then green: `F(b: 2, a: 1)` dumps `args=named:a=1,named:b=2`.
- `MixinCallBindsReceiverNotFreeGlobal` red (callee existed, `nargs=1 args=conv`) then green: `v.MixHelper(3)` dumps `callee=MixHelper(T,int)` `nargs=2`.

SemaAuthority `goal-mixin-call-green`: **total=12 passed=12**. CanonicalAST `goal-canonical-ast-mixin`: **total=27 passed=27**.

`tasks.md` 13.2 / 13.3 / 5.9 were not checked.

## Remaining 13.2/5.9 dump gaps (TDD)

SemaAuthority `goal-wave-b-gaps-green4`: **total=17 passed=17**. CanonicalAST `goal-canonical-ast-wave-b`: **total=32 passed=32**. Compiler `goal-wave-b-compiler`: **total=220 passed=220**. TypedASTJIT CanonicalASTMigration `goal-jit-identity-reject`: **total=8 passed=8**.

New compile→seal dump facts:

- `v.Value` / `v.Value = 4` rewrite to `callee=T::GetValue()` / `callee=T::SetValue(int)`
- Break inside switch targets the Switch id, not the enclosing While
- `F(1, 2)` stores reverse-formal `args=2,1`
- Temporary cleanup dumps `callee=T::~T()`
- `G(3.5)` records `kind=Conversion` + `callee=G(int)`
- `FindAngelscriptTypedASTJITCanonicalFunctionDecl("F")` rejects two same-name overloads; unique `G` still binds

## Remainder dumps (wave-b-sema-remainder.md, 2026-08-21 late)

TDD: 6 new SemaAuthority methods RED (`wave-b-sema-remainder-red2` **25/31**), then GREEN. Shadow compile-seal 4.6 method was already match+perturb green without `as_sema*` edits.

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

- RED: `wave-b-sema-remainder-red2` — `D:\as-cta\Saved\Tests\wave-b-sema-remainder-red2\20260821_173741_178_5fbb3588\Report\index.json` — **total=31 passed=25 failed=6**
- GREEN: `wave-b-sema-remainder-green3` — `D:\as-cta\Saved\Tests\wave-b-sema-remainder-green3\20260821_174714_327_be3e18d9\Report\index.json` — **total=31 passed=31 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST`

- Label `wave-b-sema-remainder-compiler`
- Report: `D:\as-cta\Saved\Tests\wave-b-sema-remainder-compiler\20260821_174802_963_b3cb63ff\Report\index.json`
- **total=46 passed=46 failed=0 skipped=0**

`Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Dump` — **1/1**. Shadow — **2/2**.

New compile→seal dump facts (still not 13.2 / 5.9 / 4.2–4.6):

- Ambiguous same-score `F(int,float)` vs `F(float,int)` does not bind first-name
- Native `hiddenArgumentIndex` injects `nargs=2` / `origin=hidden` or `literal=hidden:4`
- `Make()[0] += 1` dumps `callee=T::opIndex(int)` with one Call `callee=Make()`
- Fallthrough `target=` is the next Case id
- Method call dumps Call-line `receiver=`
- Primitive mutable TU globals are Sema-rejected; `const int Answer` keeps `quals=1`
- Compile-seal ShadowDiff match then owner/type/trait mismatch (4.6 still `[ ]`: no builder-vs-canonical publish gate)

**13.2 / 5.9 / 4.2 / 4.6 stay `[ ]`.** Parser still builds `asCScriptNode`. Production Bytecode is still `asCCompiler`.

## Parser action-only global function (13.2 slice, not close)

TDD: `ParserActOnFunctionDeclBeforeBodyParseFails` RED (`wave-b-13-2-action-red` 1/2 — empty dump on incomplete body). Duplicate-on-success already green.

GREEN after `ParseFunction` `NotifySema` after name+params (mixin/local skip), WalkOne reuses matching name+param-types+const:

- SemaAuthority `wave-b-13-2-action-green3` — `D:\as-cta\Saved\Tests\wave-b-13-2-action-green3\20260821_175916_902_2063f1f1\Report\index.json` — **33/33**
- Compiler CanonicalAST `wave-b-13-2-compiler` — `D:\as-cta\Saved\Tests\wave-b-13-2-compiler\20260821_180011_440_bd4b58e4\Report\index.json` — **48/48**

Incomplete `int Broken(int a) { return` still intern `key=Broken(int)` + param `a`. Successful `int F(int a)` intern once. **13.2 stays `[ ]`.**

## B-param-identity (2026-08-22)

Intern-after-name + `FindExistingFunctionLike` no-`snParameterList` → invalid intern-created extra 0-arg overloads. Incomplete class NotifySema also ran `EnsureGeneratedLifecycle` before user `T()` / `T(int)`.

Fix: no-list FindExisting reuses only the same name-token range; class lifecycle waits until the class node ends with `}`. Incomplete `int Second(` may intern as a distinct 0-param Function and must not steal `First`.

- RED SemaAuthority `wave-b-param-sema`: **200/202** — `ConstructorOverloadsSelectExactCtorNotFirstName` Build fails; `ParserSemaActionsRecordFirstFunctionWhenLaterSyntaxFails`
- GREEN SemaAuthority `wave-b-param-sema2`: **202/202** — `D:\as-cta\Saved\Tests\wave-b-param-sema2\20260822_130252_192_de759d6e`
- GREEN CanonicalAST `wave-b-param-canonical`: **250/250** — `D:\as-cta\Saved\Tests\wave-b-param-canonical\20260822_130408_030_57d72185`

**4.2 / 13.2 / 13.3 stay `[ ]`.**

## B-enumerator (2026-08-22)

Dedicated `ActOnStartEnumeratorDecl` FindExisting const-int `kind=Var`. Parser `ActOnParsedEnumerator` after each enumerator ident. WalkOne snEnum / snIdentifier reuse the same intern.

- RED SemaAuthority `wave-b-enum-red`: **202/203** — `SemaStartEnumeratorDeclActionRecordsEnumeratorWithoutScriptNode`
- GREEN SemaAuthority `wave-b-enum-sema`: **203/203** — `D:\as-cta\Saved\Tests\wave-b-enum-sema\20260822_130758_858_764d8f62`
- GREEN CanonicalAST `wave-b-enum-canonical`: **251/251** — `D:\as-cta\Saved\Tests\wave-b-enum-canonical\20260822_130842_462_580ebafc`

**4.2 / 13.2 stay `[ ]`.** Builder remains production declaration authority. LEGACY still `asCCompiler`.

## B-declref-fromnode (2026-08-22)

Peel leftover `ActOnParsedExpr` `snVariableAccess` whole-node FromNode: extract ident/scope then `ActOnDeclRefExpr` via `InternParsedDeclRef`. FromNode recovery reuses the same helper.

- RED SemaAuthority `wave-b-declref-red`: **173/205** — FromNode FindExisting-only (no intern)
- GREEN SemaAuthority `wave-b-declref-sema`: **205/205** — `D:\as-cta\Saved\Tests\wave-b-declref-sema\20260822_131606_241_cb45891d`
- GREEN CanonicalAST `wave-b-declref-canonical`: **253/253** — `D:\as-cta\Saved\Tests\wave-b-declref-canonical\20260822_131700_284_36107d8f`
- GREEN Compiler `wave-b-declref-compiler`: **443/443** — `D:\as-cta\Saved\Tests\wave-b-declref-compiler\20260822_131751_905_dc752915`

Locks: `callee=i` on incomplete `i;`, `callee=Game::X` on incomplete scoped access, one DeclRef on successful `return i`.

**4.2 / 13.2 / 13.3 stay `[ ]`.** Leftover `snFunctionCall` / `snExprTerm` FromNode remain. LEGACY still `asCCompiler`.

## B-call-fromnode (2026-08-22)

Peel leftover `ActOnParsedExpr` `snFunctionCall` whole-node FromNode: extract ident/args/scope then `ActOnCallExpr` via `InternParsedCall`. FromNode recovery reuses the same helper (member calls keep `implicitReceiver`).

- RED SemaAuthority `wave-b-call-red`: **159/206** — FromNode FindExisting-only
- GREEN SemaAuthority `wave-b-call-sema`: **206/206** — `D:\as-cta\Saved\Tests\wave-b-call-sema\20260822_132328_751_c9a56ab7`
- GREEN CanonicalAST `wave-b-call-canonical`: **254/254** — `D:\as-cta\Saved\Tests\wave-b-call-canonical\20260822_132423_294_963f48b3`
- GREEN Compiler `wave-b-call-compiler`: **444/444** — `D:\as-cta\Saved\Tests\wave-b-call-compiler\20260822_132514_567_621ac90a`

Lock: incomplete `return F(3` with `F(float)`/`F(int)` intern `callee=F(int)` not first-name `F(float)`.

**4.2 / 13.2 / 13.3 stay `[ ]`.** Leftover `snExprTerm` FromNode remains. LEGACY still `asCCompiler`.

## B-term-fromnode (2026-08-22) — intern landed, identity RED

Peel leftover `ActOnParsedExpr` `snExprTerm` whole-node FromNode: `InternParsedExprTerm` walks pre-op / `.` / `[` / `(` / postfix `++`/`--` then dedicated `ActOn*`. FromNode `snExprValue`/`snExprTerm` recovery reuses the same helper.

- RED SemaAuthority `wave-b-term-red`: **123/208** — FromNode FindExisting-only SEQUENCE/INDEX/UNARY/CALL
- PARTIAL SemaAuthority `wave-b-term-sema`: **200/208** — `D:\as-cta\Saved\Tests\wave-b-term-sema\20260822_133047_287_09ac5738`

New locks PASS: incomplete `-v;` → `callee=T::opNeg()`; incomplete `v++;` → `callee=T::opPostInc()`.

Eight remain RED. Shared cause: `InternParsedExprTerm` FindExisting CALL at whole-term range matches `FindExistingExpr` **begin.offset only**, so `v - 3` rewrite CALL and `Make()` steal the term. Dumps already have `callee=T::opSub(int)` **and** leftover `kind=Binary literal=-`; `Make()[0] += 1` has `callee=Make()` and **no** `callee=T::opIndex(int)`. Exclusive UBT: `attachments/wave-b-term-fix-next.md`.

## B-term-fix (2026-08-22)

Stop `InternParsedExprTerm` from FindExisting CALL at the whole-term range. SEQUENCE / INDEX / UNARY reuse stays. Inner named calls still reuse by ident offset. `ActOnBinaryExpr` second-line CALL reuse was **not** needed.

- GREEN SemaAuthority `wave-b-term-sema2`: **208/208** — `D:\as-cta\Saved\Tests\wave-b-term-sema2\20260822_134328_686_9452275b`
- GREEN CanonicalAST `wave-b-term-canonical`: **256/256** — `D:\as-cta\Saved\Tests\wave-b-term-canonical\20260822_134423_671_1daeff09`
- GREEN Compiler `wave-b-term-compiler`: **446/446** — `D:\as-cta\Saved\Tests\wave-b-term-compiler\20260822_134511_300_8c09e811`

Locks: `v - 3` dumps `callee=T::opSub(int)` with no leftover `kind=Binary literal=-`; `Make()[0] += 1` dumps `callee=T::opIndex(int)` and one `callee=Make()`; incomplete `-v;` / `v++;` still `opNeg` / `opPostInc`.

**4.2 / 13.2 / 13.3 stay `[ ]`.** LEGACY still `asCCompiler`. Next leftover: `ActOnParsedExpr` `default` recovery, then 5.4 / 5.6 (`attachments/wave-b-leftover-after-term.md`).

## B-54-single-eval dump (2026-08-22)

Explicit sequencing dump: `asAST_EXPR_OPAQUE_VALUE`, Sequence `literal=opaque`, Logical `lhs=`/`rhs=`, Conditional `cond=`/`then=`/`else=`. `+=` peels postfix Sequence then wraps Index/property-Get with OpaqueValue + get/add/set plan.

- RED SemaAuthority `wave-b-54-sema-red`: **208/212** — four new methods
- GREEN SemaAuthority `wave-b-54-sema3`: **212/212** — `D:\as-cta\Saved\Tests\wave-b-54-sema3\20260822_135801_675_7e879915`
- GREEN CanonicalAST `wave-b-54-canonical`: **260/260** — `D:\as-cta\Saved\Tests\wave-b-54-canonical\20260822_135850_614_0484197f`
- GREEN Compiler `wave-b-54-compiler`: **450/450** — `D:\as-cta\Saved\Tests\wave-b-54-compiler\20260822_135951_899_a9457ec9`

`Make()[0] += 1` / `Make().Value += 1` still fail-close Generate at pre-existing `EmitDeclRef` dangling (`code=1 line=1070`). Dump tokens use `DumpSealedCanonicalAst` like the weak Index count lock. OpaqueValue CodeGen is passthrough only, not eval-once memo. **Not 5.4 / 13.2 close** (no isolated VM trace of AST-driven CodeGen).

## B-56-safepoint dump + oracles (2026-08-22)

`asEASTSafePointRole` on stmt/expr. Dump `safepoint=` when `!= NONE`. Verifier skipped-nearer / default-order / fallthrough-target. Named For/If phases not redone.

- GREEN SemaAuthority `wave-b-56-sema`: **213/213** — `D:\as-cta\Saved\Tests\wave-b-56-sema\20260822_141027_218_515261d0`
- GREEN Verifier `wave-b-56-ver`: **16/16**
- RED Frontend CanonicalAST `wave-b-56-frontend`: **82/85** — Seal `decl-body`

**Not 5.6 / 13.2 close.**

## B-56-body-owner (2026-08-22)

`AttachParsedFunctionBody` reuses a BLOCK only when `existing->owner == fn`. `FindExistingFunctionLike` does not collapse `~FBase()` onto constructor `FBase()`. Owner-mismatch intern of a compound does **not** re-parent existing children (`stmt-multi-owner`). `ActOnStartParamDecl` records `duplicate-param:` when collapsing a second same-name param.

Diagnostic dump (`wave-b-56-body-diag`): constructor `FBase` `SetBody` stole destructor BLOCK `owner=dtor begin=108` (`DECL id=5 kind=10 body owner=8 kind=11`).

- GREEN Frontend CanonicalAST `wave-b-56-frontend4`: **85/85** — `D:\as-cta\Saved\Tests\wave-b-56-frontend4\20260822_145131_925_9f7da6c4`
- GREEN SemaAuthority `wave-b-56-sema2`: **213/213** — `D:\as-cta\Saved\Tests\wave-b-56-sema2\20260822_145217_187_cb5bb9bb`
- GREEN Verifier `wave-b-56-ver2`: **16/16** — `D:\as-cta\Saved\Tests\wave-b-56-ver2\20260822_145304_626_685eb783`
- GREEN Compiler CanonicalAST `wave-b-56-canonical`: **261/261** — `D:\as-cta\Saved\Tests\wave-b-56-canonical\20260822_145349_757_6aedfe77`

Temporary `asCASTVerify` diagnostic reverted. **5.6 / 5.4 / 13.2 / 4.2 / 9.5 stay `[ ]`.** LEGACY still `asCCompiler`. Next exclusive UBT: 5.4 Generate/VM (`attachments/wave-b-54-generate-remaining.md`), not leftover `ActOnParsedExpr` default.

## B-eighth-f1-member-call (2026-08-22)

`ParseFunctionCall(false)` when the call is a `.` postfix child — no `ActOnParsedExpr` until `InternParsedExprTerm` has the receiver. Member intern pops the receiver from the postfix Sequence (same as property Get), so `Make().Get()` is one `callee=Make()` CALL plus one `callee=T::Get()` with `receiver=`.

- RED SemaAuthority `wave-b-f1-sema-red`: **213/214** — `MemberPostfixCallInternsOnceWithoutReceiverLessCallOnCompileSealPath` (orphan `callee=` CALL id beside `T::Get()`, Sequence `parts=Make,Get`)
- GREEN SemaAuthority `wave-b-f1-sema`: **214/214** — `D:\as-cta\Saved\Tests\wave-b-f1-sema\20260822_150301_532_e6104f92`
- GREEN CanonicalAST `wave-b-f1-canonical`: **262/262** — `D:\as-cta\Saved\Tests\wave-b-f1-canonical\20260822_150351_055_e56a25d0`
- GREEN Frontend CanonicalAST `wave-b-f1-frontend`: **85/85** — `D:\as-cta\Saved\Tests\wave-b-f1-frontend\20260822_150443_679_af2bb864`

**Not 5.4 / 13.2 / 9.5 close.** `EmitCall` can still eval `literalBits` after children; Generate/VM traces of `Make().Get()` remain a later UBT. F2 scoped identity / F3 `T()` VALUE_OBJECT / F4 same-arity fallback unchanged.

## B-54-eval-once-codegen (2026-08-22)

CANONICAL `return Make().Get();` execute: `Trace(1)` then `Trace(2)`, result `1`. `EmitCall` reuses an already-emitted child when `literalBits` names that id; interned host `Trace` binds to the registered SYSTEM function instead of an empty script stub.

- RED Semantics `wave-b-54-eval-once-red`: **4/5** — `D:\as-cta\Saved\Tests\wave-b-54-eval-once-red\20260822_151704_293_8df5385e` — `CanonicalMemberPostfixCallEvaluatesReceiverOnce` (Generate succeeded, result `1`; matcher `Make() then Get(); Make() must run once`). Not `code=1 line=1070`. Diagnostic re-run `wave-b-54-eval-once-diag` showed actual `trace=''` (host `Trace` stubbed to empty `asFUNC_SCRIPT`) and `EmitCall name=Get recvId=15 nChild=1 reused=1` — not `1,1,2`.
- GREEN Semantics `wave-b-54-eval-once-sem`: **5/5** — `D:\as-cta\Saved\Tests\wave-b-54-eval-once-sem\20260822_152830_615_d7586255`
- GREEN SemaAuthority `wave-b-54-eval-once-sema`: **214/214** — `D:\as-cta\Saved\Tests\wave-b-54-eval-once-sema\20260822_152909_896_27d1ed11` (F1 dump still green)
- GREEN CanonicalAST `wave-b-54-eval-once-canonical`: **263/263** — `D:\as-cta\Saved\Tests\wave-b-54-eval-once-canonical\20260822_152956_444_02540b2f` (was 262; +1 execute method)
- GREEN Frontend CanonicalAST `wave-b-54-eval-once-frontend`: **85/85** — `D:\as-cta\Saved\Tests\wave-b-54-eval-once-frontend\20260822_153043_614_408b23d9`

**5.4 / 13.2 / 9.5 / 9.4 stay `[ ]`.** `EmitDeclRef` `:1070` and OpaqueValue passthrough memo are not this package. LEGACY still `asCCompiler`. `PropertyRewriteAndMutationSingleEvaluation` unchanged (default LEGACY).

## B-eighth-f2-call-identity (2026-08-22)

`InternParsedCall` reuses CALL by FunctionCall **full source range** (kind + begin/end file+offset), including unresolved and offset 0. Does not steal a wider CALL that only shares `begin.offset`. Creating path records one `unresolved-call:<name>`. Replay of a class-returning call still returns the wrapping Materialize when present.

- RED SemaAuthority `wave-b-f2-sema-red`: **214/219** — `D:\as-cta\Saved\Tests\wave-b-f2-sema-red\20260822_153751_810_213d6e23` — five new methods only
- GREEN SemaAuthority `wave-b-f2-sema`: **219/219** — `D:\as-cta\Saved\Tests\wave-b-f2-sema\20260822_153920_664_2bf90aa8`
- GREEN CanonicalAST `wave-b-f2-canonical`: **268/268** — `D:\as-cta\Saved\Tests\wave-b-f2-canonical\20260822_154009_093_7981ae05` (includes `CanonicalMemberPostfixCallEvaluatesReceiverOnce`)
- GREEN Frontend CanonicalAST `wave-b-f2-frontend`: **85/85** — `D:\as-cta\Saved\Tests\wave-b-f2-frontend\20260822_154057_436_ab231e1e`

**Not 13.2 / 13.3 / 4.2 / 5.4 close.** `FindExistingExpr` still kind+begin, skip 0. `asCASTVerify` still OK on unsealed CALL-without-callee.

## B-eighth-f3-construct-type (2026-08-22)

`ConstructFromCallee` uses `QualTypeFromClassDecl`: script `class` → `REFERENCE_OBJECT` + handle/auto-handle; script `struct` → `VALUE_OBJECT`. Dump EXPR lines append `typeKind=`. Match Construct dump with `kind=Construct type=` (substring of `kind=Constructor`).

- RED SemaAuthority `wave-b-eighth-f3-red` then GREEN `wave-b-eighth-f3-sema2`: **222/222** — `D:\as-cta\Saved\Tests\wave-b-eighth-f3-sema2\20260822_154912_709_123bd4b7`
- GREEN CanonicalAST `wave-b-eighth-f3-canonical`: **271/271** — `D:\as-cta\Saved\Tests\wave-b-eighth-f3-canonical\20260822_155005_094_dbb07368`

**Not 13.2 / 9.5 close.** ABI matrix still open.

## B-eighth-f4-fail-closed intern (2026-08-22)

Script member miss no longer binds first same-arity script method. Unresolved construction-API Call/DeclRef intern `asAST_TYPE_ERROR` `"<unresolved>"` plus `unresolved-callee:` / `unresolved-identifier:`. Parser-range DeclRef miss stays silent int (recovery) so `FValue() { Value = 41; }` Seal is not blocked. Mixin recovered by falling through `FindBestCallee(searchOwner, full args)` after a member miss (arity includes receiver, so free `Get(int)` still cannot bind `v.Get(3)`).

- RED SemaAuthority `wave-b-eighth-f4-red`: **223/227** then Mixin **226/227** `wave-b-eighth-f4-sema`
- GREEN SemaAuthority `wave-b-eighth-f4-sema2`: **227/227** — `D:\as-cta\Saved\Tests\wave-b-eighth-f4-sema2\20260822_155642_917_d2da921a`
- CanonicalAST `wave-b-eighth-f4-canonical2`: **270/276** — value-object `unresolved-identifier:Value` + array `insertLast` (before DeclRef recovery)
- ProductionCodeGen `wave-b-eighth-f4-prod3`: **32/33** — `D:\as-cta\Saved\Tests\wave-b-eighth-f4-prod3\20260822_160637_363_c405d9a0` — only `CanonicalArrayIntBuildPublishesCodeGenAndExecutes` (`unresolved-callee:insertLast`; RankArgument `T` vs `int` = `-1`)

Native-intern `fileID==0` same-arity written after prod3; verified GREEN in `## B-eighth-f4-native`.

**13.2 / 5.4 / 9.5 stay `[ ]`.** Do not restore script same-arity.

## B-eighth-f4-native (2026-08-22)

Native-intern `fileID==0` same-arity in `ResolveCallee` (after `FindBestCallee` miss) binds host `array<int>::insertLast(const T&in)` to `int` without restoring script same-arity. `RankArgument` is still type-id equality (`T` vs `int` = `-1`); instantiate-T was not needed. `ActOnMethodDecl` empty range is `fileID` 0.

- Build `wave-b-eighth-f4-native`: OK — `D:\as-cta\Saved\Build\wave-b-eighth-f4-native\20260822_161812_673_db0ceb8d`
- RED ProductionCodeGen `wave-b-eighth-f4-prod3`: **32/33** — `D:\as-cta\Saved\Tests\wave-b-eighth-f4-prod3\20260822_160637_363_c405d9a0` (`unresolved-callee:insertLast`; fallback written after this run, not yet built)
- GREEN ProductionCodeGen `wave-b-eighth-f4-prod4`: **33/33** — `D:\as-cta\Saved\Tests\wave-b-eighth-f4-prod4\20260822_161826_704_49808a53` (`succeededWithWarnings=0`)
- GREEN SemaAuthority `wave-b-eighth-f4-sema3`: **227/227** — `D:\as-cta\Saved\Tests\wave-b-eighth-f4-sema3\20260822_161915_941_944a9817` (`succeededWithWarnings=0`; Mixin / MemberSameArityTypeMismatch / MemberAmbiguousOverload / Unresolved* still green)
- GREEN CanonicalAST `wave-b-eighth-f4-canonical3`: **276/276** — `D:\as-cta\Saved\Tests\wave-b-eighth-f4-canonical3\20260822_162007_473_5eb73ff8` (`succeededWithWarnings=0`, failed=0)

**13.2 / 5.4 / 9.5 stay `[ ]`.** RankArgument does not instantiate host template T. Script same-arity (`fileID != 0`) stays deleted.

## B-eighth-f4-rank (2026-08-22)

`InternNativeMethods` now calls `DetermineTypeForTemplate` so `array<int>::insertLast(const T&in)` interns as `insertLast(const int&in)`, and same-name methods with **different** substituted param types are both interned (no longer collapsed by arity-only). `FindBestCallee` then ranks instantiated `int` over same-arity `bool`. Native `fileID==0` same-arity remains as defense; script same-arity stays deleted.

Lock: `NativeTemplateMethodRanksInstantiatedSubtypeNotSameArityBool` — dump `callee=array<int>::insertLast(const int&in)`, not `insertLast(bool)`.

- RED SemaAuthority `wave-b-eighth-f4-rank-red`: **227/228** — `float` host keyword invalid on this fork; fixture switched to `bool`
- Intermediate `wave-b-eighth-f4-rank-sema2`: **227/228** — ranking already selected `const int&in`; oracle matched `literal=insertLast` against `literal=insertLast:reverse-formal`
- GREEN SemaAuthority `wave-b-eighth-f4-rank-sema3`: **228/228** — `D:\as-cta\Saved\Tests\wave-b-eighth-f4-rank-sema3\20260822_163148_927_35ca9bdc`
- GREEN CanonicalAST `wave-b-eighth-f4-rank-canonical`: **277/277** — `D:\as-cta\Saved\Tests\wave-b-eighth-f4-rank-canonical\20260822_163240_599_7b31dea6`

**13.2 / 5.4 / 9.5 stay `[ ]`.** Next exclusive UBT after F5: 1070 (`wave-b-54-1070-next.md`).

## B-eighth-f5-identity (2026-08-22)

`ActOnStartParamDecl` / `ActOnStartEnumeratorDecl` reuse **same owner + same source range**, not bare name. Distinct-range same-name intern a second PARAM/VAR plus `duplicate-param:` / `duplicate-enumerator:`. Same-range replay returns the sibling with **no** diagnostic. Anonymous empty-range params stay distinct.

- RED SemaAuthority `wave-b-eighth-f5-red`: **232/236** — four new methods (`SemaStartParamDeclDistinctRange…`, replay-without-diagnostic, two enumerator distinct-range). Parser duplicate-param dump already two Params. Anonymous / per-owner locks green.
- GREEN SemaAuthority `wave-b-eighth-f5-sema`: **236/236** — `D:\as-cta\Saved\Tests\wave-b-eighth-f5-sema\20260822_163752_776_9d333d60`
- GREEN CanonicalAST `wave-b-eighth-f5-canonical`: **285/285** — `D:\as-cta\Saved\Tests\wave-b-eighth-f5-canonical\20260822_163840_236_684bc88d`

**4.2 / 13.2 / 5.4 / 9.5 stay `[ ]`.** Builder is still production decl authority.

## B-54-1070-declref (2026-08-22)

Class-member `return Value` and for-init `i` intern after the VAR exists. `ParseClass` `NotifySema`s `ParseDeclaration(true)` before later methods; `ParseFor` `NotifySema`s the init declaration before cond/incr. `InternParsedDeclRef` does not reuse a DECL_REF whose `resolvedDecl` is invalid. `ActOnDeclRefExpr` fileID split unchanged (construction-API ERROR; parser-range true miss silent int).

- RED PropertyReadWrite `wave-b-54-1070-red-prop`: `Build()!=0`, `Canonical CodeGen failed code=1 line=1107`
- RED ForLoop `wave-b-54-1070-red-for`: same `line=1107`
- GREEN SemaAuthority `wave-b-54-1070-sema`: **236/236** — `D:\as-cta\Saved\Tests\wave-b-54-1070-sema\20260822_164458_301_9914555e` (no remaining `line=1107`)
- GREEN CanonicalAST `wave-b-54-1070-canonical`: **285/285** — `D:\as-cta\Saved\Tests\wave-b-54-1070-canonical\20260822_164547_866_dcda1134`
- GREEN Verifier `wave-b-54-1070-ver`: **16/16** — `D:\as-cta\Saved\Tests\wave-b-54-1070-ver\20260822_164640_428_6ff658c3`
- GREEN Compiler `wave-b-54-1070-compiler`: **475/475** — `D:\as-cta\Saved\Tests\wave-b-54-1070-compiler\20260822_164723_549_d36e0fd3` (TypedSemanticIR SourceProvenance may still `succeededWithWarnings`)

**5.4 / 13.2 stay `[ ]`.** Next Generate exclusive: OpaqueValue memo / mutation write-through (`wave-b-54-generate-remaining.md`). Do not require IndexCompoundAssign Entry `Build()==0` from this slice.

