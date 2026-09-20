## Purpose

Materialize dynamic `DECLARE_*` forms as Unreal reflection objects and adapt registered native `TDelegate` values.

## ADDED Requirements

### Requirement: Dynamic DECLARE forms materialize UDelegateFunction

The host SHALL materialize a complete `UDelegateFunction` and matching `FDelegateProperty` or `FMulticastInlineDelegateProperty` for each admitted dynamic `DECLARE_*` declaration after signature resolution, without reconstructing the signature from generated Execute/Broadcast methods.

#### Scenario: Dynamic multicast OneParam publishes a signature function

- **GIVEN** a host `FAngelscriptEngine` that compiled `DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnHealth, int, NewHealth);`

- **WHEN** ClassGen finishes Analyze and FullReload for that module

    > Inputs: `FAngelscriptDelegateDesc` from the descriptor consumer, including `bIsDynamic`, then ClassGen `UDelegateFunction` construction from `Desc.Signature`.

- **THEN** a `UDelegateFunction` named from `FOnHealth` exists and the script type UserData points at it

    > Observables: `UDelegateFunction*`, UserData, multicast flag, parameter name `NewHealth`.

    > Verification: NativeEngine Compile `DelegateReflection`.

- **BUT** Blueprint listeners and cooked load are outside this requirement

    > Boundaries: AST-time `UObject` creation remains forbidden. `GetMethodByName("Execute")` or `GetMethodByName("Broadcast")` is not a valid signature source.

#### Scenario: Ordinary DECLARE does not publish UDelegateFunction

- **GIVEN** the same host compiled `DECLARE_DELEGATE_OneParam(FOnDone, int);`

- **WHEN** ClassGen Analyze and FullReload finish for that module

- **THEN** `FAngelscriptDelegateDesc.Function` remains null and no public `UDelegateFunction` is registered for `FOnDone`

    > Observables: `FindObject<UDelegateFunction>` for the ordinary name fails; script UserData stays the script-callable tag.

    > Verification: NativeEngine Compile `DelegateReflection`.

- **BUT** the ordinary callable remains executable on the script CallPtr path

    > Boundaries: native `TDelegate` adapters are a separate requirement.

### Requirement: Native TDelegate adapters keep the original instance

Registered native `TDelegate` / `TMulticastDelegate` signatures SHALL receive real compiled C++ delegate values and borrowed native-event views that retain the original instance and native handle.

#### Scenario: Native single-cast yields a retained script callback

- **WHEN** a registered `TDelegate<int(int)>` is bound to a named script callback that returns input plus 40 and is invoked with 2

- **THEN** the native call returns 42

    > Verification: NativeEngine Compile `DelegateNativeInterop`.

- **BUT** script callable storage is never reinterpreted as a UE delegate object

    > Boundaries: unregistered native signatures are not invented at runtime.
