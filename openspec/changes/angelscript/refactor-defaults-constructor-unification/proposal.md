## Why

Class-body `default` statements add visible noise and a second initialization model to a language being reconstructed toward C++-style use. Authors must choose between member initializers, constructors and a separate default-configuration phase even when the operation is simply assigning an inherited property or configuring an existing component. The user explicitly prefers removing this syntax and unifying construction instead of introducing a `default { ... }` block or a renamed automatic defaults hook.

The accepted rationale is architectural, not merely cosmetic:

1. **Reduce authoring and learning cost.** Simple values belong in member initializers; inherited-property overrides and component configuration belong in constructors. Authors should not need an additional lifecycle concept to express these operations.
2. **Follow UE C++ construction more closely.** UE can construct a CDO through the registered class constructor without a script-language `default` construct. The existence of CDOs does not require a separate defaults function.
3. **Separate default data from executable initialization.** Restoring supported object properties from a CDO/template is a host operation. It need not rerun source statements or depend on a special syntax. Replaying configuration code and restoring data can serve related user needs, but are not identical: replay touches whatever the code touches, whereas restoration replaces the selected state.
4. **Remove maintenance of an unnecessary special function.** The replacement compiler currently carries ClassDefault through parsing, AST, access analysis, function identity, projection and serialization. The preferred endpoint removes that executable category rather than hiding the same phase behind syntactic sugar.
5. **Use the reconstruction window.** The preserved legacy runtime is dormant and the replacement compiler/VM is evolving. Define the intended construction contract now, while explicitly coordinating shared owners, instead of extending legacy defaults semantics into every new layer.

This decision does not claim that defaults and constructors have identical current semantics, that arbitrary live UObjects can be reset by copying every property, or that CDO copying automatically solves hot reload. The implementation must migrate the behavior currently carried by the separate phase.

## What Changes

### Intended language behavior

- Remove class-body `default Statement;` and `default { ... }`, with a targeted diagnostic directing authors to member initializers or constructors. Do not silently lower the removed syntax into a hidden post-constructor callback.
- Use member initializers for declared fields and constructors for inherited-property overrides and component configuration. Preserve base-to-derived construction and explicit member initialization rules; do not redeclare an inherited field to change its default.
- Remove the ClassDefault AST statement, implicit function generation and executable identity once replacement consumers are migrated. Update visitors, verification, lifetime analysis, definitions, codec/projection and tests as one consistent representation change.
- Preserve `switch` labels, default arguments and unrelated UE property specifiers such as `EditDefaultsOnly` and `VisibleDefaultsOnly`. The lexical keyword cannot simply be removed globally.
- Migrate defaults-specific access checks to an explicit construction-context contract for reflected classes. Preserve ordinary access protection and construction-unsafe call restrictions. Audit `editdefaults` permissions and the `defaults` function suffix separately: these currently express permissions, not automatic callbacks. Their final spelling/compatibility contract belongs in design before implementation; no blanket permission widening is implied.

### Before and after

Existing class-body shape, with reflection declarations omitted:

```cpp
class Pickup : AActor
{
    int Value = 10;
    default SetReplicates(true);
}
class HealthPickup : Pickup
{
    default Value = 25;
}
```

Intended constructor-based shape:

```cpp
class Pickup : AActor
{
    int Value = 10;
    Pickup() { SetReplicates(true); }
}
class HealthPickup : Pickup
{
    HealthPickup() { Value = 25; }
}
```

These examples explain the initialization change; they do not select a new reflection declaration spelling or prove current replacement UE execution.

### UE construction and defaults

- Continue letting UE own UClass/CDO allocation and normal object lifecycle. Bind the replacement script constructor to the appropriate host construction path; do not repurpose `SetDefaultObject` as a generic reset API.
- Make default components available before the script constructor body that configures them. Define the complete relationship between native construction, script member initialization, the script constructor chain and UE template/property initialization.
- Preserve Blueprint and serialized instance overrides. Source constructors establish initial configuration; an incorrectly placed late constructor call must not overwrite authored Blueprint/instance values.
- Remove reliance on `DefaultsFunction`, generated `__InitDefaults`, separate replay and `DefaultsCode` as the source of replacement runtime semantics. Preserved dormant sources remain references unless an explicitly owned migration requires changes; this change does not reactivate them.
- Specify bounded host restoration from the current class CDO or applicable archetype. Distinguish explicit reset (which intentionally discards selected overrides) from reload migration (which preserves overrides). Reuse suitable UE mechanisms; public API names are selected in design, not invented as existing interfaces here.
- Account for instanced subobjects, script fields outside FProperty and component state synchronization. A universal reset of timers, external registrations, physics and all native state is excluded. Completion of such a universal API is not a prerequisite for removing language syntax.

