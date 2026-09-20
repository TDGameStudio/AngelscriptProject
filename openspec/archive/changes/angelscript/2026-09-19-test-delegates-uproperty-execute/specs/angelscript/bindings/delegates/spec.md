## Purpose

Materialize dynamic `DECLARE_*` forms as Unreal reflection objects and adapt registered native `TDelegate` values.

## ADDED Requirements

### Requirement: Isolated host seeds script delegate property adapters

An isolated `FAngelscriptEngine` created with `bSkipInitialCompile` SHALL install `ScriptDelegateType` and `ScriptMulticastDelegateType` so a dynamic `DECLARE_*` member can become an `FDelegateProperty` or `FMulticastInlineDelegateProperty`.

#### Scenario: Isolated host UPROPERTY dynamic multicast is FMulticastInlineDelegateProperty

- **GIVEN** a host `FAngelscriptEngine` created with `bSkipInitialCompile` and CacheV2 off

    > Context: `Bind_Delegates` returns on `IsHostTarget` and does not install these adapters. Host inject also does not replay bind TypeDatabase adapters.

- **WHEN** `CompileModules(Initial)` admits `DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnPropertyHealth, int, Current, int, Max)` and a `UCLASS` with `UPROPERTY() FOnPropertyHealth Ev`

    > Inputs: `SeedHostScriptDelegateTypes` has assigned `FScriptDelegateType` and `FMulticastScriptDelegateType` on the host TypeDatabase.

- **THEN** `Ev` is an `FMulticastInlineDelegateProperty` whose `SignatureFunction` name contains `FOnPropertyHealth`

    > Observables: property class and published `UDelegateFunction`.

    > Verification: NativeEngine Compile `DelegateProperty`.

- **BUT** the property bytes are not a native `FMulticastScriptDelegate` the script CallPtr slot can share

    > Boundaries: overlay storage is a later capability. Ordinary multicast `UPROPERTY(BlueprintAssignable)` stays rejected.

#### Scenario: Isolated host UPROPERTY dynamic single-cast is FDelegateProperty

- **GIVEN** the same isolated host

- **WHEN** `CompileModules(Initial)` admits `DECLARE_DYNAMIC_DELEGATE_OneParam(FPropertyAdd, int, Value)` and a `UCLASS` with `UPROPERTY() FPropertyAdd Handler`

- **THEN** `Handler` is an `FDelegateProperty` with a non-null `SignatureFunction`

    > Observables: property class and published signature.

    > Verification: NativeEngine Compile `DelegateProperty`.
