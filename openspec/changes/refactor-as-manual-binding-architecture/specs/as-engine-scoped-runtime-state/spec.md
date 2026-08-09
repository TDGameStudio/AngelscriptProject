## ADDED Requirements

### Requirement: Process-wide binding state is limited to callback metadata

The process-wide binding collection SHALL contain only logical name, phase, owner module, source provenance, and a process-lifetime callback pointer. It SHALL NOT contain resolved reflection results, AngelScript objects or ids, expanded declarations/methods/properties, engine-owned auxiliary values, enable/filter state, dependencies, or unload handles.

#### Scenario: Process collection is inspected

- **WHEN** diagnostics inspect the sealed bind collection
- **THEN** they can report provider identity, phase, module, and source
- **AND** no AS type/function/object pointer or registration id is present

#### Scenario: Subsystem has initialized

- **WHEN** `UAngelscriptSubsystem` has loaded modules and finalized the collection
- **THEN** the one global collection remains the source of callback metadata
- **AND** the subsystem owns no copy, pointer view, or expanded binding member

### Requirement: Every callback mutation has an explicit engine target

Each full engine binding pass SHALL construct `FAngelscriptBinds` for one explicit `FAngelscriptEngine`. Type adapters/finders, well-known type slots, ToString, BindDB, string factory/default array selection, interface signatures/user data, generated/reflection bindings, traits, and finalizers SHALL resolve their mutable targets through that context. Completed binding code SHALL NOT choose a target through an ambient current engine or unpartitioned fallback store.

#### Scenario: Type and ToString work targets Engine B

- **WHEN** Engine B replays callbacks that register a type adapter and ToString formatter
- **THEN** those results are stored only in Engine B's databases/collections
- **AND** Engine A's corresponding state is unchanged

#### Scenario: BindDB is loaded and consumed

- **WHEN** a direct callback consults `Binds.Cache`
- **THEN** it reads the `FAngelscriptBindDatabase` owned by the explicit engine
- **AND** no legacy fallback database receives the operation

### Requirement: Multiple engines replay callbacks but isolate results

The sealed process callback collection SHALL be reused by every full engine, while each engine SHALL independently own all AS registration ids/objects and auxiliary results produced by callback replay. Engine teardown SHALL release only that engine's state and SHALL NOT invalidate the callback collection or another engine.

#### Scenario: Two engines execute one callback collection

- **WHEN** Engine A and Engine B initialize in the same process
- **THEN** both execute the same callback identities in the same phase order
- **AND** their AS ids, type pointers, bind states, databases, finders, ToString entries, and interface state are distinct

#### Scenario: One engine is destroyed

- **WHEN** Engine A is torn down while Engine B remains valid
- **THEN** Engine A's resolved binding state is released
- **AND** the sealed callback collection and Engine B's state remain valid

## MODIFIED Requirements

### Requirement: Engine-owned AngelScript objects are not unpartitioned process state

Runtime code SHALL NOT store engine-owned AngelScript objects or ids in unpartitioned process-wide statics. The process callback collection MAY store only replayable native callback metadata; all resolved types, functions, objects, ids, traits, and auxiliary stores SHALL belong to a specific engine.

#### Scenario: Runtime needs an AS object pointer

- **WHEN** binding or runtime code stores an `asITypeInfo*`, `asIScriptFunction*`, `asIScriptObject*`, context, or registration id
- **THEN** ownership is reachable from one explicit `FAngelscriptEngine`
- **AND** teardown removes it with that engine

#### Scenario: Direct bound result is used

- **WHEN** `FAngelscriptBoundFunction` or `FAngelscriptBoundProperty` applies a fluent option
- **THEN** it uses the explicit engine and exact id/pointer held by that temporary value
- **AND** the value is not added to process-global state

## REMOVED Requirements

### Requirement: Legacy fallbacks may hide engine-owned binding state

**Reason**: Fallback stores silently route binding work outside the explicit engine and can leak state across full-engine recreation.

**Migration**: Route all binding-path database, finder, formatter, interface, and trait operations through the `FAngelscriptBinds` target engine.

### Requirement: ToString fallback exposes cross-engine type info

**Reason**: Cached `asITypeInfo*` values are engine-specific and become stale after teardown.

**Migration**: Each engine callback replay registers and finalizes ToString contributions directly in that engine's store during the declared phases.
