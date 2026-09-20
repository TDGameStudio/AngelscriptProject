## ADDED Requirements

### Requirement: Initial compile materializes a callable UFUNCTION

The host engine SHALL, after `CompileModules` with `ECompileType::Initial` and existing ClassGenerator, bind each host `ClassDesc` method whose `ScriptFunctionName` exists on the registered TypeInfo to a `UASFunction` whose ProcessEvent executes that script body.

    Production Methods remain preprocessor-filled. A test that skips the preprocessor MAY hand-fill the same `Methods` table.

#### Scenario: Initial ProcessEvent returns a UFUNCTION result

- **GIVEN** a host `FAngelscriptEngine` with a script package and one module whose class descriptor already has `CodeSuperClass` and one BlueprintCallable method row

    The source method is annotated `UFUNCTION()` and returns the integer 7. The class has no `UCLASS()` / `: UObject` spelling. Frontend `CompileDeclarations` is not this path.

- **WHEN** the host compiles that module with `ECompileType::Initial` and ProcessEvent is invoked on the generated function

    > Inputs: `FAngelscriptEngine::CompileModules(Initial, InModules, OutCompiledModules)`, then `UObject::ProcessEvent`.

- **THEN** the generated `UASFunction::ScriptFunction` is non-null and ProcessEvent returns 7

    > Observables: `FAngelscriptFunctionDesc::Function`, `UASFunction::ScriptFunction`, ProcessEvent return parm.

    > Verification: NativeEngine Compile `ClassGenCall`.

- **BUT** this capability SHALL NOT require a script construct, a method-body reload, Language corpus execute, or copying Builder CompileOutput Methods onto the host descriptor

    > Boundaries: CacheV2 reuse and BlueprintEvent `_Implementation` wrappers stay outside this requirement.
