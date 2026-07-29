## ADDED Requirements

### Requirement: Loopback source-preview service
The tool SHALL provide an optional `serve` command that starts a Web preview service on `127.0.0.1` only. The command SHALL preserve the existing `generate` command and SHALL report how to install the optional Web dependencies when they are unavailable.

#### Scenario: Start the local preview service
- **WHEN** a developer installs the `web` extra and runs `angelscript-codegen serve`
- **THEN** the service listens on `127.0.0.1` at its configured port and serves the preview page

### Requirement: Reviewed scenario selection
The preview page SHALL display four Chinese-labelled scenario cards mapping only to the existing `native-core`, `ue-values`, `ue-annotated`, and `ue-world` profiles. A scenario SHALL describe only source shapes the current generator actually emits.

#### Scenario: Select the UE value-environment scenario
- **WHEN** a developer selects the UE value-environment card
- **THEN** the page selects the `ue-values` profile and describes it as a capability environment without claiming unimplemented random FVector or FString expressions

### Requirement: In-memory valid source preview
The preview API SHALL accept one selected scenario, an unsigned 64-bit seed, and positive expression/statement bounds within the scenario Profile's declared limits. It SHALL return one lifted valid AngelScript source case with its profile, expected outcome, harness, and `source-only` verification metadata.

#### Scenario: Preview an annotated UClass case
- **WHEN** a developer requests a preview for `uclass-annotation`
- **THEN** the response contains one `compile-pass`, `source-only` case using the `ue-annotated` profile and source containing its audited UClass fragment

### Requirement: Preview has no output side effects
The Web preview SHALL generate and return source entirely in memory. It MUST NOT write `.as` files, `index.json`, output directories, or run history records.

#### Scenario: Generate a native preview
- **WHEN** a developer submits a valid native-control-flow preview request
- **THEN** the service returns source without invoking the generator output writer or creating a generated artifact

### Requirement: Accessible Chinese source workbench
The page SHALL provide Chinese operational text, visible form labels, keyboard-operable scenario selection, a visible focus state, a live error region, and a read-only code display that inserts generated source as text rather than HTML. Technical identifiers and generated AngelScript SHALL remain unmodified.

#### Scenario: Invalid preview parameters
- **WHEN** a developer supplies an invalid seed or bounds outside the selected Profile limit
- **THEN** the page presents a nearby Chinese error message without replacing the existing source preview
