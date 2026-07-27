# Runtime Context Assertion-Depth Implementation

Date: 2026-07-27

## Scope

Implemented the six Runtime Context assertion-depth review actions in exactly these
AngelScript SDK test sources:

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Runtime/AngelscriptNativeContextControlTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Runtime/AngelscriptNativeContextReturnValueTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Runtime/AngelscriptNativeContextExceptionTests.cpp`

No catalog, review CSV, Support source, production source, OpenSpec proposal, or task
file was modified. This handoff is the only non-test-source file created, as required.
The existing product IDs, case IDs, generated-source printing, and existing behavior
assertions were retained.

## Product Disposition

| Product | Review requirement addressed | Implemented observable oracle |
| --- | --- | --- |
| `RT-CTX-CONTROL-FLOW-EXECUTION` | Add cleanup proof beyond RAII. | The original loop-boundary `Entry` execution now uses an explicit primary context, asserts `asSUCCESS` from `Unprepare`, runs the same exact declaration in a separate control context, unprepares it, then asserts `FScopedNativeModule::Discard()` succeeds and `GetModule(..., asGM_ONLY_IF_EXISTS)` is null. |
| `RT-CTX-ARITHMETIC-EXCEPTION-DETAILS` | Unprepare and recover each exception context, or use a cleanup callback. | Every direct/nested divide/modulo cell retains its exception result/text/line/failing-frame assertions, adds printed `Recover`, unprepares after the exception, executes `Recover` on that same context, asserts return `7`, and unprepares again. A separate control context executes `Recover`; every cell explicitly discards its module and checks the `asGM_ONLY_IF_EXISTS` lookup is null. |
| `RT-CTX-SUSPEND-FORK-REJECTION` | Add cleanup and cleared-callback/independent-control isolation. | The rejected active-context `Suspend` result, finished state, and return `42` remain asserted. A raw line callback observes the rejected-suspend execution, is explicitly cleared, and a reused-context `Control` execution proves the callback count does not increase. A second independent control context executes `Control`; both contexts unprepare, followed by explicit discard and null lookup. |
| `RT-CTX-RETURN-ABI-SHAPES` | Add cleanup proof for configured float and signed integer ABI shapes. | Both the configured floating result and signed integer `-42` path explicitly unprepare their primary contexts, execute their function in an independent control context, unprepare it, explicitly discard the module, and assert a null `asGM_ONLY_IF_EXISTS` lookup. The selected float accessor and signed DWORD oracle are unchanged. |
| `RT-CTX-RETURN-CONTROL-PATHS` | Explicitly clean both independent return-path contexts and module. | The original positive (`40`) and fallback (`2`) contexts now each assert successful `Unprepare`; both are released before explicit module discard, and a null `asGM_ONLY_IF_EXISTS` lookup confirms removal. The pre-existing separate positive/fallback contexts remain the isolation controls. |
| `RT-CTX-STACK-OVERFLOW-METADATA` | Unprepare/recover the overflow context and add a non-overflow control. | The recursion function still asserts `asEXECUTION_EXCEPTION`, exact `Stack overflow`, recursive function identity, and now explicitly asserts a positive exception line. The same context unprepares, executes `Recover` with return `7`, and unprepares again. A second non-overflow control context executes `Recover`; the module is explicitly discarded and checked absent by `asGM_ONLY_IF_EXISTS`. |

## Fork-Specific Decisions

- No `GetModuleCount() == 0` assertion was added. The current fork keeps module-count
  state after `DiscardModule`; each cleanup oracle uses the required exact-name
  `GetModule(..., asGM_ONLY_IF_EXISTS) == nullptr` check instead.
- AngelScript global function registration does not expose a per-function unregister
  operation suitable for this fixture. The suspend test therefore proves callback
  clearing through its context-owned raw line callback: it is observed before clear,
  explicitly cleared, then proven not to fire during reused-context control execution.
  The registered native suspend function remains engine-owned until case teardown.
- `FScopedNativeDebugCallbacks` is used only for the suspend test so the raw line
  callback is enabled on the standalone raw SDK engine. It is RAII-scoped and restores
  the static debug callback flags at case exit.

## Static Checks Performed

- Read the required `angelscript-test-guide` and `Documents/UnitTest/UnitTest.md`
  instructions before editing.
- Compared each product against the assertion-depth review's `MissingOracle` and
  `RequiredAction`, and the catalog's existing generated-source evidence.
- Confirmed all three target sources contain the expected explicit `Unprepare`,
  explicit successful discard, and `asGM_ONLY_IF_EXISTS` null-lookup assertions.
- Confirmed none of the three target sources contains a `GetModuleCount` assertion.
- Ran targeted `git -C Plugins/Angelscript diff --check -- <three target files>`:
  **PASS** (no whitespace errors). Git emitted only repository-wide LF-to-CRLF
  advisory warnings.

## Validation Deliberately Not Performed

Per task direction, this batch did **not** build the plugin or run UE Automation tests.
Consequently, the raw-context callback execution and the full SDK prefix remain
runtime-unverified. A follow-up validation owner should run the narrow Runtime Context
prefix after the normal plugin build, then the complete
`Angelscript.TestModule.AngelScriptSDK` prefix if the narrow run passes.

## Review-Fix Follow-up

An independent code-quality review identified two null-safety/result-consumption gaps
in the assertion-depth implementation. The following minimal corrections were applied:

- `SuspendAndResumePreserveContextState` now returns immediately after the
  `ScriptEngine` non-null assertion fails, before any `RegisterGlobalFunction` call.
- The signed ABI path returns immediately after a failed function lookup and now
  explicitly consumes both primary-context `SetArgDWord` results as `asSUCCESS`.
- The configured float ABI path now also returns immediately after a failed function
  lookup, before creating either primary or independent control context.
- `MultipleReturnPaths` now has matching early returns for the function, positive
  context, and fallback context lookups. Its positive and fallback `SetArgDWord`
  results are both explicitly asserted as `asSUCCESS`.
- Early returns are positioned before the newly created context's release guard;
  if the fallback context cannot be created, the already-active positive-context
  scope guard still releases it. Successful paths retain the existing explicit
  releases before module discard.

No additional scenarios, files, or product/catalog records were changed.

## Concerns

1. The absence of build/test execution is intentional and is the only remaining
   confidence limitation. Static inspection cannot prove the configured raw SDK line
   callback dispatch at runtime.
2. Existing dirty-worktree changes predated this handoff. This implementation did not
   revert or edit unrelated files, and no commit was created.
