# InputEvents migration report

- Status: `DONE`
- Files changed:
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputEvents.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputEvents_Functions.h` (new)
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputEvents_Functions.cpp` (new)
  - `openspec/changes/refactor-as-manual-binding-architecture/agent-briefs/input-events-report.md` (new)

## Callable coverage

- Replaced the legacy `FAngelscriptBinds::FBind` / `EOrder::Late` provider with file-static direct callbacks.
- Registered the callable/property/global surface in `ManualBindings`, and split FKey string conversion into `InputEvents.FKeyToStringContribution` at `TypeInfrastructure`.
- Moved all 25 project-owned AS callable lambda bodies into `FAngelscriptInputEventsBinds`: FKey/FName/FInputChord helpers, pointer-event conversions, FEventReply helpers, reply globals, and character conversion.
- Retained 101 direct engine member/free-function pointer registrations. The macro-expanded EKeys list remains unchanged.

## Preserved surface and metadata parity

- Static declaration comparison against the pre-migration provider: `128` declarations before and after; exact parity.
- Macro-expanded EKeys comparison: `187` entries before and after; exact parity.
- Native/trivial metadata terms: `0` before and after. No classification metadata was added.

## Static checks run

- `rg` audit confirmed no remaining legacy provider/static registration APIs or inline callable lambdas in `Bind_InputEvents.cpp`.
- `rg` audit confirmed target-context registrations use `ExistingClassForTarget`, `FNamespace(Binds.GetTargetEngine(), ...)`, `BindGlobalFunctionForTarget`, `BindGlobalVariableForTarget`, and `FToStringHelper::Register(Binds, ...)`.
- Owner completeness comparison: `25` prior callable lambdas, `25` companion declarations, and `25` companion definitions.
- `git diff --check` for the three scoped source files passed without whitespace diagnostics.

## Concerns

- No UBT or UE Automation execution was performed, as required by the brief; serialized build/test validation remains with the root agent.

## Critical follow-up fix evidence

- The root-owned unified UBT run exposed C2888/C2440 cascades after `Bind_InputEvents.cpp` because the migrated file closed only the EKeys scope and `BindInputEvents`, leaving its outer unnamed namespace open across the rest of the unity translation unit.
- Added the single missing namespace-closing `}` before the two file-scope `FAngelscriptBind` registrations.
- Fresh static brace audit now shows three terminal closes in order: EKeys scope, `BindInputEvents`, unnamed namespace. The two provider registrations follow at file scope.
- Fresh scoped `git diff --check` and forbidden legacy/lambda `rg` checks pass after the fix.
- Per the brief, this agent did not rerun UBT or UE Automation; the root agent owns the confirming unified build.
