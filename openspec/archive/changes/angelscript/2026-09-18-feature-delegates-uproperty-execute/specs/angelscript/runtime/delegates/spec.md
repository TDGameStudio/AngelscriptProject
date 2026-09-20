## ADDED Requirements

### Requirement: UPROPERTY CallPtr reports binding state

A script `IsBound()` call on a dynamic `UPROPERTY` delegate member SHALL return whether the CallPtr slot currently holds a binding.

#### Scenario: IsBound is false before bind and true after AddDynamic

- **GIVEN** an isolated host that compiled `UPROPERTY() FOnPropertyHealth Ev` on a `UCLASS`

    > Context: `IsBound` is a Sema member operation on the CallPtr slot, not a native `FMulticastScriptDelegate` query on property bytes.

- **WHEN** script reads `Ev.IsBound()`, then `AddDynamic` binds a listener, then script reads `Ev.IsBound()` again

    > Inputs: the same `UObject` instance for both reads.

- **THEN** the first read is false and the second read is true

    > Observables: boolean return from `IsBound`.

    > Verification: NativeEngine Compile `DelegateProperty`.

- **AND** `Clear()` makes a later `IsBound()` false again

    > Observables: binding state follows `ClearPtr`.

### Requirement: BindDynamic accepts this as the listener target

`BindDynamic(this, FunctionName)` and `AddDynamic(this, FunctionName)` on a dynamic `UPROPERTY` member SHALL bind the current script object.

#### Scenario: AddDynamic this broadcasts to the owner

- **GIVEN** an isolated host `UCLASS` with `UPROPERTY() FOnPropertyHealth Ev` and a `UFUNCTION` listener that writes `Current`

    > Context: a bare-target first argument named `this` is the current object, not an unresolved declaration reference.

- **WHEN** script runs `Ev.AddDynamic(this, FunctionName)` then `Ev.Broadcast(100, 75)`

    > Inputs: `Current` starts at 0.

- **THEN** `Current` is 100

    > Observables: listener side-effect on the same instance.

    > Verification: NativeEngine Compile `DelegateProperty`.

- **BUT** a missing `UFUNCTION` name still fails compile

    > Boundaries: `this` does not bypass bind-name checking.

### Requirement: ExecuteIfBound is quiet when the CallPtr slot is unbound

`ExecuteIfBound` on a dynamic single-cast `UPROPERTY` SHALL do nothing when the CallPtr slot is unbound, while unbound `Execute` still throws.

#### Scenario: Unbound ExecuteIfBound leaves Current unchanged

- **GIVEN** an isolated host `UCLASS` with unbound `UPROPERTY() FPropertyAdd Handler` and `UPROPERTY() int Current = 7`

    > Context: `ExecuteIfBound` does not share the throwing unbound `CallPtr` path used by `Execute`.

- **WHEN** script calls `Handler.ExecuteIfBound(42)`

    > Inputs: no prior `BindDynamic` or `BindUFunction`.

- **THEN** `Current` is still 7 and compile/runtime emit no unbound-function exception

    > Observables: side-effect absence and a completed call.

    > Verification: NativeEngine Compile `DelegateProperty`.

### Requirement: Bound UFUNCTION writeback through CallPtr

`asCallBoundUFunction` SHALL write `CPF_ReturnParm` and dword-sized parameter values, including `FName`, when a CallPtr slot invokes a bound `UFUNCTION`.

#### Scenario: BindUFunction Execute writes a returned int onto the owner

- **GIVEN** an isolated host `UCLASS` with `UPROPERTY() FPropertyGet Handler` and a `UFUNCTION` that returns `42`

    > Context: earlier CallPtr UFUNCTION dispatch skipped `CPF_ReturnParm` and only copied `FIntProperty` args.

- **WHEN** script runs `Handler.BindUFunction(Target, FunctionName)` then `int Result = Handler.Execute()`

    > Inputs: `Result` starts at 0.

- **THEN** `Result` is 42

    > Observables: return writeback on the script assignment.

    > Verification: NativeEngine Compile `DelegateProperty`.

#### Scenario: One-param FName UFUNCTION receives the broadcast name

- **GIVEN** an isolated host `UCLASS` with a one-param `FName` dynamic multicast `UPROPERTY` and a `UFUNCTION` that copies the name into an `FName` field

    > Inputs: broadcast argument `FName("Health")`.

- **WHEN** script `AddDynamic` binds that `UFUNCTION` and `Broadcast`s the name

- **THEN** the owner `FName` field equals `Health`

    > Observables: dword-sized `FName` copy through CallPtr dispatch.

    > Verification: NativeEngine Compile `DelegateProperty`.

### Requirement: Native fire converts from the CallPtr slot

Native code SHALL fire a script `UPROPERTY` delegate by converting the CallPtr slot into a temporary native multicast, never by `ProcessDelegate` on the property bytes.

#### Scenario: ProcessCallPtr fires a script-bound multicast

- **GIVEN** an isolated host `UCLASS` whose `UPROPERTY() FOnPropertyHealth Ev` was bound by script `AddDynamic`

    > Context: `FAngelscriptDelegateOperations::ProcessCallPtr` reads the pointer-sized slot and the published `UDelegateFunction`.

- **WHEN** native code calls `ProcessCallPtr` with that slot, the published signature, and a two-int parameter buffer `(100, 75)`

    > Inputs: `Current` starts at 0.

