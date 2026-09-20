## Purpose

Execute UE `DECLARE_*` callables on the replacement host without restoring the dormant legacy wrapper runtime.

## ADDED Requirements

### Requirement: DECLARE forms bind and execute named targets

After `CompileModules` admits a module that declared a supported `DECLARE_*` callable, the replacement host SHALL bind a named script free function or member and return or broadcast the independently specified values.

    Ordinary and dynamic flavors share this execution path until reflection materialization is proven. Empty non-void Execute fails without inventing a return. Void callbacks provide ExecuteIfBound. Multicast uses Add and Broadcast.

#### Scenario: Ordinary RetVal OneParam Execute returns 42

- **GIVEN** a host `FAngelscriptEngine` created with `bSkipInitialCompile` and CacheV2 off

- **WHEN** source declares `DECLARE_DELEGATE_RetVal_OneParam(int, FAddOne, int);`, binds named `int AddOne(int Value) { return Value + 1; }`, and Execute is invoked with 41

    > Inputs: `FAngelscriptEngine::CompileModules(Initial)`, then the declared Bind/Execute API recorded by task 1.1.

- **THEN** Execute returns 42

    > Observables: integer return.

    > Verification: NativeEngine Compile `DelegateExecute`.

- **BUT** this requirement does not restore preprocessor `_FScriptDelegate` wrappers or `WITH_ANGELSCRIPT_UNITTESTS`

    > Boundaries: explicit bind-time payloads are a later requirement. Language folder execute is outside this requirement.

#### Scenario: Ordinary multicast OneParam Broadcast reaches two listeners

- **GIVEN** the same host setup and `DECLARE_MULTICAST_DELEGATE_OneParam(FOnValue, int);`

- **WHEN** two named void listeners are Added and Broadcast is invoked with 7

- **THEN** both listeners observe 7

    > Observables: two independent recorded values.

    > Verification: NativeEngine Compile `DelegateExecute`.

- **BUT** listener order is not specified

    > Boundaries: handle Remove/RemoveAll mutation matrix belongs to the multicast-subscription requirement.

#### Scenario: Dynamic RetVal Execute uses the same callable path

- **GIVEN** `DECLARE_DYNAMIC_DELEGATE_RetVal_OneParam(int, FAddOne, int, Value);` and the same named `AddOne`

- **WHEN** the dynamic delegate is bound and Execute is invoked with 41

- **THEN** Execute returns 42

    > Verification: NativeEngine Compile `DelegateExecute`.

- **BUT** `UDelegateFunction` publication is not required for this scenario

    > Boundaries: reflected property materialization belongs to the bindings capability.
