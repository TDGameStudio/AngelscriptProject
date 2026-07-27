# Verification

## Property inventory

The anonymous `ep` structure in
`ThirdParty/angelscript/source/as_scriptengine.h` contains 46 fields. A
field-by-field constructor reconciliation against
`asCScriptEngine::asCScriptEngine()` finds 46 explicit assignments and zero
omissions. No additional runtime repair is required beyond the already applied
`ep.typeCheckSwitchEnums = false`.

The two raw profiles intentionally differ:

- a bare SDK engine starts with `asEP_TYPECHECK_SWITCH_ENUMS == 0`;
- the fork-configured native test engine applies the plugin policy and sets it
  to `1`.

This preserves the vendored SDK default while retaining the plugin's configured
behavior. The profile test captures and restores each profile independently;
it does not assume that bare and configured defaults are equal.

## Runtime evidence

| Gate | Artifact | Result |
| --- | --- | --- |
| Initial regression | `Saved/Tests/native-sdk-depth-batch-typecheck-default/20260725_155124_893_1d28548d/Report/index.json` | Reproduced the nondeterministic uninitialized bare baseline before the constructor repair. |
| Repair build | `Saved/Build/native-sdk-depth-batch-typecheck-default-fix/20260725_155233_225_a2b3fca5/RunMetadata.json` | PASS; process/final exit 0. |
| Focused property profile | `Saved/Tests/native-sdk-engine-property-profile-typecheck-default-fix/20260725_155244_953_a642c5ff/Report/index.json` | **1/1 PASS** across 64 profile/property/applied-value cells. |
| Independent-engine isolation | `Saved/Tests/as-native-sdk-engine-property-isolation/20260724_233835_863_35937f4f/Report/index.json` | **1/1 PASS** across fourteen mutable properties, two values, and three independent engines. |
| Current complete SDK | `Saved/Tests/as-native-sdk-after-compiler-ownership-depth/20260727_080307_760_31790f05/Report/index.json`; sibling metadata/log | **666/666 PASS**, zero failed/not-run/in-process/warning results, process/wrapper exit 0, `TimedOut=false`, normal status-zero shutdown, and no crash/fatal/assert/unhandled/access-violation marker. |

The focused profile owns baseline, both applied values, restore, compilation,
execution, module cleanup, and independent-control isolation. The aggregate
run confirms the explicit default remains compatible with every active native
SDK owner.
