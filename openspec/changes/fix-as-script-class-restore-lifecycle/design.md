## Context

Fresh compilation calculates script-class layout and synthesizes special-member
behavior across several builder/compiler stages. Restore reconstructs type and
property records in phases; simply replaying property insertion is insufficient
for inheritance, embedded script value types, alignment, and inherited offsets.
Separately, a user destructor exception can bypass the generated suffix that
normally destroys members and the base class.

## Goals / Non-Goals

**Goals:**

- Make restored base/derived layouts equivalent to fresh compilation.
- Preserve construction, copy/assignment, destruction, metadata, and runtime
  reads after save/load.
- Guarantee balanced cleanup after partial construction and destructor
  exceptions.
- Remove raw script-object registry entries before their type/engine becomes
  invalid.

**Non-Goals:**

- Change user-visible exception propagation beyond the fork's existing
  destructor policy.
- Introduce add-on types or UE object semantics into raw SDK tests.
- Redesign the class generator.

## Decisions

1. Rebuild layouts after type/property phases are available, recursively
   base-before-derived, with cycle and invalid-property rejection.
2. Reuse authoritative restored base-property identity for inherited offset
   classification instead of trusting serialization order alone.
3. On an exceptional user destructor body, destroy only still-owned members
   introduced by that class and then its base; do not rerun already completed
   suffix work.
4. Scope raw object registry entries by engine and unregister on object free and
   before engine type teardown.
5. Compare restored and fresh classes through metadata, runtime reads, lifecycle
   events, cleanup, and post-teardown allocation controls.
6. Treat the raw registry as the ownership authority for a public SDK or VM
   object only when the pointer is registered and the supplied static TypeInfo
   is the registered dynamic type, one of its bases, or an interface it
   implements. Unrelated TypeInfo inputs remain rejected. AddRef increments
   the dynamic-type entry. A final public or VM release marks
   generated destruction in progress without first dropping the last count.
   A reentrant retain from the destructor can therefore preserve the object;
   the initiating release decrements only after destruction returns. A later
   final release frees without running the already completed destructor again;
   final destruction always uses the registered dynamic type.
   Registered native types, UE-backed script classes, mismatched TypeInfo
   inputs, and ordinary behaviour-backed references retain their existing
   paths.

## Risks / Trade-offs

- **[Double destruction]** Cleanup may overlap generated destructor suffix. →
  Invoke fallback only when execution terminates exceptionally before the
  suffix and assert exact event order.
- **[Incorrect inherited offset]** Recomputing in the wrong phase can corrupt
  instances. → Rebuild base-first after all required type records exist and
  validate inherited properties.
- **[Registry lifetime race]** Global lookup state may outlive an engine. →
  unregister by engine before type teardown and by object before free.
- **[Public API double free or wrong-type destruction]** A generic public
  release could be called with an unrelated pointer or TypeInfo, while VM
  ownership legitimately supplies a base or interface TypeInfo for a derived
  object. → resolve the registered dynamic type, accept only exact,
  `DerivesFrom`, or `Implements` compatibility, and perform the transition and
  final destructor against that dynamic type; otherwise preserve the existing
  behaviour dispatch.
- **[Destructor re-entry]** A destructor can retain its own object through a
  native callback. → preserve the last ownership count during generated
  destruction, record that the destructor has run, finish the initiating
  release afterward, and never run the destructor twice.
- **[Outstanding object at engine shutdown]** Registry removal prevents stale
  TypeInfo lookup but does not free an allocation still held by the
  application. → keep this as an explicit fork defect until public-created and
  VM-owned raw allocations carry sufficient provenance for safe teardown.
- **[Layout compatibility]** Existing streams may encode incomplete inherited
  classification. → derive from the restored base contract and reject
  inconsistent streams.

## Migration Plan

1. Assign all special-member/layout/cleanup/registry hunks to this change.
2. Add fresh-versus-restored and exceptional cleanup regressions.
3. Apply the coherent runtime repair.
4. Build once, then run focused Module, Constructor, Destructor, Runtime, and
   full SDK prefixes.
5. Roll back the complete class-restore/lifecycle hunk set if equivalence or
   teardown baselines regress.

## Open Questions

- Confirm which raw object registry hooks are pre-existing unrelated work and
  which are required only by this root cause.
