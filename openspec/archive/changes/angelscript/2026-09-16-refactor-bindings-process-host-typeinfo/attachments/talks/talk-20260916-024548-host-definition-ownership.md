# Process host ownership with private script and live definitions

## Context

The old plan shares BindInfo recipes and IDs while materializing different TypeInfo pointers per Engine. The accepted direction shares stable C++ type/function objects themselves.

## Evidence

[Current source](../drafts/findings/change-readiness-20260916.md) identifies unique-transfer registration and Prepare's exact-owner check. [Execution contracts](../drafts/findings/three-engine-contracts.md) explain required ID, lifetime and admission changes.

## Options

Continue descriptor/per-Engine materialization; clone host graphs; or retain one process graph and separate receiving-engine admission. The user selected the last option and rejected a new Host/Script base hierarchy or separate library class.

## Settled Decision

Collection owns HostProcess definitions, InjectDefinitions admits shared pointers, and RegisterExternalDefinitions transfers only private script definitions. LiveRegister is restored as an explicit per-Engine path. Use one asCDefinitions type and the approved vocabulary.

## Consequences and Flip Condition

Shared object identity reduces duplicate metadata but makes Engine lookup through a definition invalid. Mutable native/adapter/auxiliary state stays local and active calls retain graph leases. If evidence invalidates safe admission or lifetime, replan explicitly; do not silently clone the graph.

## Visual

Collection -> HostProcess graph -> A and B directories; Context A/B -> local execution state. Script/live private graphs -> exactly one Engine.

## Sources

Local-source provenance: topic bindings-gap-audit, Q20-Q39, Q48-Q50, Q60/Q61; final acceptance Q65-Q68. The [accepted design](../drafts/design.md) is the exported decision, not the local transcript.
