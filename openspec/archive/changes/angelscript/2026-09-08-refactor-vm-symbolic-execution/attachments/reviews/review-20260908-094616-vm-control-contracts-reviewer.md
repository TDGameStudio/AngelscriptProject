---
review_schema: review-v2
review_kind: external
requested_by: user
state: superseded
assigned_at: 2026-09-08T09:46:16.992064+08:00
reviewed_at: 2026-09-08T09:49:30.170766+08:00
closed_at: 2026-09-08T13:17:22.117476+08:00
snapshot_ref: D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/review-20260908-094616-vm-control-contracts
snapshot_sha256: 928178234f4369841827cb8e427176ae76324f6dbe42d2b30aa17c2fa5bb93a5
verdict: CHANGES_REQUIRED
---

# Remaining VM control and frame contract re-evaluation

The continuing user request explicitly asks for review repair, replan where necessary and completion. This inline tests-first Review reads the assigned immutable snapshot of 1,074 files. Scope is the original F01 call/return ABI, indexed CFG and signed frame contract, with F04 indirect dispatch as context. Exclusions are unrelated host changes, dormant runtime, Standalone, JIT and exhaustive reassessment of other original findings. Supplied reports prove 381/381 VM cases and eight/eight stomp unwind on the current source. The stomp report has one engine LogHttp network probe warning. Those passes establish the actual 6.7/6.8 fixes; they do not prove the untested contracts below.

`R/` means Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/; `T/` means Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/. Locations refer to copied snapshot content. No implementation or older Review was edited in this review phase.

## X01 — Body argument size and RET are not authenticated to the callable ABI

severity: Required
status: resolved
Location: R/as_bytecode_verifier.cpp:227-231,469-478; R/as_bytecode_linker.cpp:98-100,463-481,867-907; R/as_context.cpp:2155-2176; T/VMDispatchTests.cpp:25-34.

Original observation: Frame.ParameterDwords is compared only to Body.ParameterSize. Neither is compared with the body function's callable requirement or target declaration. RET's immediate is only a signed-width operand; no check requires it to equal the declared argument/receiver storage. LowerFunction's PshC4/RET shorthand additionally replaces any supplied RET count with zero. ApplyCallContract assumes the callee consumes the authenticated input, while Context restores caller SP and then pops exactly the RET word.

Concrete static counterexample: real void F(double) with Body.ParameterSize=2 and RET(0) is admitted, though a verified PshC8/CALL F consumes two DWORDs abstractly and consumes none at runtime. Repetition accumulates argument storage. Forged ParameterSize=0 plus RET(0) avoids even body-local consistency. A method constant shorthand resets a nonzero receiver pop to zero. Existing constant-return helper supplies zero parameters/RET even for method fixtures; scalar return values do not observe the mismatch. No malformed body was executed during review.

Impact: the original F01 call/return ABI resolution condition remains open despite the valid 6.7 caller-side storage fix.

Resolution condition: require each reachable RET to match the body ABI and authenticate body argument storage to real metadata before publication, including bodies whose declaration is supplied externally. Preserve correct pop counts in shorthand lowering. Direct/decode/link negative cases cover under/over/negative pop, forged body sizes, receiver and wide/reference inputs; valid nested repeated calls have a literal stack-balance/result oracle.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Task 6.10: VMReturnAdmission authenticates body/RET ABI against real receiver, hidden-result and wide/reference storage, rejects forged sizes and executes repeated nested calls with stack/result oracles. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

## X02 — CallPtr has no call-site signature or abstract argument consumption

severity: Required
status: resolved
Location: R/as_bytecode_verifier.cpp:104-114,167,474-478; R/as_bytecode_opcode.cpp:126-137 and CallPtr Local operand schema; R/as_bytecode_linker.cpp:163-169; R/as_context.cpp:4108-4191; T/VMDispatchTests.cpp:192-255,460-500.

Original observation: CallPtr has a single Local operand, so CallRequirement finds no FunctionSlot and ApplyStackEffect treats its dynamic effect as zero. Runtime dispatch invokes the target's real signature, including a delegate's bound receiver. Existing fixtures mainly call zero-parameter functions or bound zero-parameter methods; null behavior proves a runtime guard, not a signature contract.

Concrete static counterexample: FuncPtr(real void F(double)), PopRPtr, CpyRtoV8(local), PshC4(1), CallPtr(local), RET is admitted even though the target reads two argument DWORDs. A correct wide call leaves phantom abstract stack words because its consumption is zero. Different callable types passed in the same raw local cannot be compared with any declared call-site expectation. These are static counterexamples, not observed crashes.

Impact: F01's complete ABI and F04's indirect-call contract are incomplete. Stable symbol authentication of the FuncPtr operand alone cannot authenticate a later arbitrary indirect target.

