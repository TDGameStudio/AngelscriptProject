## Why

`UnrealEvent` needs to restart from the GMP runtime source instead of extending the old lightweight `UFUNCTION`-only prototype under `D:\Workspace\UnrealEvent`. The first step is to establish a clean standalone plugin repository and host-project submodule boundary before any GMP pruning or runtime redesign begins.

## What Changes

- Create a fresh standalone `UnrealEventPlugin` repository initialized from a GMP source snapshot, without preserving GMP git history.
- Record `git@github.com:TDGameStudio/UnrealEventPlugin.git` as the new plugin remote.
- Add the standalone repository back to `AngelscriptProject` as the `Plugins/UnrealEvent` submodule.
- Preserve GMP Apache 2.0 license obligations and attribution in the standalone repository.
- Defer GMP feature pruning, runtime API redesign, Blueprint/editor/script integration, and AngelScript bindings to later OpenSpec changes.

## Capabilities

### New Capabilities

- `unrealevent-standalone-repository`: Captures the standalone repository, GMP snapshot attribution, and host submodule integration behavior for the new UnrealEvent plugin.

### Modified Capabilities

- None.

## Impact

- New standalone repository: `TDGameStudio/UnrealEventPlugin`.
- Host submodule metadata: `.gitmodules` and `Plugins/UnrealEvent`.
- Host project plugin enablement: `AngelscriptProject.uproject`.
- Documentation and setup notes: root project guidance for the new plugin submodule.
- External source reference: `D:\Workspace\UnrealEvent\Plugins\GenericMessagePlugin`, upstream `git@github.com:wangjieest/GenericMessagePlugin.git`, observed commit `421f572`.
