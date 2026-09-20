## MODIFIED Requirements

### Requirement: Host descriptions are declaration-stage products

The frontend SHALL expose collected declaration information and resolved signature/dependency descriptions independently of UE object materialization. A resolved `FAngelscriptDelegateDesc` SHALL carry ordinary-versus-dynamic flavor and the structured signature taken from the original `DECLARE_*` declaration.

#### Scenario: Observe an early callable declaration

- **WHEN** `DECLARE_*` declaration collection completes before all signature types resolve

    > Inputs: a supported family spelling whose parameter or return type is still an unresolved location.

- **THEN** a host can inspect the name, declaration kind, authored flavor, authored range and unresolved signature locations

- **BUT** the result is not advertised as a resolved reflection signature

    > Boundaries: leftover `delegate` / `event` introducers do not produce a callable description.

#### Scenario: Observe a resolved callable description

- **WHEN** signature types and dependencies resolve successfully

    > Inputs: `DECLARE_DELEGATE_OneParam(FOnDone, int);` or `DECLARE_DYNAMIC_DELEGATE_OneParam(FDynOne, int, Value);`.

- **THEN** the descriptor consumer supplies the structured signature, single/multicast classification, and ordinary/dynamic flavor from the original declaration

    > Observables: `FAngelscriptDelegateDesc.bIsDynamic`, `bIsMulticast`, `Signature` parameter types and dynamic parameter names.

- **AND** UE reflection pointers remain unmaterialized

    Ordinary flavor keeps `Function == nullptr`. Dynamic flavor also keeps `Function == nullptr` until the host materialization stage.

    > Boundaries: Reflection shell creation, FProperty completion and public runtime visibility belong to explicit host operations, not preprocessing or AST construction. ClassGen SHALL NOT reconstruct the signature from generated `Execute` / `Broadcast` methods.
