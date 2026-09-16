# Coverage oracle certification

## State

Certified 2026-09-15 from existing product contracts, current replacement tests, and inspected frontend/VM sources. Not execution evidence for 3.x. Every design.md section 4 axis has at least one positive, one boundary, and one rejection cell except Retired, which is rejection-only. All required rows are `existing-proven` or `missing-with-settled-oracle`. No `product-defect` or `contract-unsettled` row remains in the required set.

## Row fields

Cell ID; operator/construct and types; literal source plus runtime args; expected stage/status; exact value, side effect, diagnostic/range or fault/cleanup; independent contract citation; existing/proposed test identity; owner; disposition; actual run/source/binary identity after execution (filled by 3.x / 4.1).

Disposition values used here:

- `existing-proven` — a current replacement test already asserts the independent oracle.
- `missing-with-settled-oracle` — the expected answer is independently cited; 3.x must add or reuse a SourceExecution/Sema/Parser case.

## Certification method

Oracles come from durable specs, existing replacement tests, and the maintained interpreter/constant-evaluator. Observed-only outputs, emitted-opcode-only proof, and TestCode `.as` counts are not accepted. Runtime-variable over-wide shifts have no product-specified numeric result (the VM uses an unguarded C++ `<<`); that context is **not** a required value cell. The approved over-wide-shift **boundary** is compile-time/constant `InvalidShift`.

## Previously unresolved entries

| Entry | Settled oracle | Disposition | Owner |
|---|---|---|---|
| Signed overflow by width | Compile-time signed add/sub/mul/min/-1 div → `Overflow` and no publishable constant. Runtime `ADDi`/`SUBi`/`MULi` wrap at two's-complement width with no exception. Runtime `MIN_int32 / -1` and `MIN_int64 / -1` → `asEXECUTION_EXCEPTION` `"Overflow in integer division"`. Unsigned add wraps at declared width and succeeds. | existing-proven (const/VM opcode) + missing-with-settled-oracle (SourceExecution wrap) | 3.2 |
| Shift at/above width | Constant/enum: count `< 0` or `>=` width → `InvalidShift` / `EnumConstantInvalidShift`. In-range runtime `<<`/`>>`/`>>>` use fixed-width DWORD/QWORD bit patterns (`1 << 31` → `0x80000000`; `-2 << 1` → `0xfffffffc`; logical `>>` of `-2` → `0x7fffffff`; arithmetic `>>>` of `-2` → `0xffffffff`). Runtime-variable over-wide counts are unspecified; 3.2 does not assert a masked or trapped value. | existing-proven (const/enum) + missing-with-settled-oracle (in-range source) | 3.2 |
| Floating zero divisor | `asBC_DIVf`/`MODf`/`DIVd`/`MODd` raise `TXT_DIVIDE_BY_ZERO` and leave no finished return. Distinct from integer `"Divide by zero"`. IEEE residual after a finished divide is not the oracle. | existing-proven (VM float opcodes) + missing-with-settled-oracle (source `7.5 / 0.0`) | 3.2 |
| Narrow/out-of-range conversion | Supported explicit `int(9.0/2.0)` and `int(4.5)` truncate toward zero to `4`. `int8(-1)` widens to `int(-1)`. Constant `256` cannot convert to `uint8` (`asTryConvertIntegralConstant` false, output bits unchanged). Constant `2147483648.0` → `int32` is `Overflow`. Unrelated object casts reject without publishable output. | existing-proven + missing-with-settled-oracle (object pair) | 3.6 |
| Inherited same-name dispatch | Legal `B : A` with `int F(int) override` returning `Value + 1` and extra `int F()` returning `0` publishes three functions. Exact `B` receiver `F(3)` returns `4`. Call through `A@` to a `B` instance uses interface/virtual `CALLINTF` and still returns `4`. Illegal cycles, duplicate bases, `override` without a base, `final` override, and return-type mismatch fail at declaration resolution. | existing-proven (decl) + missing-with-settled-oracle (runtime) | 3.5 |
| Storage class/module globals | Namespace-scope `int Counter` is a valid declaration identity. Detached **const** global metadata publishes without executable storage. **Mutable** (`non-const`) and `void` globals return `InvalidSignature` and publish nothing. 3.5 SourceExecution of script-mutable module globals must reject without usable mutation. Locals and members remain the positive storage forms. | existing-proven | 3.5 |
| Foreach | Not a language/surface removed construct. Well-formed `foreach` with an `opFor*` range can pass Sema (`BodyControlFlowTests`). Bytecode emission is `UnsupportedLowering` and publishes no image (`VMSourceAdmissionTests.UnsupportedBodyPublishesNoPartialImage`). Malformed `foreach` keeps authored-range syntax diagnostics. 3.6 asserts emission/syntax rejection only; this Change does not productize foreach. | existing-proven | 3.6 |

