## Context

The SDK sources already sit at `Source/AngelscriptRuntime/angelscript/` with `as_*.{h,cpp}` and `frontend/` as siblings. `AngelscriptRuntime.Build.cs` still adds `ThirdParty/angelscript` and `ThirdParty/angelscript/source`. Current specs still say headers may remain under that deleted tree.

Public C API is unchanged at `Core/angelscript.h`. Existing includes `"angelscript.h"` and `"frontend/…"` keep working if both `ModuleDirectory` / `Core` and the new SDK root stay on the include path.

See `attachments/drafts/design.md` for the approved layout sketch.

## Goals / Non-Goals

**Goals:**

- Compile the moved first-party SDK through UBT with one include root at `ModuleDirectory/angelscript`.
- Make current specs, knowledges, and live fork-strategy guidance name that root.
- List sibling Changes that still Files the old tree so they replan.

**Non-Goals:**

- Moving sources again, restoring ThirdParty, or adding a symlink alias.
- SDK behavior, public C API location, or Automation identities.
- `AngelscriptLSP/` CMake (sibling Change).
- Rewriting other Changes' `tasks.md`.
- Archives and ZH knowledge dumps.

## Decisions

### Treat the tree as first-party Runtime source

The reconstructed SDK is not a drop-in AngelCode package. Keeping a `ThirdParty/angelscript` include alias would hide the move and keep agents writing to a vendor-shaped path. Alternative considered: symlink the old path. Rejected because UBT and specs would keep teaching a deleted organization.

### Include root is the flattened folder, not a nested `source/`

On disk there is no `angelscript/source/`. UBT must add `ModuleDirectory/angelscript` so `"frontend/as_parser.h"` and sibling `as_*.h` resolve. `ModuleDirectory` and `ModuleDirectory/Core` stay. No new module or header name.

### Specs keep the namespace rule; only the example path changes

`BEGIN_AS_NAMESPACE` and the ban on a nested C++ `frontend` namespace stay. The Context/WHEN examples that currently say `ThirdParty/angelscript/source/frontend/` become `Source/AngelscriptRuntime/angelscript/frontend/`.

### Sibling Changes replan their own Files

This record does not rewrite `feature-frontend-diagnostics-tooling`, `refactor-sdk-drop-native-gc`, or `refactor-bindings-two-stage-pipeline`. Those Task DAGs still name the old tree; their owners replan after this layout exists.

## Risks / Trade-offs

- Until Build.cs is retargeted, the Editor target cannot compile the moved SDK. That is the current RED, not a new failure mode.
- A missing new include root must fail the build. There is no fallback to the deleted ThirdParty path.
- Historical archive paths stay historical. Grep of the whole repository will still find `ThirdParty/angelscript` in archives, ZH dumps, and sibling Change Files until those records replan.