Resolution condition: carry a complete expected indirect-call ABI through image/codec/lowering, consume it in CFG analysis, and validate the actual callable target against it before invocation. Preserve null exceptions, same-signature different targets, free/native functions and bound delegates. Add actual wide/reference negative and balanced-call controls, decoded contracts and mismatch-without-callback execution. Do not infer signatures from names or silently assume zero arguments.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Task 6.11: VMIndirectAdmission carries an explicit expected signature through image/codec/CFG/runtime; wrong actual return/parameter/mode/receiver shapes reject before callback, compatible script/native/delegate calls and null recovery pass. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

## X03 — Indexed jumps do not visit all possible table successors

severity: Required
status: resolved
Location: R/as_bytecode_opcode.cpp:126-128; R/as_bytecode_verifier.cpp:516-550; R/as_bytecode_linker.cpp:439-461; R/as_context.cpp:2682-2684; T/VMResourceOpcodeMatrixTests.cpp indexed jump execution coverage.

Original observation: JMPP is classified IndexedJump, but the verifier worklist handles only Jump and ConditionalJump explicitly. IndexedJump therefore follows Index+1 and the first table JMP only. Linker checks a table count fits in the body, but does not establish all table entries are fixed-width JMPs; runtime advances by index*2 DWORDs, so instruction shape is part of the execution contract.

Concrete static counterexample: JMPP(local, max=1), JMP(valid RET), JMP(POPPTR without push), RET admits the second table target as unreachable. Equivalent skipped lifetime violations evade 6.8 because the missing edge is outside its existing branch model. A malformed non-JMP table entry can invalidate the assumed two-DWORD stride. Runtime table index bounds are also not carried into the lowered JMPP instruction, so an out-of-range local can escape the declared table.

Impact: advertised CFG admission and opcode dispatch do not share the same reachable successors.

Resolution condition: validate bounded table structure and every possible successor, including stack/lifetime joins and non-first entries; ensure runtime cannot dispatch outside the declared range. Direct/decoded negative and valid multi-entry execution controls must prove all entries and index boundary behavior.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Task 6.12: VMIndexedAdmission validates every fixed-width table entry and CFG successor; legal entries return 11/22, negative/max+1/large indices throw the exact exception then recover to 97. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

## X04 — Frame span arithmetic uses the opposite direction from interpreter addressing

severity: Required
status: resolved
Location: R/as_bytecode_verifier.cpp:29-47; R/as_bytecode_linker.cpp:168 and local lowering; R/as_context.cpp:629,693,1849,3202-3209; T/VMOperandContractsTests.cpp:230-266.

Original observation: verifier enumerates Dword = Offset + Index and permits nonnegative offsets in [0, FrameSize). Interpreter starts at Frame-Offset and reads/writes forward in memory, so each next storage DWORD has symbolic offset Offset-Index. Actual locals occupy Frame[-FrameSize..-1], and arguments start at Frame[0]. The new Context fallback fix correctly respects that runtime range, but general operand verification still uses the old convention.

Concrete static counterexamples: no-argument FrameSize=4 with SetV4(Local=0) is admitted and writes at Frame[0], which may be one-past-stack for a top-level function. ParameterSize=1 with Local=-1 is admitted but writes Frame[1], beyond the sole argument at Frame[0]. SetV8(Local=1) is admitted as offsets 1,2 while actual storage spans Frame[-1],Frame[0], crossing into arguments. Conversely SetV8(Local=4) is rejected though Frame[-4],Frame[-3] lies within four local DWORDs. Existing positive/negative operand fixtures encode the reversed convention, so their GREEN repeats the error. No new malformed operand was executed during review; the supplied stomp investigation independently demonstrates why Frame[0] cannot be treated as an unconditional local.

Impact: F01's signed frame/argument bound resolution condition remains unmet. Accepted declarations and source/runtime offsets must have one physical interpretation.

Resolution condition: define the interpreter-consistent signed coordinate and validate complete local/argument spans without crossing regions or narrowing. Align frame/result/cleanup producers and existing synthetic fixtures with that contract, preserving their literal execution oracles. Add direct/decoded positive/negative cases for zero, first/last local, argument zero/last, wide boundary crossing and signed limits; execute safe boundary controls with memory checking. Keep invalid images out of execution.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.9/11.4: VMFrameAdmission and VMFlowAdmission use physical signed frame coordinates and full-width span arithmetic, direct/decoded 64/65-DWORD boundaries and safe memory-checked local-edge execution. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

## Verdict and verification story

CHANGES_REQUIRED. Read copied flow/operand/dispatch/matrix tests before copied verifier/linker/opcode/Context code and the original F01 resolution condition. Current W01/W02 repairs and their 381-case regression are real. No new broad test run, crash experiment, source mutation, plan mutation or prior Review edit was performed in this review phase. Four remaining contracts need exact proof; an aggregate test count cannot close F01. The coordinator owns triage and any planning response.

## Coordinator supersession

Superseded 2026-09-08T13:17:22.117476+08:00 by [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md) because this report describes an earlier immutable implementation. Its CHANGES_REQUIRED verdict and original finding text remain historical truth. Every finding now has a specific appended resolution and the new snapshot re-evaluation is APPROVE.
