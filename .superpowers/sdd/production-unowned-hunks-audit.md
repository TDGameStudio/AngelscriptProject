# Production Unowned-Hunk Audit

Date: 2026-07-27
Source record: `openspec/changes/test-as-native-sdk-comprehensive-coverage/handoffs/production-hunk-ownership-final.csv` and `SDK-QUALITY-237`

## Conclusion

The 15 currently `Unowned` production hunks do not represent one coherent change:

| Disposition | Hunk IDs | Recommendation |
|---|---|---|
| Assign to an existing active change | P022, P138, P142, P149, P150, P151 | Amend `fix-as-reference-bytecode-ownership-persistence` to name these six supporting hunks and their regression owners explicitly. |
| Create focused change | P019 | `fix-as-static-jit-debug-text-whitespace` |
| Create focused change | P066, P067, P068, P069 | `fix-as-switch-int-max-lowering` |
| Create focused change | P091, P092 | `fix-as-double-int64-bytecode-execution` |
| Explicit user-authorized non-semantic cleanup | P073, P074 | Retain without inventing a behavioral root-cause owner or regression. |

The current CSV/issue grouping needs correction before it is treated as authoritative: P138, P142, P150, and P151 are not `dTOi64`/`dTOu64` save-load work. They implement the missing reader/writer handling for `asBCTYPE_W_rW_ARG`, used by GETOBJ/reference opcodes. The numeric conversion opcodes use the already-supported `asBCTYPE_wW_rW_ARG`.

## Per-hunk findings

