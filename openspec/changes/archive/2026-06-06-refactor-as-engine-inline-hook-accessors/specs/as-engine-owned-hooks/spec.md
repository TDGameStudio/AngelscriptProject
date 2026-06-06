# as-engine-owned-hooks Specification (Delta)

## MODIFIED Requirements

### Requirement: ClassGenerator does not own process-wide reload hooks

`FAngelscriptClassGenerator` SHALL NOT expose process-wide static delegates for reload-lifecycle events.

#### Scenario: Reload hook is registered through the engine

- **WHEN** runtime, editor, or test code needs a class-reload, enum-created, enum-changed, struct-reload, delegate-reload, full-reload, post-reload, or literal-asset-reload notification
- **THEN** it SHALL register through the active `FAngelscriptEngine`'s direct hook accessor (`FAngelscriptEngine::Get().GetOnXxx()`) rather than through `FAngelscriptClassGenerator::OnXxx`

#### Scenario: ClassGenerator header has no static reload delegate fields

- **WHEN** `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.h` is inspected
- **THEN** it SHALL NOT declare any `static FOnAngelscript*` delegate field
- **AND** the corresponding definitions in `AngelscriptClassGenerator.cpp` SHALL be removed

#### Scenario: Hook accessors are direct members of FAngelscriptEngine

- **WHEN** application or test code wants to subscribe or broadcast on any of the 19 engine-owned hooks (compile lifecycle, class generation, reload lifecycle, asset lifecycle, runtime helpers)
- **THEN** the access path SHALL be `Engine.GetXxx()` directly on `FAngelscriptEngine`
- **AND** there SHALL NOT be an intermediate container struct (such as `FAngelscriptEngineHooks`) or `Engine.GetHooks()` method exposed by the engine