### Hot reload and compatibility

- Changes to constructors and member initializers must be considered when producing new defaults. Constructor-called helpers and native configuration dependencies can also change outcomes; a constructor-source-only comparison is insufficient.
- Prefer a conservative, explicit class/default-state rebuild when dependency information is insufficient. Derive new defaults through legitimate construction, then migrate supported data or reinstance as required. Do not invoke a C++ constructor over a live object as a reset operation.
- Retain Blueprint/instance override semantics during migration. Equality to an old default is not perfect evidence of whether an author explicitly set a value.
- Source migration must account for the old ordering: defaults ran after the script construction chain, with base defaults before derived defaults. Moving text into each constructor is not universally order-preserving. Automatically suggest only unambiguous edits; diagnose cases requiring manual migration.
- Evolve AST/metadata/cache formats deliberately. Removing an enum entry must not silently renumber surviving serialized kinds or reinterpret old data. Select reserved retired values or an explicit incompatible format revision and validate stale input rejection.

## Capabilities

### New Capabilities

- `angelscript/language/construction`: Constructor-based class initialization, removal diagnostics, inheritance/permission contracts and source migration.
- `angelscript/runtime/ue-defaults`: Replacement UE construction/default-state ownership, bounded restoration and preservation of template/Blueprint/instance semantics.

### Modified Capabilities

- `angelscript/language/frontend/preprocessing`: Update the durable example of class-body defaults passing through preprocessing when that language form is removed; preprocessing must not become a compatibility text-rewrite layer.
- Existing `angelscript/language/ast/core`, `angelscript/language/frontend/bodies` and `angelscript/language/types/stable-identity` are implementation/contract dependencies. Add deltas only for requirements actually changed after reading their current clauses; preserve typed ownership, verification and stable-identity invariants.

Design must allocate the exact durable reload scenarios to the owning capability without claiming the existing VM Change already supplies replacement UE integration.

## Impact

### Ownership

- **Parent repository:** This proposal, required planning task and indexed evidence; later durable deltas and migration of affected `Script/` examples.
- **Plugins/Angelscript submodule:** Maintained frontend/AST/metadata and direct consumers, replacement tests under `Source/AngelscriptTest/NewVersion/`, and explicitly selected replacement runtime/editor lifecycle integration.
- **Existing work:** Coordinate constructor, emitter, identity and format ownership with `angelscript/refactor-vm-symbolic-execution`. Do not rewrite its task state, diagnostics/testing-framework Changes, or the independent delegate Change as a side effect.
- **Host project:** Keep `Source/AngelscriptProject/` minimal. This is plugin behavior, not host-project game logic.

### Non-goals

- Adding a defaults block, automatic ConfigureDefaults hook, or compiler-inferred replayable subset of arbitrary constructor code.
- Changing delegate/event syntax, default arguments, switch labels, ordinary class construction rules without demonstrated impact, or UE editor property flags.
- Redesigning default-component declaration syntax, all Blueprint construction scripts, or the full editor reload system.
- A universal reset API for every live UObject state, automatic resurrection of the legacy runtime, or unconditional full-suite/build gates during record creation.

### Acceptance direction and next planning step

Future bounded feature groups must prove: old class-body forms reject with actionable diagnostics while switch/default arguments still work; declared/inherited defaults and access rules work through constructors; no ClassDefault executable survives newly produced artifacts; incompatible old artifacts reject; CDO and ordinary instances initialize correctly; Blueprint and instance overrides survive; supported reset retains object identity and does not alias CDO-owned components; constructor/default dependency changes produce new defaults with defined reload behavior.

Use exact replacement test identities and Harness proving commands when these groups are authored. The current delivery records intent and evidence only. `tasks.md` contains a pending planning outcome; design, durable scenarios, concrete integration APIs and the implementation DAG must be completed before product work. No build, runtime test or implementation is claimed by this record.