| ID | Exact production evidence | Semantic root cause | Current regression owner(s) | Ownership decision |
|---|---|---|---|---|
| P019 | `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptBytecodes.cpp:6743`: adds `Out.TrimEndInline()` before `FAngelscriptBytecode::GetInstrDebugString()` returns. | The formatter seeds the opcode name with a separating space. Instructions with no rendered operands retain that space, so generated AOT debug-comment lines contain trailing whitespace. | Comprehensive issue `JIT-004`; closest existing automation is `FAngelscriptStaticJITAotTests::GeneratedOutputVerify` in `AngelscriptStaticJITAotTests.cpp`, supplemented by the recorded literal trailing-whitespace scan. | New `fix-as-static-jit-debug-text-whitespace`. The existing `static-jit-diagnostics` capability and archived `improve-static-jit-diagnostics` change concern diagnostic surfaces, not generated debug-text normalization. |
| P022 | `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.h:179`: exports `FAngelscriptPrecompiledFunction::Process` with `ANGELSCRIPTRUNTIME_API`. | The AngelscriptTest DLL now directly exercises precompiled reference-operand remapping; without exporting `Process`, the exact regression cannot link across the module boundary. This is a narrow testability/API support change, not a new runtime algorithm. | `FAngelscriptPrecompiledDataArchiveTests::ReferenceCopyTypeOperandsRemapAcrossPrecompiledLoad` in `AngelscriptPrecompiledDataArchiveTests.cpp`; its recorded first failure was LNK2019, followed by the intended `Process` remap assertion after export. | Existing active `fix-as-reference-bytecode-ownership-persistence`. Amend its impact/tasks to name this required narrow export and require the export and regression to be rolled back together. The completed `refactor-as-native-sdk-regression-suite` export inventory is intentionally exact and excludes StaticJIT, so it is adjacent rather than the owner. |
| P066 | `Plugins/Angelscript/Source/AngelscriptRuntime/PrivateSource/Angelscript/as_compiler.cpp:5143-5146`: widens the `caseValues[n-1] + 5` range test to `asINT64`. | Signed 32-bit overflow near `INT_MAX` can corrupt the gap/range grouping decision before jump-table emission. | `FSwitchTests::SelectorsByCaseAndExit` in `Language/ControlFlow/AngelscriptNativeSwitchTests.cpp`, product `LANG-CF-SWITCH`, comprehensive issue `LANG-CF-006`; cases exercise 2147483642, 2147483643, and dense 2147483645 through 2147483647. | New `fix-as-switch-int-max-lowering`; keep P066-P069 in one rollback boundary. |
| P067 | Same file, line 5167: widens `maxRange + 5` before comparison. | The heuristic deciding whether to emit a dense table can overflow at the upper signed boundary and choose the wrong lowering path. | Same `FSwitchTests::SelectorsByCaseAndExit` owner and high-boundary cells. | Same new `fix-as-switch-int-max-lowering`. |
| P068 | Same file, lines 5201-5203: changes dense-table loop index from `int` to `asINT64`. | An `int` induction variable wrapping after 2147483647 can make the table-emission loop non-terminating or incomplete. | Same `FSwitchTests::SelectorsByCaseAndExit` owner and high-boundary cells. | Same new `fix-as-switch-int-max-lowering`. |
| P069 | Same file, line 5205: compares each case value against the widened induction variable. | This is the companion type-correct comparison required by P068; retaining a narrowed comparison would reintroduce the boundary error. | Same `FSwitchTests::SelectorsByCaseAndExit` owner and high-boundary cells. | Same new `fix-as-switch-int-max-lowering`. |
| P073 | Same file, line 8296: comment adopts the user-required “priority table” terminology. | None; terminology-only comment edit. | None, and none is warranted. | Retain as explicitly user-authorized non-semantic cleanup with no behavioral owner. |
| P074 | Same file, line 8328: companion comment adopts “table” terminology. | None; terminology-only comment edit. | None, and none is warranted. | Retain under the same explicit authorization without opening a behavioral change. |
| P091 | `Plugins/Angelscript/Source/AngelscriptRuntime/PrivateSource/Angelscript/as_context.cpp:3451-3452`: `dTOi64` reads `SWORDARG1(l_bc)` and advances by two words. | The interpreter decoded the two-word `asBCTYPE_wW_rW_ARG` instruction as a one-word instruction, treated its destination offset as the double source offset, and left the program counter on the operand word. The recorded failure showed `dTOi64 0x000e0095 0x0000000c` followed by a spurious later `CALLBND`. | Primary interpreter owner: `FConstructorParameterTests::ParameterTypesByArityAndSelection` in `Language/Constructors/AngelscriptNativeConstructorParameterTests.cpp`, product `LANG-CTOR-PARAM-SELECT`. Interpreter breadth: `FNumericConversionTests::SourceTargetFormAndValue` in `Language/Conversions/AngelscriptNativeNumericConversionTests.cpp`, product `LANG-CONV-NUMERIC`. No exact generated-code StaticJIT `dTOi64`/`dTOu64` parity owner currently exists; `BitCastAndNumericParity` exercises the opposite helper direction. | New `fix-as-double-int64-bytecode-execution`. This is interpreter execution, not reference-bytecode persistence; generated StaticJIT parity implementation remains open. |
| P092 | Same file, lines 3461-3462: makes the equivalent source-offset and instruction-length correction for `dTOu64`. | Same decoder defect for unsigned 64-bit conversion. | Same constructor/conversion owners, with explicit unsigned coverage required. | Same new `fix-as-double-int64-bytecode-execution`. |
| P138 | `Plugins/Angelscript/Source/AngelscriptRuntime/PrivateSource/Angelscript/as_restore.cpp:3049`: adds `asBCTYPE_W_rW_ARG` to reader encoding handling. | The bytecode reader did not deserialize GETOBJ-style two-operand instructions carrying a value operand plus an adjustable stack/reference offset. | `FAngelscriptPrecompiledDataArchiveTests::ReferenceCopyTypeOperandsRemapAcrossPrecompiledLoad`; the active reference-persistence change also records the parameter/return save-load-restore reproducer. | Existing active `fix-as-reference-bytecode-ownership-persistence`. |
| P142 | Same file, lines 3668-3671: adjusts only the second operand for `asBCTYPE_W_rW_ARG`. | On restore, the reference/stack-position operand must be remapped while the first value operand must remain unchanged. Missing or indiscriminate adjustment corrupts GETOBJ/reference behavior. | Same precompiled archive regression plus the active change's save-load-restore parameter/return scenario. | Existing active `fix-as-reference-bytecode-ownership-persistence`. |
| P149 | Same file, line 5778: corrects GETOBJ's format comment from `W_ARG` to `W_rW_ARG`. | The old comment concealed the actual two-operand contract and directly contributed to the reader/writer omission. Although comment-only mechanically, it documents the exact fixed invariant. | Same GETOBJ/reference persistence regressions. | Existing active `fix-as-reference-bytecode-ownership-persistence`, as supporting documentation for P138/P142/P150/P151. Do not group it with P073/P074. |
| P150 | Same file, lines 5864-5867: writer-side stack-position adjustment for the second `asBCTYPE_W_rW_ARG` operand. | Save-side adjustment omitted the GETOBJ/reference offset, preventing correct stack remapping across serialization. | Same precompiled archive regression plus save-load-restore parameter/return scenario. | Existing active `fix-as-reference-bytecode-ownership-persistence`. |
| P151 | Same file, line 5970: serializes the `asBCTYPE_W_rW_ARG` format. | The writer had no encoding branch for the two-operand GETOBJ/reference format, so its second word was not persisted correctly. | Same precompiled archive regression plus save-load-restore parameter/return scenario. | Existing active `fix-as-reference-bytecode-ownership-persistence`. |

