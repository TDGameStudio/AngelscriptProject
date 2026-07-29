## MODIFIED Requirements

### Requirement: Runtime Version Uses Owned UEAS Label
Documentation that needs a runtime or fork version MUST use the owned form `Unreal AngelScript <semver>` as the primary product version label. `UEAS` MAY be used only as a defined technical abbreviation and MUST NOT replace the primary release identity.

#### Scenario: Runtime version is documented
- **WHEN** documentation identifies the current fork/runtime version
- **THEN** it uses `Unreal AngelScript 1.0.0` and does not claim the runtime is vanilla AngelScript 2.33 or 2.38

#### Scenario: Technical text uses an abbreviation
- **WHEN** technical documentation uses `UEAS`
- **THEN** the surrounding document first defines it as an abbreviation of `Unreal AngelScript` and retains the full product name for release identity
