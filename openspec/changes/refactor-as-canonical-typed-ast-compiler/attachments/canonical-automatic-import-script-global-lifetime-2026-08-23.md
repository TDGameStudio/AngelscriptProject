# Canonical automatic-import script-global lifetime — 2026-08-23

## Decision

Canonical automatic imports may project a script global from an already
published provider module only when all of the following are true:

- the reference is explicitly namespace-qualified;
- automatic imports are enabled;
- exactly one external provider property has the same namespace, name, and
  resolved canonical type; and
- the provider is not the consumer module.

The projected declaration is marked
`canonical-automatic-import-script-global`. CodeGen resolves that marker back
to the existing property and puts it only into the emitter lookup table. It is
not an artifact-owned global and never creates a second consumer allocation.
Ambiguity and any type mismatch remain fail-closed.

## Lifetime boundary

The VM bytecode embeds the property address in global-address/load opcodes.
An address-map lookup during release is unsafe: a provider can be discarded and
its module reclaimed before the consumer function is reclaimed. The consumer
would then have no reliable way to determine that the old address referred to a
script property rather than string storage.

`asCScriptFunction::AddReferences()` now acquires an `asCGlobalProperty`
reference at each such bytecode offset and retains `{ offset, property }` in
the function. `ReleaseReferences()` releases the captured property at that
same instruction rather than consulting the mutable address map. Thus engine
GC retains the provider property and its `varAddressMap` entry while a consumer
function exists, and normal cleanup removes both once the last consumer is
discarded.

```
provider global G ──address──> consumer LDG/PGA bytecode
       │                                  │
       │                         exact property AddRef
       │                                  │
provider Discard + GC ── keeps property/map alive ── consumer executes G
                                          │
consumer Discard ── Release captured property ── engine GC reclaims G/map
```

## Executable evidence

`CanonicalAutomaticImportsPublishGlobalsAndResolveFunctions` now performs the
complete lifecycle:

1. Compile provider `AutoProvider::SharedGlobal` and consumer
   `AutoProvider::SharedGlobal + 2` through CANONICAL automatic import.
2. Execute the consumer (result `42`).
3. Discard the provider and force engine GC; its global address still resolves
   in `varAddressMap` and the consumer still executes to `42`.
4. Discard the consumer and force GC; the old address no longer resolves.

Verification on 2026-08-23:

- Runtime/Editor build: success —
  `Saved/Build/cta-auto-import-global-lifetime-green/20260823_143725_653_1a3dd4b4/RunMetadata.json`.
- Canonical ProductionCodeGen: **64/64 PASS** —
  `Saved/Tests/cta-auto-import-global-lifetime-green/20260823_144058_164_a5c25571/Summary.json`.
- Cache ASTBodySidecar + ExactWarmStartup: **16/16 PASS** —
  `Saved/Tests/cta-auto-import-global-cache-regression/20260823_144330_885_782991ea/Summary.json`.
- Broad native SDK: **1208/1218**, with the ten unrelated current
  Canonical-coverage/compatibility failures recorded in
  `Saved/Tests/cta-auto-import-global-native-sdk/20260823_144500_971_10562b79/Summary.json`.

## Deliberate limits

This is a narrow direct-read lifecycle route, not a completed cross-module
global/import design. It does not establish Cache V2 DTO provenance for the
provider link, a rebind protocol across provider generations, all write and
compound-assignment forms, non-trivial initialization, or broad semantic
imports. Those constraints remain part of the open 13.6 / Cache V2 work.
