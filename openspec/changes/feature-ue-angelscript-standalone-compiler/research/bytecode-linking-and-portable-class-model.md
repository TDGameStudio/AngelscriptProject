# Bytecode Linking and Portable Class Model

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


## Function Identity Versus Native Address

The maintained fork stores live system-call bytecode operands as references to registered `asCScriptFunction` descriptors. The descriptor owns an `asSSystemFunctionInterface`; that interface contains the current process's callable address and calling metadata.

`SaveByteCode` does not persist that pointer or native address. It converts callable references to indices in the used-function table and serializes enough owner, namespace, name, return, parameter, direction, qualifier, and behavior information to identify the function. `LoadByteCode` reads those signatures, resolves them against the target engine's current registrations, and patches the in-memory bytecode to current descriptors.

Consequences:

- UE startup registration, not the offline bundle, establishes real callable addresses.
- ASLR, rebuilds, restarts, and hot reload do not require stable addresses in the contract.
- Standalone registers the same declarations against compile-only generic traps and produces bytecode linked to those standalone descriptors.
- UE-validation bytecode cannot be advertised as UE-loadable merely because function signatures are relocatable; exact type/layout, engine-property, adapter, registration, and fork compatibility would need a separate contract.

The canonical offline contract therefore carries stable semantic symbol IDs and full declarations, never addresses.

## Portable Class Projection

Current preprocessing already produces `FAngelscriptClassDesc`, `FAngelscriptFunctionDesc`, and `FAngelscriptPropertyDesc`, but the class descriptor mixes compile-time facts with UE-owned pointers such as `UClass*`, `UStruct*`, and `asITypeInfo*`.

The standalone boundary uses the standard-C++ declaration IR owned by `AngelscriptLanguageCore` for compile-time facts only. The shared frontend populates it, both hosts validate it, standalone lowers it into the maintained AngelScript compiler, and the UE adapter converts it into the existing UE descriptors consumed by ClassGenerator.

Standalone produces:

- a real AngelScript script type;
- function bytecode;
- a deterministic class-model record;
- resolved symbol IDs;
- exact/compile-shim/ue-required/unsupported classifications.

Standalone does not produce:

- `UASClass`, `UASStruct`, or `UASFunction`;
- `FProperty` instances or UE offsets;
- a CDO or applied default state;
- component templates;
- Blueprint VM/RPC/GC/World state;
- hot-reload or reinstancing behavior.

`asPreClassData` may configure compiler lowering, but its property offset, shadow type, and user data are engine-local details, not the portable class contract.

## Script Baseline Replacement

Observing the final registered engine includes already compiled project scripts. Replaying all of those declarations before recompiling current sources would create duplicate types, while dropping all script declarations would make changed-module validation unable to resolve unchanged dependencies.

The bundle therefore labels symbols as `host-surface` or `script-baseline`. The standalone host computes the source/module closure, suppresses baseline records for modules being recompiled, and retains only closure-external baseline declarations. Stable module identity, rather than filename order or runtime module ID, controls replacement.
