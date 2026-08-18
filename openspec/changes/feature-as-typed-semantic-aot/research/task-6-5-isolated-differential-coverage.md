# Task 6.5 isolated differential coverage audit

Date: 2026-08-16

## Purpose

Task 6.4 established that one AS function can be compiled by two independent
Static generation tasks and exposed as three separate test routes: interpreter
VM, BytecodeJIT, and TypedASTJIT. Task 6.5 expands that proof into a semantic
oracle. This note distinguishes existing useful coverage from the stricter
isolated-artifact requirement so old tests are reused without over-claiming.

## Current authoritative carrier

`DifferentialScalarValue(const int, const int)` is emitted by one fresh
BytecodeJIT generation Engine and one fresh TypedASTJIT generation Engine. The
two test-only translation units carry the same stable function key and distinct
symbol/address sets. VM, Raw, and reflected-Parms entries execute four rows,
and the ordinary production Provider contains exactly one entry for the key.
No production dual backend or shadow execution exists.

## Existing evidence versus remaining isolated proof

| Task 6.5 axis | Existing evidence | What remains for the isolated oracle |
| --- | --- | --- |
| scalar values and reflected parameter memory | `RunTypedASTScalarParity`, `TypedASTGeneratedProviderEntriesCompileLinkAndExecute`, task 6.4 six-entry differential case | General carrier rows beyond one `int(int,int)` function; scalar type/enum layouts must use independently generated artifacts |
| enum and exhaustive switch | `RunTypedASTStructuredControlFlowParity` compares VM, BytecodeJIT, and compiled Typed probe, including invalid exhaustive-enum exception | Move the enum target into independent Bytecode/Typed artifacts and freeze the exact exception observation |
| exception payload and route origin | `ExceptionRouteMatrixCharacterizesExecutionPaths`, nested checked exception tests, public UASFunction exception route | Add direct isolated-entry observations for exact first message/function/section/row/column and backend route; do not infer this from matching return values |
| cleanup plan/trace | compiler HIR and exception-region tests freeze empty plans for the supported scalar slice | Record empty plan plus deterministic empty runtime trace per isolated route; later managed effects remain rejected |
| eager evaluation order and mutation | `SemanticMutationParity`, capability showcase, generated-output order assertions, exception side-effect suppression | Add first/middle/last failing operand rows and one-evaluation compound/prefix/postfix state initialized independently per route |
| loop/switch control targets | structured-control-flow parity covers loop phases, nested break/continue, switch/fallthrough/default | Re-emit selected targets through the independent carrier and compare per-row state/results |
| arithmetic/conversion boundaries | scalar/power parity, `DoubleInt64ConversionsMatchInterpreter`, primitive conversion and generated-output helper tests | Add wrapping, divide/remainder failure, shift masking/sign fill, conversion boundary and power rows to the independent carrier |
| pure globals | capture/eligibility and Cache identity tests cover global facts | Add folded pure-global identity invalidation and ensure each route receives equivalent fresh global state |
| imports and private helpers | provider-private add/exception, replacement Engine and unbind-to-VM tests | Add independent import bind/rebind/unbind rows and prove exact reference-slot behavior without regenerating C++ |
| exported/inline/thunk calls | exported `FDateTime::DaysInMonth`, `Print`, Runtime callable/thunk linkage tests | Execute representative direct/exported/inline/thunk calls through all isolated routes and compare target counters |
| non-cloneable effects | eligibility rejects object/reference/container/suspend/managed-cleanup shapes | Make the differential runner reject such fixtures before execution rather than sharing mutable state |

## Implementation slices

1. Generalize the test-only entry carrier from two hard-coded entry sets into a
   generated stable-key registry while retaining the task-6.4 compatibility
   accessors. Add enum/reflected-Parms execution first. VM and Raw are required
   carrier entries, while Parms is an exact per-backend capability: the
   reflected static enum preserves BytecodeJIT's task-6.3 fail-closed
   VM+Raw/no-Parms plan for the ClassGenerator-only generated WorldContext
   suffix, whereas TypedASTJIT consumes the explicit reflected layout and
   exposes VM+Raw+Parms.