## Parser (3.1)

| Cell | Source / args | Expected | Citation | Identity | Owner | Disposition |
|---|---|---|---|---|---|---|
| PAR.PREC.ADD_MUL | `int F(int A){ return A + 2 * 3; }` | Parser tree: add root, multiply on the right; ranges cover `+` and `*`. Runtime later `A=1` → `7` is SourceExecution overlap, not the Parser oracle. | `as_parser.cpp` binary precedence (`*`  above `+`); `VMSourceNumeric.IntegerControlStillSeven` is execution overlap only | proposed `NativeEngine.Parser.Precedence.*` | 3.1 | missing-with-settled-oracle |
| PAR.PREC.PAREN | `int F(int A){ return (A + 2) * 3; }` | Multiply root; add is the left child. | Same parser tables | proposed `NativeEngine.Parser.Precedence.*` | 3.1 | missing-with-settled-oracle |
| PAR.OK.DECL | `int G(){ return 7; }` | No parser error; `G` is collected. | `asCParser Parser(Sema)` at `as_parser.h:20`; declarations spec | proposed `NativeEngine.Parser.Contracts.*` | 3.1 | missing-with-settled-oracle |
| PAR.REC.FOLLOW | malformed `F` then `int G(){ return 7; }` | Authored bad-token range on `F`; `G` remains. | language/surface recovery; SyntaxTests keep-following-declaration | proposed `NativeEngine.Parser.Recovery.*` | 3.1 | missing-with-settled-oracle |
| PAR.REC.EOF | missing delimiter / incomplete EOF | Distinct recovery oracles, not the same diagnostic as a bad token in the middle. | Parser recovery helpers | proposed `NativeEngine.Parser.Recovery.*` | 3.1 | missing-with-settled-oracle |

## Arithmetic, assignment, compare, logic, bitwise (3.2)

Default stage is SourceExecution: compile, link, `Prepare`, `SetArg*`, `Execute`. `A`/`B` below are runtime arguments unless marked `const`.

