## ADDED Requirements

### Requirement: Named callable bind and invoke share one signature

Body analysis SHALL resolve `Bind` of a named free function or member against the frozen `asCCallableTypeDecl` signature, and SHALL type `Execute` together with a direct call of a callable-typed variable as the same indirect call with that signature's return type.

#### Scenario: Bind selects the matching int overload

- **GIVEN** `DECLARE_DELEGATE_RetVal_OneParam(int, FAdd, int);` and overloads `Add(bool)` / `Add(int)`

    Both overloads are already in the frozen declaration environment before the body that calls `Bind` is analyzed.

- **WHEN** Sema analyzes `D.Bind(Add)` on a `FAdd` value

    > Inputs: authored name `Add`, delegate signature `int(int)`.

- **THEN** the bind plan refers to the `int` overload and not the `bool` overload

    > Observables: callee declaration identity, converted argument types.

    > Verification: NativeEngine Sema `DelegateBinding`.

- **BUT** a bool-only target publishes no bind plan

    > Boundaries: runtime objects and bytecode are absent at this stage.

#### Scenario: Execute and a direct callable call have the same return type

- **WHEN** a body writes `return Handler.Execute(2);` or `return Handler(2);` where `Handler` has a resolved `int(int)` callable type

    > Inputs: `DECLARE_DELEGATE_RetVal_OneParam` or an equivalent frozen callable type.

- **THEN** both call expressions have primitive `int` result type

    > Observables: `asCCallExpr` return type, argument count 1.

    > Verification: NativeEngine Sema `DelegateBinding` and the existing indirect-call typing path.

- **BUT** no `asBC_CallPtr` or return register is allocated during body analysis

    > Boundaries: definition-graph CallPtr emission belongs to the compile capability.
