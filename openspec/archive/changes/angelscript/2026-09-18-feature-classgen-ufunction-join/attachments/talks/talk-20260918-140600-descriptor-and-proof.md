# Method descriptors and first proof

## Context

ClassGen Analyze iterates host `ClassDesc.Methods` and looks up `ScriptFunctionName` on TypeInfo. Builder CompileOutput Methods are not copied back.

## Evidence

AskQuestion Q2 = P, Q3 = E. Draft log R3. `ExecuteConstructFunction` no-ops when `ConstructFunction == nullptr`.

## Options

- Q2 P: hand-fill Methods in the NativeEngine test; preprocessor stays the production authority.
- Q2 R: run the real preprocessor in the test.
- Q2 B: copy Builder DescriptorConsumer Methods onto the host ClassDesc.
- Q3 E: Initial ProcessEvent only.
- Q3 C: also script construct.
- Q3 F: also FullReload of the method body.

## Settled Decision

Q2=P and Q3=E. Hand-fill Methods. Prove Initial ProcessEvent. Do not run the preprocessor, copy Builder Methods, join construct, or reload the body.

## Consequences

The fixture matches `ClassGenMaterialization`. Production preprocessor behavior is unchanged.

## Flip Condition

Reopen Q2 if hand-filled names cannot match TypeInfo and the test cannot change those names. Reopen Q3 if construct or reload must be proven before a UFUNCTION call counts.

## Sources

[handoff](../drafts/handoff.md), [ufunction-join](../drafts/findings/ufunction-join.md). Provenance: draft log R3.
