## MODIFIED Requirements

### Requirement: Native callable type declarations

The Parser and Sema SHALL represent the six UE `DECLARE_*` families as explicit callable-type declarations with ordinary-versus-dynamic flavor, single-versus-multicast classification, and structured signatures. The Parser and Sema SHALL reject `delegate` and `event` as callable introducers.

    Supported families, each with no suffix through `NineParams` (60 spellings): `DECLARE_DELEGATE`, `DECLARE_DELEGATE_RetVal`, `DECLARE_MULTICAST_DELEGATE`, `DECLARE_DYNAMIC_DELEGATE`, `DECLARE_DYNAMIC_DELEGATE_RetVal`, `DECLARE_DYNAMIC_MULTICAST_DELEGATE`. Ordinary forms take unnamed parameter types. Dynamic forms take type/name pairs. Multicast forms require void returns. One declaration-form table and one 60-row expectation matrix implement the surface; the frontend SHALL NOT grow a parser per spelling.

#### Scenario: Resolve a forward-referenced signature

- **WHEN** a `DECLARE_*` signature refers to a type collected later in the same source set

    > Inputs: `DECLARE_DELEGATE_RetVal_OneParam(int, FMake, Payload);` while `class Payload {}` is declared later in the same compilation.

- **THEN** declaration collection retains the unresolved type location and declaration resolution supplies the canonical type and dependency

    > Observables: resolved signature type, nominal delegate name `FMake`.

- **BUT** the frontend does not manufacture an AS wrapper struct or infer the signature from generated Execute/Broadcast methods

    > Boundaries: preprocessor `ProcessDelegates` wrapper generation is not a valid implementation of this requirement.

#### Scenario: Reject removed delegate and event keywords

- **WHEN** active source declares `delegate int FOnDone();` or `event void FOnChanged();`

    > Inputs: the former AngelScript callable introducers.

- **THEN** Parser reports `removed-delegate-event-keyword` on the introducer range and can continue with the following declaration

    > Observables: diagnostic id, source range, recovery to the next declaration.

- **BUT** no `asCCallableTypeDecl` is published for that name

    > Boundaries: this is a transitional reject, not a preprocessor rewrite into `_FScriptDelegate`, and not a durable keyword product. Token deletion is a later Change.

#### Scenario: Admit a DECLARE_DELEGATE_OneParam form

- **WHEN** active source contains `DECLARE_DELEGATE_OneParam(FOnDone, int);`

    > Inputs: ordinary void single-cast, one unnamed parameter type `int`, name `FOnDone`.

- **THEN** Sema publishes a callable type named `FOnDone` with ordinary flavor, single-cast classification, void return, and one `int` parameter

    > Observables: name, flavor, multicast flag, parameter count and types.

- **AND** an equivalent later `DECLARE_DELEGATE_OneParam(FOnDone, int);` in the same compilation is the same nominal identity

    > Verification: NativeEngine Sema `DelegateDeclarations`.

#### Scenario: Admit ordinary versus dynamic flavor

- **WHEN** source declares `DECLARE_DELEGATE_OneParam(FOnDone, int);` and `DECLARE_DYNAMIC_DELEGATE_OneParam(FDynOne, int, Value);`

    > Inputs: one ordinary unnamed-type form and one dynamic type/name pair.

- **THEN** Sema publishes `FOnDone` with ordinary flavor and `FDynOne` with dynamic flavor

    > Observables: `asECallableFlavor` on `asCCallableTypeDecl`. Dynamic form retains parameter name `Value`. Ordinary form has no authored parameter name.

    > Verification: NativeEngine Sema `DelegateDeclarations`.

- **BUT** flavor does not by itself create a `UDelegateFunction`

    > Boundaries: reflection materialization belongs to the bindings capability.

#### Scenario: Diagnose an unsupported UE family

- **WHEN** active source spells `DECLARE_EVENT`, `DECLARE_DERIVED_EVENT`, `DECLARE_TS_MULTICAST_DELEGATE`, or `DECLARE_DYNAMIC_MULTICAST_SPARSE_DELEGATE` with a legal arity suffix

    > Inputs: the 31 deferred spellings inventoried from UE 5.8 `DelegateCombinations.h`, `Delegate.h`, and `SparseDelegate.h`.

- **THEN** Parser reports `unsupported-delegate-declaration-form` and recovers

    > Observables: diagnostic id, original spelling range.

- **BUT** the form is not silently treated as `DECLARE_MULTICAST_DELEGATE` or a dynamic multicast

    > Boundaries: owner-only Event publication, TS threading, sparse storage, and derived-event bases are out of scope.