- **THEN** `Current` is 100

    > Observables: listener side-effect without touching a native `FMulticastScriptDelegate` overlay on `Ev`.

    > Verification: NativeEngine Compile `DelegateProperty`.

- **BUT** native code does not `ProcessDelegate` the `FMulticastInlineDelegateProperty` bytes

    > Boundaries: convert-and-fire is the supported native path. Property-byte overlay remains outside this capability.

### Requirement: SoftReload copies only the CallPtr slot for script delegate properties

SoftReload property copy for a script delegate `UPROPERTY` SHALL copy `AS_PTR_SIZE` bytes so a neighbor property and the later Broadcast path stay valid.

#### Scenario: SoftReload keeps a bound Ev and the neighbor int

- **GIVEN** an isolated host `UCLASS` with `UPROPERTY() int Current` beside `UPROPERTY() FOnPropertyHealth Ev`, after script `AddDynamic` and `Current = 7`

    > Context: `FRawUnrealPropertyType::CopyValue` must not `CopyCompleteValue` a native multicast blob over the pointer-sized slot.

- **WHEN** `CompileModules(SoftReloadOnly)` reloads the same class layout

    > Inputs: the live `UObject` instance is preserved.

- **THEN** `Current` is still 7, `Ev.IsBound()` is true, and `Ev.Broadcast(100, 75)` writes `Current` to 100

    > Observables: neighbor integrity plus post-reload CallPtr fire.

    > Verification: NativeEngine Compile `DelegateProperty`.

## MODIFIED Requirements

### Requirement: Dynamic UPROPERTY members execute on the script CallPtr slot

A compiled dynamic `DECLARE_*` member stored as `UPROPERTY` SHALL bind and fire through the pointer-sized script CallPtr slot. Native overlay of `FScriptDelegate` or `FMulticastScriptDelegate` on those bytes is not required for script execute.

#### Scenario: Script AddDynamic then Broadcast writes Current through the UPROPERTY slot

- **GIVEN** an isolated host that compiled `DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnPropertyHealth, int, Current, int, Max)` and a `UCLASS` with `UPROPERTY() FOnPropertyHealth Ev` plus `UPROPERTY() int Current`

    > Context: ClassGen linked `Ev` at the script `byteOffset`. The slot holds a CallPtr listener list, not a native multicast value.

- **WHEN** script `AddDynamic` binds a `UFUNCTION` listener and `Broadcast(100, 75)`

    > Inputs: `Current` starts at 0. CacheV2 is off.

- **THEN** `Current` is 100

    > Observables: listener side-effect on the same `UObject`.

    > Verification: NativeEngine Compile `DelegateProperty`.

- **BUT** native code does not `ProcessDelegate` the `FMulticastInlineDelegateProperty` bytes at that offset

    > Boundaries: those bytes are not a native `FMulticastScriptDelegate`. Native fire uses convert-from-CallPtr.

#### Scenario: Script BindDynamic then Execute writes through a single-cast UPROPERTY

- **GIVEN** an isolated host that compiled `DECLARE_DYNAMIC_DELEGATE_OneParam(FPropertyAdd, int, Value)` and a `UCLASS` with `UPROPERTY() FPropertyAdd Handler` plus `UPROPERTY() int Result`

    > Context: single-cast CallPtr holds one binding. A void `UFUNCTION` writes `Result` by side-effect.

- **WHEN** script `BindDynamic` binds that `UFUNCTION` and `Execute(42)`

    > Inputs: `Result` starts at 0. The bind target is a real `UObject`, not the identifier `this` unless Sema has resolved `this`.

- **THEN** `Result` is 42

    > Observables: void UFUNCTION side-effect.

    > Verification: NativeEngine Compile `DelegateProperty`.

#### Scenario: Native ProcessDelegate uses the published UDelegateFunction on a local multicast

- **GIVEN** the same compiled class whose `FOnPropertyHealth` published a `UDelegateFunction`

    > Context: `CreateFullReloadDelegate` already publishes the signature for native bind.

- **WHEN** native code builds a local `FMulticastScriptDelegate`, `Add`s the listener, and `ProcessDelegate`s that local value

    > Inputs: the parameter buffer is `(100, 75)`. `Current` starts at 0.

- **THEN** `Current` is 100

    > Observables: native fire through the published signature, not through `Ev` property bytes.

    > Verification: NativeEngine Compile `DelegateProperty`.

#### Scenario: Clear and Remove stop later Broadcast on a UPROPERTY slot

- **GIVEN** an isolated host `UCLASS` with `UPROPERTY() FOnPropertyHealth Ev` after a successful `AddDynamic` bind

    > Context: `Clear` and `Remove` are already Sema/`ClearPtr`/`RemovePtr` operations on the CallPtr slot.

- **WHEN** script `Clear()`s or `Remove()`s the listener and then `Broadcast(100, 75)`

    > Inputs: `Current` is reset to 0 before the post-clear Broadcast.

- **THEN** `Current` stays 0

    > Observables: later Broadcast is a no-op after the slot is cleared or the listener is removed.

    > Verification: NativeEngine Compile `DelegateProperty`.

- **AND** `RemoveAll(Target)` also leaves a later Broadcast at `Current == 0`

    > Observables: `RemoveAll` is the same CallPtr list removal already emitted for local delegates.

- **BUT** native code still does not `ProcessDelegate` the property bytes

    > Boundaries: CallPtr remains the script source of truth.