## OpenSpec fit and proposed scopes

### Amend the existing active reference-bytecode change

`openspec/changes/fix-as-reference-bytecode-ownership-persistence/` is an exact semantic fit for P022, P138, P142, P149, P150, and P151:

- its design explicitly requires a reader/writer path for every adjusted stack-position operand format;
- its proposal covers object/reference/native-function operands across save/load/restore;
- tasks 2.2 and 3.2 already cover save/load behavior and stack-position adjustment;
- the comprehensive investigation records GETOBJ as `GETOBJ(offset, variableOffset)` and identifies its second word as the reference offset used by both the interpreter and StaticJIT.

Amend that change only to make the already-required production hunks, narrow `Process` export, named regression method, and rollback boundary explicit. No new parallel change should be opened for them.

### `fix-as-static-jit-debug-text-whitespace`

Scope:

- normalize `GetInstrDebugString()` output so no-operand instructions do not retain a synthetic separator;
- add a deterministic direct formatter or generated-output assertion that covers both operand and no-operand instructions;
- regenerate representative AOT output and verify generated source has no trailing whitespace;
- keep P019 and its regression in one rollback boundary.

Do not broaden this into diagnostic commands, log routing, or general AOT formatting cleanup.

### `fix-as-switch-int-max-lowering`

Scope:

- keep range-gap arithmetic, dense-table heuristics, iteration, and comparisons non-overflowing at the upper `int32` boundary;
- own P066-P069 as one indivisible compiler fix;
- retain `LANG-CF-SWITCH` high-boundary execution cells and ordinary low/mid-range controls;
- verify compilation terminates and selects/executes the correct case for `INT_MAX`-adjacent values.

The completed `refactor-as-native-sdk-regression-suite` requires switch coverage but does not own this newly exposed compiler defect.

### `fix-as-double-int64-bytecode-execution`

Scope:

- correct interpreter decoding of `dTOi64` and `dTOu64` as two-word `asBCTYPE_wW_rW_ARG` instructions;
- own P091-P092 together;
- retain signed and unsigned conversion regressions through constructor-parameter and direct numeric-conversion paths;
- compare interpreter behavior with StaticJIT as a parity check.

Do not include `as_restore.cpp`: `asBCTYPE_wW_rW_ARG` was already serialized and translated correctly. The defect is confined to the two interpreter handlers.

## Record correction required

Before closing `SDK-QUALITY-237`, update the CSV/issue narrative so that:

1. P091-P092 are the only numeric conversion decoder hunks.
2. P138/P142/P150/P151, with P149 as the invariant comment, are GETOBJ/reference persistence hunks.
3. P022 is recorded as the narrow cross-module regression-enabling export for that persistence change.
4. P073-P074 are recorded as explicitly user-authorized non-semantic cleanup, not forced into a behavioral owner.

This audit was read-only apart from this report. It inspected the existing source diff, regression sources, comprehensive investigation records, and active/archived OpenSpecs; it did not build, run tests, commit, or claim fresh execution evidence.
