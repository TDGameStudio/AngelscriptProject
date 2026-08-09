# Parallel wave: Bind_Json

Migrate only the JSON manual bind family to the direct callback architecture.

## Exclusive edit scope

- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Json.cpp`
- new `Bind_Json_Functions.h`
- new `Bind_Json_Functions.cpp`
- this task's report: `json-report.md`

Do not edit core APIs, tests, OpenSpec matrices/tasks, other bind families, or build files. Other agents are editing the shared checkout concurrently.

## Requirements

- Replace the legacy Late provider with file-static direct callbacks taking explicit `FAngelscriptBinds&`.
- Split `EJsonType` and the four AS value-class declarations into `TypeDeclarations`; register constructors/destructors/properties/methods/Json namespace functions in `ManualBindings`.
- Route class, enum, namespace and global operations through explicit target APIs.
- Move every project-owned AS callable lambda/body and the existing `ValueTypeToString` entry into one `FAngelscriptJsonBinds` owner declared in the companion header and defined in the companion cpp. Preserve member-pointer registrations directly.
- The implementation-only JSON container/iterator types may be relocated as needed within the exclusive files, but keep them private to this bind family and do not change their layout or behavior.
- Preserve every AngelScript declaration string, enum value, method/property/global surface, iterator-debug behavior, error behavior, JSON parse/serialize behavior, and native classification exactly. No native/trivial terms currently exist; do not invent them.
- Do not leave inline non-capturing lambdas passed to AS registration APIs.
- Chain formatting must match `Bind_FVector.cpp`; also normalize only the lines you move/touch, without unrelated style churn.
- Run only static/file-local checks (`rg`, diff/self-review). Do not run UBT or UE automation; the root agent owns serialized validation.

## Evidence already established

The root agent added and ran a red source-layout test. It currently fails because the direct provider/companion family does not exist.

## Report

Write `json-report.md` beside this brief with: status, files changed, declaration/manual split, callable ownership coverage, static checks run, and concerns. Return only the status and a compact summary to the root agent. Do not commit.
