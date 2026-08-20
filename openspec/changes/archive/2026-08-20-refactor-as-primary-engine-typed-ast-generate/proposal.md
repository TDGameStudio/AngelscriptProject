## Why

TypedASTJIT currently compiles a second, contained generation Engine for every Generate, even when the Editor primary Engine already has the same source. That duplicate Engine is waste for the matching Editor profile. Keep the generation Engine for other profiles (Editor or commandlet) so Dev/Shipping `.jit.cpp` trees can still be produced. HIR capture stays optional: matching `"typed-ast"` Generate reads primary HIR when capture is on, and never spawns an extra Engine just to obtain that matching HIR.

## What Changes

- Primary Editor/Runtime Engine MAY optionally capture function-owned typed semantic HIR. Capture stays frozen at Engine create. `"bytecode"` sessions stay capture-off. `"typed-ast"` matching Generate requires that primary HIR; it does not spawn a generation Engine to obtain it. Hot Reload updates captured HIR with the recompiled functions.
- Matching-profile Editor Generate/Refresh reads the primary Engine (bytecode graph, or verified HIR when capture is on). It MUST NOT create a generation Engine for that matching request.
- **BREAKING** (spec overturn): Cache V2 MAY persist an optional pointer-free TypedHIR sidecar. ExactStartup remaps it onto restored functions. Bytecode FunctionBody, `SaveByteCode`, public `angelscript.h`, and `.hir.txt`/`.hir.json` dump files remain non-inputs.
- Native-form / reviewed native-call collection moves toward a process-lifetime catalog keyed by stable declaration identity **and bind-surface**. Recipes include Header/Include when bind recorded them. Primary matching Generate does not depend on keeping `bCollectStaticJITCompatibilityBinds` true. Bind lambdas still replay per Engine.
- The contained generation Engine is **kept** for non-matching profiles and for commandlet/CI Generate. Editor and `UAngelscriptJITCommandlet` MAY emit multiple `.jit.cpp` trees (`EditorDevelopment`, `GameDevelopment`, `GameShipping`) in one action: matching profile from the primary Engine, other profiles from sequential generation Engines (at most one extra Engine alive). Commandlet remains the pack-time entry (`Tools\RunAngelscriptJIT.ps1`). HIR capture on a generation Engine is required only for that Engine's `"typed-ast"` request; `"bytecode"` Generate does not capture.
- Switching Static backend or primary target profile still requires an Editor restart.

## Capabilities

### New Capabilities

- `as-primary-engine-typed-ast-generate`: matching-profile Generate from the primary Engine (no generation Engine); optional primary HIR capture; non-matching profiles via sequential generation Engines in Editor or commandlet; pack-time commandlet remains authoritative for GameDevelopment/GameShipping.

### Modified Capabilities

- `as-typed-semantic-ir`: HIR MAY persist as an optional Cache V2 sidecar; still forbidden in `SaveByteCode`, public ABI, and dump-file reload.
- `as-typed-ast-jit-backend`: matching-profile Editor Generate consumes primary compiled state; a generation Engine is allowed only for non-matching profiles or isolated/commandlet Generate.
- `as-static-jit-backend`: matching-profile Editor Generate must not construct a generation Engine; generation Engines remain the contained compile host for other profiles.
- `as-incremental-script-cache`: optional TypedHIR sidecar record, absence coordinate, and ExactStartup remap.
- `as-static-jit-native-call-linkage`: process-global native-form / native-call catalog; a native-form display name still does not prove DLL linkability.

## Impact

- Runtime Cache V2 record kinds, ExactStartup restore, and Editor StaticJIT orchestration (`AngelscriptProjectSourceGraph`, `AngelscriptJITGeneration`, JIT commandlet).
- Fork HIR persist codec (stable keys, no engine-local function IDs on disk).
- Bind-time `bCollectStaticJITCompatibilityBinds` / `StaticJITBinds.cpp` native-form attachment.
- Tests under `Angelscript.TestModule.Cache`, `Angelscript.TestModule.StaticJIT`, and compiler HIR helpers.
- Overturns `feature-as-typed-semantic-aot` “HIR never in Cache V2” and “matching-profile TypedASTJIT always uses a temporary Engine”.
- Does not introduce a production `"dual"` backend, Runtime JIT, or two live target-profile Engines at once. Sequential extra Engines for non-matching profiles remain allowed.
