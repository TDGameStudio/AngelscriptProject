## Purpose

Execute UE `DECLARE_*` callables on the replacement host without restoring the dormant legacy wrapper runtime.

## ADDED Requirements

### Requirement: Dynamic UPROPERTY members execute on the script CallPtr slot

After ClassGen materializes a dynamic `DECLARE_*` member as `FDelegateProperty` or `FMulticastInlineDelegateProperty`, script bind and fire SHALL use the pointer-sized CallPtr slot of that member. Native `ProcessDelegate` SHALL use a local `FMulticastScriptDelegate` plus the published `UDelegateFunction`, not the property bytes.

#### Scenario: Dynamic multicast UPROPERTY Broadcast writes Current and Max

- **GIVEN** an isolated host that compiled `UPROPERTY() FOnPropertyHealth Ev` and a listener `UFUNCTION void OnHealth(int NewCurrent, int NewMax)`

    > Context: the owner stores `Target` and `FunctionName` as `UPROPERTY`s. Sema `this` in `AddDynamic(this, FunctionName)` is unresolved; tests bind through those fields.

- **WHEN** script calls `Ev.AddDynamic(Target, FunctionName)` then `Ev.Broadcast(100, 75)`

    > Inputs: `FunctionName` is `OnHealth`.

- **THEN** the listener `Current` is 100 and `Max` is 75

    > Observables: two `UPROPERTY` ints on the listener.

    > Verification: NativeEngine Compile `DelegateProperty`.

- **BUT** native code does not `ProcessDelegate` through `ContainerPtrToValuePtr` on `Ev`

    > Boundaries: the script slot is pointer-sized; the property claims `sizeof(FMulticastScriptDelegate)`.

#### Scenario: Dynamic single-cast UPROPERTY Execute writes Result through a void UFUNCTION

- **GIVEN** `UPROPERTY() FPropertyAdd Handler` and `UFUNCTION void AddOne(int Value) { Result = Value + 1; }`

- **WHEN** script calls `Handler.BindDynamic(Target, FunctionName)` then `Handler.Execute(41)`

    > Inputs: `FunctionName` is `AddOne`. `Target` is the owner.

- **THEN** owner `Result` is 42

    > Observables: the `UPROPERTY` int side effect.

    > Verification: NativeEngine Compile `DelegateProperty`.

- **BUT** BindDynamic plus Execute does not promise retval assignment into a `UPROPERTY` int

    > Boundaries: a returning `UFUNCTION` writeback is a later requirement.

#### Scenario: Native ProcessDelegate uses the published signature and a local multicast

- **GIVEN** the published `SignatureFunction` on a materialized dynamic multicast `UPROPERTY`

- **WHEN** native code builds a local `FMulticastScriptDelegate`, `BindUFunction`s the listener `OnHealth`, and `ProcessDelegate`s `{100, 75}`

- **THEN** the listener `Current` is 100 and `Max` is 75

    > Observables: the same two ints as the script Broadcast case.

    > Verification: NativeEngine Compile `DelegateProperty`.

- **BUT** the local delegate is not the `UPROPERTY` storage

    > Boundaries: property-byte overlay remains forbidden.

#### Scenario: Clear and Remove stop later Broadcast on a UPROPERTY multicast

- **GIVEN** a bound dynamic multicast `UPROPERTY` whose first Broadcast already wrote `Current=100`

- **WHEN** script calls `Ev.Clear()`, resets `Current` to 0, and Broadcasts again; then re-Adds, `Remove`s the returned handle, resets `Current`, and Broadcasts again

- **THEN** both later Broadcasts leave `Current` at 0

    > Observables: the listener int does not change after Clear or Remove.

    > Verification: NativeEngine Compile `DelegateProperty`.

- **BUT** `Ev.IsBound()` is not required as a Sema callable operation

    > Boundaries: bound state is observed through fire versus no-fire.

#### Scenario: Script BindUFunction then Execute writes Result

- **GIVEN** `UPROPERTY() FPropertyAdd Handler` and the same void `AddOne`

- **WHEN** script calls `Handler.BindUFunction(Target, FunctionName)` then `Handler.Execute(41)`

- **THEN** owner `Result` is 42

    > Observables: the `UPROPERTY` int side effect.

    > Verification: NativeEngine Compile `DelegateProperty`.

#### Scenario: Dynamic multicast OneParam UPROPERTY Broadcast writes Current

- **GIVEN** `DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnPropertyOne, int, NewHealth)` stored as `UPROPERTY() FOnPropertyOne Ev`

- **WHEN** script AddDynamic binds `OnHealth` and Broadcasts 42

- **THEN** the listener `Current` is 42

    > Observables: one `UPROPERTY` int.

    > Verification: NativeEngine Compile `DelegateProperty`.
