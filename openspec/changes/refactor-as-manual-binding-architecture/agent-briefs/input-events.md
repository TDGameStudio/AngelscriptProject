# Parallel wave: Bind_InputEvents

Migrate only the InputEvents manual provider to the direct callback architecture.

## Exclusive edit scope

- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputEvents.cpp`
- new `Bind_InputEvents_Functions.h`
- new `Bind_InputEvents_Functions.cpp`
- this task's report: `input-events-report.md`

Do not edit core APIs, tests, OpenSpec matrices/tasks, other bind families, or build files. Other agents are editing the shared checkout concurrently.

## Requirements

- Replace the legacy `FAngelscriptBinds::FBind`/`EOrder::Late` provider with file-static `FAngelscriptBind` callbacks taking explicit `FAngelscriptBinds&`.
- Use `ManualBindings` for the callable/property/global surface.
- Split FKey ToString registration into a `TypeInfrastructure` contribution named with semantic `ToStringContribution`, using `FToStringHelper::Register(Binds, ...)`.
- Route all class, namespace, global function, and global variable work through the explicit target context (`ExistingClassForTarget`, `FNamespace(Binds.GetTargetEngine(), ...)`, `BindGlobalFunctionForTarget`, `BindGlobalVariableForTarget`).
- Move every project-owned AS callable lambda/body into one `FAngelscriptInputEventsBinds` owner declared in the companion header and defined in the companion cpp. Preserve engine member/free pointer registrations directly.
- Preserve every AngelScript declaration string, method/global/property set, semantics, macro-expanded EKeys list, and native classification exactly. This provider currently has no native/trivial metadata terms to invent.
- Do not leave inline non-capturing lambdas passed to AS constructor/method/global registration. Auxiliary local lambdas not used as AS callables are allowed.
- Preserve short-chain one-line formatting; when a chain has traits, put the registration on one line and align subsequent `.Trait()` calls one tab deeper, matching `Bind_FVector.cpp`.
- Use semantic callback and callable names, no numeric sequencing.
- Run only static/file-local checks (`rg`, diff/self-review). Do not run UBT or UE automation; the root agent owns serialized build/test validation.

## Evidence already established

The root agent added and ran a red source-layout test. It currently fails because the direct provider/companion family does not exist.

## Report

Write `input-events-report.md` beside this brief with: status (`DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, or `BLOCKED`), files changed, callable count/coverage notes, preserved declarations/native parity, static checks run, and concerns. Return only the status and a compact summary to the root agent. Do not commit.