2. Add a route-result record containing value/status, the first failure
   payload, route/backend origin, and cleanup trace. Cover exhaustive-enum and
   checked integer failure before broader expressions.
3. Add cloneable fixture-state factories and evaluation/mutation/control-flow
   rows. Every route gets a distinct initial state; shared mutable observations
   are forbidden.
4. Add numeric boundary tables and pure-global invalidation.
5. Add import/private/native call-site bind/rebind/unbind and direct linkage
   rows. Non-cloneable effects remain explicit rejection cases.

## 6.5.2 RED checkpoint and source-position finding

The first checked-integer carrier test is deliberately RED before adding a
fixture or generated artifact. `Angelscript.TestModule.StaticJIT.AOT` found 31
tests and reported 30 success / one failure at
`Saved/Tests/typed-aot-isolated-exception-red-class/20260816_062437_179_7c73c13c`;
the sole failure is the missing independent BytecodeJIT row for
`int SemanticCheckedDivide(const int, const int)`. The earlier exact method
filter omitted the CQTest class-name segment and therefore matched no test; it
is discovery evidence only, not the RED claim.

The exception-path audit also found a concrete BytecodeJIT position gap. The
checked division/remainder opcodes call `DebugLineNumber()` before raising a
failure, but `asBC_ThrowException` does not. Consequently the isolated
exhaustive-enum artifact retains the entry-frame line instead of the switch
failure instruction's processed line. Task 6.5.2 must make the throw opcode
publish the current source position and retain column information alongside
the existing row before exact VM/BytecodeJIT/TypedASTJIT comparison is claimed.

The test-only route result will keep two origins separate: the runtime failure
record's maintained `RouteOrigin`/`BackendOrigin`, and the harness-selected
interpreter/BytecodeJIT/TypedASTJIT plus VM/Raw/Parms route. Context-free
generated entries legitimately report the generic `static-jit` runtime backend
without a Provider binding context; their independently generated backend is
therefore carried explicitly rather than forged into production state.

The first GREEN generation exposed a second, deeper position defect rather
than validating the initial opcode-only fix. Adding `DebugLineNumber()` to
`asBC_ThrowException` made the generated Bytecode artifact publish `111:4`,
the position inherited from the final enum case, while the compiler-owned
Typed HIR correctly published the switch position `104:2`. The synthesized
invalid-value edge is appended after all case bodies, so the maintained
compiler must emit `LineInstr(bc, snode->tokenPos)` immediately before its
`asBC_ThrowException`; changing the test oracle to accept `111:4` would freeze
the wrong source authority. The direct Bytecode opcode position hook remains
necessary to consume that corrected line-table entry.

The same generation produced the new checked-integer artifacts and made their
shape inspectable before execution: Bytecode emits VM+Raw/no-Parms with
`SCRIPT_DEBUG_CALLSTACK_POSITION(118, 4)` before divide-by-zero/overflow,
TypedASTJIT emits VM+Raw+Parms with
`TypedFrame.SetSourcePosition(118, 2)`, and both carry the same stable function
key. The differing expression columns will be compared against the
interpreter's public exception location rather than assumed equivalent until
the focused runtime test provides authoritative evidence.

The parent task remains open until every axis is complete. Each slice follows
RED -> implementation -> generated build -> focused tests -> complete AOT
prefix -> official Verify, with evidence appended to `implementation-progress.md`.

## 6.5.2 GREEN checkpoint and final position authority

The first generated runtime comparison remained deliberately useful RED at
`Saved/Tests/typed-aot-isolated-exception-first-runtime/
20260816_064348_209_f79dd197`: the synthesized exhaustive-enum failure was
reported at interpreter `103:2`, BytecodeJIT `104:4`, and TypedASTJIT `104:2`.
This proved that changing only the compiler-owned throw line was insufficient
and exposed two independent runtime decoding defects:

- the interpreter loop executes from local `l_bc`/`l_sp`/`l_fp` registers, but
  `asBC_ThrowException` called `SetInternalException` while
  `m_regs.programPointer` still described the previous synchronized location;
  the opcode now synchronizes the local registers back to `m_regs` before
  publishing the exception and returning;
- BytecodeJIT treated the second output of `asCScriptFunction::GetLineNumber`
  as a source column even though it is the section index. The maintained fork
  packs row in the low 20 bits and column in the high bits of the returned
  source position, so the generator now decodes those two fields and retains
  the section output only as section identity.

The earlier compiler fix remains necessary: the synthesized invalid exhaustive
switch edge receives `LineInstr(bc, snode->tokenPos)` immediately before
`asBC_ThrowException`, and the Bytecode opcode calls `DebugLineNumber()` before
raising the failure. After the runtime fixes and official regeneration, both
generated enum bodies publish `104:2`, and both checked-division bodies publish
`118:2`. The interpreter now reports the same first-failure positions.

The route carrier owns a typed first-failure payload (message, function,
section, row, column, runtime route/backend origin), keeps the selected test
backend/entry route separate from that runtime origin, and records the
compile-time cleanup-plan state plus action count. The supported scalar rows
require `VerifiedEmpty`, zero actions and an empty runtime cleanup trace for
TypedASTJIT. BytecodeJIT records `NotCaptured`, because it has no Typed HIR
cleanup plan. Exhaustive-enum invalid value `99` and division `12 / 0` are
executed through a fresh interpreter context and every independently generated
VM/Raw/available Parms route; all routes must fail with the same first payload
while preserving their own legitimate route origin.

Fresh verification evidence:

- `Saved/Build/typed-aot-isolated-exception-position-fix-build/
  20260816_064746_989_debe595f` — Runtime position fixes build PASS;
- `Saved/Commandlet/typed-aot-isolated-exception-position-fix-generate/
  20260816_064820_869_7bed84a3` — official Generate PASS;
- `Saved/Build/typed-aot-isolated-exception-position-fix-generated-build/
  20260816_064913_612_ed898ba8` — regenerated Bytecode/Typed artifacts build
  PASS;
- `Saved/Tests/typed-aot-isolated-exception-position-fix-exact/
  20260816_064927_250_efbad254` — exact isolated checked-integer method 1/1
  PASS;
- `Saved/Tests/typed-aot-position-hooks-typed-exact/
  20260816_065024_309_f4ecf303` and
  `Saved/Tests/typed-aot-position-hooks-bytecode-exact/
  20260816_065057_722_f4c2d731` — the two directly affected generator hooks
  each 1/1 PASS;
- `Saved/Commandlet/typed-aot-isolated-exception-position-fix-verify/
  20260816_065142_181_f5aae906` — official Verify PASS with zero errors;
- `Saved/Tests/typed-aot-isolated-exception-generated-output-verify-exact/
  20260816_065229_799_1af7a029` — exact generated-output comparison 1/1 PASS;
- `Saved/Tests/typed-aot-isolated-exception-position-fix-aot/
  20260816_065345_508_6c7901af` — complete AOT prefix 41/41 PASS, zero failed,
  skipped or not-run tests.

Task 6.5.2 is complete. Parent task 6.5 remains open for cloneable mutable
state, evaluation/mutation/control-flow traces, numeric/global boundaries,
import/native/private-bridge rows, and non-cloneable-effect rejection.

## 6.5.3 GREEN checkpoint: cloned state and ordered binary evaluation

The test-only typed-control-flow fixture now contains one bounded scalar root,
`SemanticCloneableState(int Seed, int Mode, bool bLeft, bool bRight)`. A
`FCloneableDifferentialState` value is copied independently for the interpreter,
Bytecode Raw/VM, and TypedASTJIT Raw/VM/reflected-parameter routes. The source
state retains its sentinel observed value after every case, so matching results
cannot be produced by accidentally sharing a mutable test counter between
routes.

