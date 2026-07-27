# Runtime ScriptObject assertion-depth implementation

## Scope

Only the requested native SDK Runtime ScriptObject test source was changed:

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Runtime/AngelscriptNativeScriptObjectLifecycleDepthTests.cpp`

No catalog, Support fixture, or other source file was modified. The source file is
currently untracked in the `Plugins/Angelscript` submodule, so ordinary `git diff`
does not render its content; inspect it directly or use `git status --short`.

## Implemented observability

`OwnershipProbe` can now be generated with a script destructor that calls
`RecordOwnershipProbeDestruction()`. Each affected product registers that native
callback **before** compiling its generated source. The callback resolves a
case-owned recorder from the active script context's engine userdata slot. The
recorder is reset between product scenarios and asserts exact counts:

| Product | New oracle | Exact destruction baseline |
| --- | --- | --- |
| `RT-OBJ-CONSTRUCT-COPY-ASSIGN-PROPERTY` | Script destructor callback plus explicit release of constructed, copied, and assigned/uninitialized objects; copy and assigned values are independently mutated. | `0` before creation; `3` after the three explicit releases. |
| `RT-OBJ-REFCOUNT-WEAKFLAG-FORK` | Separate reference probe with the current-fork null weak-flag assertion, callback baseline across balanced `AddRef`/`Release`, then final release. | `0` after the balanced pair; `1` after final release. |
| `RT-OBJ-TYPE-ENGINE-IDENTITY` | Same callback around constructed/copy/uninitialized origin coverage; each balanced pair must retain the `0` baseline before all objects are released. | `0` before and after each balanced pair; `3` after all three explicit releases. |

The construct/copy/assign product writes `Copy.Value = 31` and then
`Assigned.Value = 41`, asserting the original and the other owner remain
unchanged. `CopyFrom(Original)` subsequently proves the assigned object updates
without erasing the independently mutated copy.

Both affected methods use explicit normal-path object release, set released
pointer variables to `nullptr`, explicitly discard the module only after all
objects are released, and assert
`GetModule(name, asGM_ONLY_IF_EXISTS) == nullptr`. The remaining scope exits are
early-return fallback cleanup only; their pointer conditions are false after each
explicit release, so they do not issue a second release. No `GetModuleCount()`
assertion was added.

## Static review performed

- Re-read the three rows in `assertion-depth-runtime-module-review.csv` and the
  current catalog declarations.
- Confirmed stable product IDs, generated-source print calls, fork-limit logs,
  matcher assertions, and nullable lookup early returns remain present.
- Inspected the fork's `CreateUninitializedScriptObject`,
  `CreateScriptObjectCopy`, `ReleaseScriptObject`, and script-object destructor
  paths. The uninitialized path pre-initializes memory, and destruction is driven
  through the script object's final release/destructor route.
- Checked the target for explicit callback registration preceding `BuildSource(true)`,
  required `asGM_ONLY_IF_EXISTS` null checks, explicit `DiscardModule`, and the
  absence of `GetModuleCount()`.

## Status: DONE_WITH_CONCERNS

Per request, no build and no UE automation test were run. The exact `3/1/3`
destruction expectations are based on the inspected raw API paths and must be
confirmed by the narrow Runtime ScriptObject automation prefix when test execution
is authorized. A second concern is the pre-existing untracked status of the target
test source in the Angelscript submodule; it prevents a normal `git diff` from
showing the file, but it is intentionally left unaltered as repository state.

## Review-fix: destruction-observation userdata cleanup

The approved review identified one Minor cleanup-observability gap: the two
affected methods previously ignored the return value from the normal-path
`SetUserData(nullptr, OwnershipProbeDestructionObservationSlot)` call.

Both methods now keep `bDestructionObservationSlotCleared` false while their
scope exit remains responsible only for early-return fallback. After the final
destruction baseline, explicit module discard, and
`asGM_ONLY_IF_EXISTS` null assertion, the normal path explicitly clears the
slot and asserts that the returned prior value is exactly
`&DestructionObservation`. It then marks the guard cleared and verifies a
direct `GetUserData(slot)` lookup is null. This occurs after every callback
observation, so it cannot hide or perturb the expected `3/1/3` destruction
counts.

## Runtime diagnosis and public ownership repair

The first executed Runtime parent disproved the original source-only concern:
both affected owners observed a destruction count of zero. The test callback and
module order were valid. The fork registers script classes as
`asOBJ_SCRIPT_OBJECT | asOBJ_REF | asOBJ_NOCOUNT`, comments out the canonical
script-object addref/release behaviours, and uses a separate raw-object registry
for standalone SDK allocations. Interpreter/StaticJIT cleanup already consumed
that registry, but public `AddRefScriptObject()` and
`ReleaseScriptObject()` still dispatched only behaviours and therefore became
no-ops.

The production bridge is owned by linked change
`fix-as-script-class-restore-lifecycle`. It enters the raw path only when the
pointer is registered with the exact supplied TypeInfo. Public AddRef increments
the raw owner count. Final public Release keeps the registration alive through
`CallDestructor()`, then calls `CallFree()`; UE-backed and ordinary
behaviour-backed references retain their previous path.

Accepted red/green evidence:

- red Runtime parent:
  `Saved/Tests/as-native-sdk-runtime-assertion-depth/20260727_132238_926_13c98332/`,
  42/44 with only the two zero-destruction failures and no crash/timeout;
- repair UBT:
  `Saved/Build/as-native-sdk-runtime-scriptobject-public-release-fix/20260727_133011_892_d9f7f840/UBT.log`,
  `Result: Succeeded`;
- focused ScriptObject:
  `Saved/Tests/as-native-sdk-runtime-scriptobject-public-release-fix/20260727_133041_790_0ce9194c/`,
  3/3 PASS;
- Runtime parent:
  `Saved/Tests/as-native-sdk-runtime-assertion-depth-final/20260727_133118_732_878ed5f4/`,
  44/44 PASS with normal status-zero shutdown and no crash marker.

Independent diagnosis recommended stronger per-origin localization. The source
now requires the assigned/uninitialized final release to move the count to one,
the copied release to two, and the constructed release to three, and requires
module discard not to increment the already completed count. These additional
assertions await the next coherent build and Runtime parent execution; they do
not weaken or replace the already green aggregate 3/1/3 contract.