| Cell | Types / source | Expected | Citation | Identity | Owner | Disposition |
|---|---|---|---|---|---|---|
| AR.INT.POS | `int F(int A,int B){ return A+B; }` A=7,B=3 | `10`; same pattern `-4`, `*21`, `/2`, `%1` | Task 3.2 cases; `IntegerControlStillSeven` is `1+2*3=7` overlap | proposed `VMSourceNumeric` methods | 3.2 | missing-with-settled-oracle |
| AR.FLT.POS | float/double A=7.5,B=2.0 | `+9.5`, `-5.5`, `*15.0`, `/3.75` | `VMSourceNumeric` double 8.5-2.0=6.5, 2.5*4.0=10.0, 9.0/2.0=4.5 | existing-proven (nearby) + missing-with-settled-oracle (exact 7.5/2.0 set) | 3.2 | mixed |
| AR.INT.DIV0 | `int F(int A,int B){ return A/B; }` A=7,B=0 | `asEXECUTION_EXCEPTION`, exception string contains `Divide by zero`; Context can be reprepared; no finished return | language/surface runtime safety; `VMIntegerOpcodeMatrixTests.DivModByZeroTypedException`; `as_context.cpp` `asBC_DIVi` | proposed SourceExecution + existing VM opcode | 3.2 | missing-with-settled-oracle |
| AR.INT.DIVOVF | A=`MIN_int32`, B=`-1` | Exception `"Overflow in integer division"` | `as_context.cpp` `asBC_DIVi`; same VM test | proposed SourceExecution | 3.2 | missing-with-settled-oracle |
| AR.INT.ADDWRAP | runtime `int A = 2147483647; return A + 1;` | Finished; result `-2147483648` (two's-complement wrap). Not a compile-time constant. | `as_context.cpp` `asBC_ADDi` has no overflow check | proposed SourceExecution | 3.2 | missing-with-settled-oracle |
| AR.CONST.OVERFLOW | const/enum `2147483647 + 1` | Constant-eval `Overflow`; enum uses `enum-value-out-of-range` / no publishable constant | `as_constant_evaluator.cpp`; `IntegralConstants.SignedOverflowAndInvalidShiftFailAtTheActualOperator` | existing-proven | 3.2 | existing-proven |
| AR.UINT.WRAP | uint32 max + 1 at const-eval | Succeeds with bits `0` | `IntegralConstants.UnsignedArithmeticWrapsAtItsDeclaredWidth` | existing-proven | 3.2 | existing-proven |
| AR.FLT.DIV0 | `double F(double A,double B){ return A/B; }` 7.5, 0.0 | Exception `Divide by zero`; not Inf as a finished return | `as_context.cpp` `asBC_DIVd`/`DIVf` | proposed SourceExecution | 3.2 | missing-with-settled-oracle |
| AR.TYPE.REJ | `int + bool` / incomparable pair | Sema reject; no publishable output | Sema binary type rules (`as_sema.cpp` operator families) | proposed Sema | 3.2 | missing-with-settled-oracle |
| AS.CHAIN | start A=12; `A+=3; A-=2; A*=4; A/=2; A%=5` | Visible values 15,13,52,26,1 | Task 3.2; compound ops update the lvalue | proposed `VMSourceExpressions` | 3.2 | missing-with-settled-oracle |
| AS.CONST.REJ | assign to `const` / non-lvalue | Sema reject; no publishable output | value-category rules | proposed Sema | 3.2 | missing-with-settled-oracle |
| CMP.POS | `== != < <=` on ints and floats | Boolean results; `4.0 > 1.5` is true | `VMSourceNumeric.FloatCompareAssignAndNonIntCast` | existing-proven + missing cells | 3.2 | mixed |
| LOG.SHORT | `false && RHS()`, `true \|\| RHS()` | RHS side-effect counter stays 0; opposite cases increment once | `IntegralConstants.ShortCircuitDoesNotEvaluateAnUnreachableDivision` | existing-proven (const) + missing-with-settled-oracle (runtime counter) | 3.2 | mixed |
| BIT.POS | `& \| ^ ~ << >>` in-range | Bit-pattern results per width | `IntegralConstants.LogicalAndArithmeticRightShiftKeepMaintainedASMeanings` | existing-proven (const) + missing-with-settled-oracle (source) | 3.2 | mixed |
| BIT.OVERWIDE | const `1 << 32` on int32 | `InvalidShift`; enum `1 << 99` → `EnumConstantInvalidShift` | `as_constant_evaluator.cpp:290`; `DiagnosticSemanticTests` | existing-proven | 3.2 | existing-proven |
| BIT.FLOAT.REJ | float `&` / `<<` | Sema reject; no publishable output | Sema bitwise requires integers (`as_sema.cpp` shift/bitwise cases) | proposed Sema | 3.2 | missing-with-settled-oracle |

## Control flow (3.3)

| Cell | Source / args | Expected | Citation | Identity | Owner | Disposition |
|---|---|---|---|---|---|---|
| CF.LOOP.SUM | N=4; while / do / full-for sum 0..3 | Return `6` | Task 3.3 | proposed `VMSourceControlFlow` | 3.3 | missing-with-settled-oracle |
| CF.FOR.OMIT | omitted for-init and/or increment, bounded | Same sum `6` or certified termination | Task 3.3 boundary | proposed `VMSourceControlFlow` | 3.3 | missing-with-settled-oracle |
| CF.SWITCH | fallthrough / break / continue | Certified case values and skipped tails | Task 3.3 | proposed `VMSourceControlFlow` | 3.3 | missing-with-settled-oracle |
| CF.TERNARY | `cond ? L : R` | Only the chosen side-effect runs | Task 3.3; `FromConditional` overlap | existing-proven nearby + missing | 3.3 | mixed |
| CF.COMMA | comma expressions | Left-to-right side effects; last value returned | Task 3.3 | proposed | 3.3 | missing-with-settled-oracle |
| CF.REJ.BREAK | `break` outside loop/switch | Sema reject at authored range | Body/Sema control rules | proposed Sema | 3.3 | missing-with-settled-oracle |
| CF.REJ.CONT | `continue` outside loop | Sema reject at authored range | Body/Sema control rules | proposed Sema | 3.3 | missing-with-settled-oracle |
| CF.REJ.CASE | invalid/duplicate case | Sema reject at authored range | Body/Sema switch rules | proposed Sema | 3.3 | missing-with-settled-oracle |
| CF.RET.EARLY | early `return` before later `Mark()` | Later side effect does not run | `VMSourceUnwind` / cleanup family | proposed `VMSourceControlFlow` | 3.3 | missing-with-settled-oracle |

## Calls (3.4)

| Cell | Source / args | Expected | Citation | Identity | Owner | Disposition |
|---|---|---|---|---|---|---|
| CALL.POS | `int Pick(int First,int Second=2){ return First*10+Second; }` `Pick(3)` | `32` | Task 3.4 | proposed `VMSourceCalls` | 3.4 | missing-with-settled-oracle |
| CALL.NAMED | `Pick(Second:4,First:3)` | `34` | Task 3.4 | proposed `VMSourceCalls` | 3.4 | missing-with-settled-oracle |
| CALL.NS | `namespace N { int F(){ return 7; } }` call `N::F()` | `7` | `BuilderStageTests.NamedFunctionRetainsItsImageAndNamespaceAfterBuilderRelease` (AddOne) | existing-proven nearby + missing SourceExecution | 3.4 | mixed |
| CALL.THIS | method reads `this` members | Member value | `VMSourceObjects.SourceValueFieldWriteThenRead` | existing-proven | 3.4 | existing-proven |
| CALL.OVLD | overloads distinguished by independent returns | Each target returns its own constant | Task 3.4 | proposed `VMSourceCalls` | 3.4 | missing-with-settled-oracle |
| CALL.REJ.RETONLY | return-type-only fake overloads | Reject; no publishable output | overload rules | proposed Sema / `VMSourceCallContracts` | 3.4 | missing-with-settled-oracle |
| CALL.REJ.NAMED | duplicate/unknown named args; missing required | Reject at certified phase | call contracts | proposed `VMSourceCallContracts` | 3.4 | missing-with-settled-oracle |

## Objects and storage (3.5)

| Cell | Source / args | Expected | Citation | Identity | Owner | Disposition |
|---|---|---|---|---|---|---|
| OBJ.CTOR | two nested owned objects | Construct outer then inner; destroy inner then outer | Task 3.5; existing object Mark-trace helpers | proposed `VMSourceObjects` | 3.5 | missing-with-settled-oracle |
| OBJ.MEMBER | member write then read | `7` then `9` | `VMSourceObjects.SourceValueFieldWriteThenRead` | existing-proven | 3.5 | existing-proven |
| OBJ.REF | reference write-back | Caller-visible storage changes | Task 3.5 | proposed `VMSourceObjects` | 3.5 | missing-with-settled-oracle |
| OBJ.DISP | `B` override `F(3)` and `A@` to `B` | Both return `4`; `B.F()` returns `0` | `BuilderStageTests.ExactBaseOverrideAndDistinctOverloadsProduceRealDefinitions`; `asBC_CALLINTF` | proposed SourceExecution | 3.5 | missing-with-settled-oracle |
| OBJ.INH.REJ | cycle / `class A : int` / duplicate base / bad override | Fail at `DeclarationsResolved`; no body product | `BuilderStageTests.RecordInheritanceAndOverrideRulesFailAtDeclarationResolution` | existing-proven | 3.5 | existing-proven |
| STO.LOCAL | locals | Ordinary values | `VMSourceNumeric` locals | existing-proven | 3.5 | existing-proven |
| STO.GLOBAL.CONST | detached const global metadata | Publishes; `GetAddressOfValue()` is null before engine install | `GlobalDefinitions.DetachedGlobalMetadataDoesNotAllocateExecutableStorage` | existing-proven | 3.5 | existing-proven |
| STO.GLOBAL.MUT | mutable/void global metadata | `InvalidSignature`; zero published properties | `GlobalDefinitions.MutableGlobalAndVoidTypeAreRejectedWithoutPublication` | existing-proven | 3.5 | existing-proven |
| STO.GLOBAL.SRC | source `int Counter;` used as a mutable module global in SourceExecution | Reject / no usable mutation (same publication rule) | same definition-set contract | proposed SourceExecution / Sema | 3.5 | missing-with-settled-oracle |
| OBJ.CLEAN | early return / runtime fault | Initialized objects cleaned; Context recovery | language/surface runtime safety; `VMSourceScopeCleanup` / `VMSourceUnwind` | existing-proven nearby + missing exact ctor/dtor pair | 3.5 | mixed |

## Conversions and retired syntax (3.6)

| Cell | Source / args | Expected | Citation | Identity | Owner | Disposition |
|---|---|---|---|---|---|---|
| CV.WIDEN | runtime `int 7` to double | `7.0` | Task 3.6; `FloatCompareAssignAndNonIntCast` widen 8.5 | existing-proven nearby | 3.6 | existing-proven |
| CV.TRUNC | `int(4.5)` / `int(9.0/2.0)` | `4` (toward zero). Not a rejection. | `VMSourceNumeric.FloatCompareAssignAndNonIntCast` | existing-proven | 3.6 | existing-proven |
| CV.SIGNEXT | `int8 X = -1; return int(X)` | `-1` | `VMSourceNumeric.NarrowSignExtension` | existing-proven | 3.6 | existing-proven |
| CV.NARROW.CONST | const 256 → uint8 | Conversion false; caller bits unchanged (`99`) | `IntegralConstants.CheckedCaseConversionPreservesOutputOnFailure` | existing-proven | 3.6 | existing-proven |
| CV.RANGE.CONST | const `2147483648.0` → int32 | `Overflow` on the cast node | `IntegralConstants.FloatingConversionChecksRangeBeforeNativeConversion` | existing-proven | 3.6 | existing-proven |
| CV.OBJ.REJ | unrelated object forced cast | Reject; no publishable output | conversion definitions / Sema | proposed Sema | 3.6 | missing-with-settled-oracle |
| RET.SHARED | `shared class C {}` + following `int Good()` | Feature diagnostic `shared` at authored range; `Good` kept; not publishable | language/surface; `Syntax.ModuleModifiersReportFeatureAndKeepFollowingDeclaration` | existing-proven | 3.6 | existing-proven |
| RET.EXTERNAL | `external class C {}` / `external int Bad();` | Same pattern for `external` | same | existing-proven | 3.6 | existing-proven |
| RET.FUNCDEF | `funcdef int Callback(int);` | `FuncdefDeclaration` at `funcdef`; `Good` kept | `SyntaxTests` | existing-proven | 3.6 | existing-proven |
| RET.ANON | `function(int V){return V+1;}(41)` and capture lists | Diagnostic `AnonymousFunction`; not publishable | language/surface; `Lambda.ImmediateAnonymousFunctionCannotPublish` | existing-proven | 3.6 | existing-proven |
| RET.FOREACH | well-formed `foreach` after Sema | Emission `UnsupportedLowering`; no image. Malformed forms keep syntax catalog IDs. Inactive `#if` / ordinary identifiers are not retired. | `VMSourceAdmissionTests.UnsupportedBodyPublishesNoPartialImage`; `DiagnosticSyntaxTests` foreach rows; language/surface inactive-source | existing-proven | 3.6 | existing-proven |
| RET.INACTIVE | `#if REMOVED` shared/funcdef text | No removed-feature diagnostic | `SyntaxTests` inactive branch | existing-proven | 3.6 | existing-proven |

## Explicit non-oracles

- TestCode `.as` file counts.
- Runtime-variable `1 << N` for `N >= width` numeric results (unguarded C++ shift; no mask/trap contract).
- Productizing foreach execution.
- Frontend or VM repairs. A later production Change may specify runtime over-wide shifts; this ledger will not invent one.

## Execution identity

Filled 2026-09-15 after 3.x / 4.1. Shared NativeEngine binary: UE RunId `b99a111c19a2478a9f15027ae270f89f` (1239 Success). Parser-only prefix: `b8426d6bd67648718fccd1dc28383897` (5 Success). Editor rebuild `68a8c1cab9974acf838f3963ff3048f4`. Workspace `d:\Workspace\AngelscriptProject`.

| Cell group | Actual identity | Run |
|---|---|---|
| PAR.* | `NativeEngine.Parser.ParserContracts/Recovery/Precedence.*` as listed in `final-verification.md` | `b8426d6bd67648718fccd1dc28383897` and shared NativeEngine |
| AR.* / AS.CHAIN / LOG overlap / BIT source | `VMSourceNumeric.Runtime*`, `VMSourceExpressions.RuntimeCompoundAssignChainFromTwelve`, Sema compound/type rejects | shared NativeEngine |
| BIT.POS source lowering | `VMSourceExpressions.RuntimeInRangeShiftsKeepFixedWidthBits` = Sema-ok + `UnsupportedLowering`; values stay `IntegralConstants.LogicalAndArithmeticRightShiftKeepMaintainedASMeanings` | shared NativeEngine |
| CF.* | `VMSourceControlFlow.RuntimeN4LoopsSumZeroToThree`, `RuntimeCommaKeepsLeftToRightLastValue` (for-increment + multi-decl), `RuntimeEarlyReturnSkipsLaterMark`; Sema break/continue/case rejects | shared NativeEngine |
| CALL.* | `VMSourceCalls.RuntimePickDefaultSecondIsThirtyTwo`, `RuntimeQualifiedNamespaceCallIsSeven`, `ReturnTypeOnlyOverloadsPublishNoImage` plus existing Combine/Overloads | shared NativeEngine |
| OBJ.* / STO.GLOBAL.SRC | `VMSourceObjects.NestedOwnedObjectsConstructOuterThenInner`, `ReferenceWriteBackChangesCallerStorage`, `InheritedOverrideDispatchReturnsFour` (exact/extra), `MutableModuleGlobalRejectsPublication` | shared NativeEngine |
| CV.WIDEN / CV.OBJ.REJ | `VMSourceNumeric.RuntimeIntWidensToDoubleSeven`; `BodiesLanguageForms.UnrelatedObjectCastRejects` | shared NativeEngine |
| Retired | existing-proven Syntax/Lambda/foreach emission rows unchanged | shared NativeEngine |