The four fixture modes cover the task-6.5.3 axes without adding a production
runtime abstraction:

- nested eager binary expressions contain three prefix increments and encode
  both the final trace and the three observed operand values, proving
  left-to-right, exactly-once evaluation;
- an `&&` chain places the increment in the middle operand and covers
  first-operand rejection, last-operand rejection, and the all-true path;
- compound assignment plus prefix and postfix increments encodes the updated
  value, prefix result, and postfix-old result;
- a `while` containing a `for` and nested `switch` exercises loop phases plus
  nearest-target `continue` and `break` transfers.

The initial generator/carrier/test build passed at
`Saved/Build/typed-aot-cloneable-state-red-build/
20260816_070236_005_e5ec1095`. The first exact run was the intended generation
RED at `Saved/Tests/typed-aot-cloneable-state-red/
20260816_070258_035_cdb80cfa`: the fixture compiled, but neither independent
artifact was registered. Adding one Bytecode and one Typed task made official
Generate pass at `Saved/Commandlet/typed-aot-cloneable-state-generate/
20260816_070530_266_95ad4741`; both artifacts use stable key
`169ac06f87b6ff4213bade0bb8d12b1d533553178b5660298da6a6e66fd90855`.
Bytecode exposes Raw+VM and deliberately no Parms entry. TypedASTJIT exposes
Raw+VM+Parms, with reflected offsets `Seed=0`, `Mode=4`, `bLeft=8`,
`bRight=9`, generated WorldContext `=16`, and return `=24`. The generated files
built at `Saved/Build/typed-aot-cloneable-state-generated-build/
20260816_070758_640_8c4aa257`.

That first generated execution produced a second, semantic RED at
`Saved/Tests/typed-aot-cloneable-state-green/
20260816_070821_253_40006d0b`: interpreter and both Bytecode routes returned
the authoritative `3123`, while Typed Raw returned `3321`. The Typed emitter
had embedded three mutation lambdas as arguments to nested C++ scalar helper
calls. Building the output string in HIR order did not sequence C++ function
arguments, and MSVC evaluated the side-effecting arguments in a different
order. Accepting `3321` would therefore have hidden a real TypedASTJIT semantic
defect.

Ordinary Typed binary expressions now materialize their left and right
operands into typed local C++ temporaries in HIR order and only then execute
the native operation/helper. This preserves AngelScript ordering while
retaining ordinary native scalar operations and without introducing
`FAngelscriptJITExecutionContext`. `ShortCircuit` remains a direct `&&`/`||`
expression so its right operand is not eagerly materialized. The emitter fix
built at `Saved/Build/typed-aot-binary-evaluation-order-fix-build/
20260816_071133_203_51539dcc`; regenerated output passed at
`Saved/Commandlet/typed-aot-cloneable-state-order-fix-generate/
20260816_071148_194_b9722662`; and all regenerated Typed artifacts built at
`Saved/Build/typed-aot-cloneable-state-order-fix-generated-build/
20260816_071243_604_57415abb`.

Final evidence:

- `Saved/Tests/typed-aot-cloneable-state-order-fix-green/
  20260816_071257_135_df430e47` — exact six-route cloned-state differential
  test 1/1 PASS;
- `Saved/Commandlet/typed-aot-cloneable-state-order-fix-verify/
  20260816_071408_806_9b2ed881` — official Verify PASS;
- `Saved/Tests/typed-aot-cloneable-state-generated-output-verify-exact/
  20260816_071457_191_ce036af7` — two-fresh-Engine generated-output and byte
  determinism verification 1/1 PASS;
- `Saved/Tests/typed-aot-cloneable-state-order-fix-aot/
  20260816_071623_636_dc262f63` — complete AOT prefix 42/42 PASS, zero failed,
  skipped, or not-run tests.

Task 6.5.3 is complete. Parent task 6.5 remains open for numeric/global
boundaries, imported/direct/private-bridge rows, and explicit rejection of
non-cloneable effects.
