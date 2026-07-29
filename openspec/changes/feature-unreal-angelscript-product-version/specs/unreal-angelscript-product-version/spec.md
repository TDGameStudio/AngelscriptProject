## ADDED Requirements

### Requirement: Core Product Uses Owned Semantic Version
The core plugin, embedded runtime, and standalone release contract MUST identify the current product as `Unreal AngelScript 1.0.0`, with encoded version `10000`.

#### Scenario: Consumer queries the current runtime
- **WHEN** a consumer calls the runtime version query
- **THEN** the returned identity is `Unreal AngelScript 1.0.0` and not an upstream AngelScript release label

#### Scenario: Unreal loads the core plugin descriptor
- **WHEN** Unreal reads `Angelscript.uplugin`
- **THEN** its integer version is `10000`, display version is `1.0.0`, and friendly name is `Unreal AngelScript`

### Requirement: Engine Creation Enforces Owned SemVer Compatibility
The runtime MUST accept a non-zero requested version only when its major version equals the available runtime major and the requested encoded version is not newer than the available encoded version.

#### Scenario: Current header requests current runtime
- **WHEN** `asCreateScriptEngine` receives `10000` from the 1.0.0 header
- **THEN** engine creation succeeds

#### Scenario: Legacy upstream header requests owned runtime
- **WHEN** `asCreateScriptEngine` receives the former upstream value `23300`
- **THEN** engine creation fails without a compatibility exception

#### Scenario: Newer header requests older runtime
- **WHEN** a requested version is newer than the available runtime version
- **THEN** engine creation fails

#### Scenario: Older compatible header requests later runtime
- **WHEN** requested and available versions have the same major and the requested version is older
- **THEN** the compatibility rule accepts the request

#### Scenario: Different major requests runtime
- **WHEN** requested and available versions use different major versions
- **THEN** the compatibility rule rejects the request

### Requirement: Upstream Lineage Is Queryable Separately
The runtime MUST expose upstream source lineage separately from the current product version and MUST report `AngelScript 2.33.0 WIP lineage + selective 2.38 backports`.

#### Scenario: Consumer audits source provenance
- **WHEN** a consumer calls the upstream-lineage query
- **THEN** the runtime returns the 2.33 WIP lineage and selective 2.38 backport description without changing the current product identity

### Requirement: Version Sources Remain Synchronized
The plugin MUST provide a non-mutating validation command that verifies the public version header and core plugin descriptor agree on encoded version, semantic version, and product name.

#### Scenario: Version sources agree
- **WHEN** the validator reads the checked-in 1.0.0 header and descriptor
- **THEN** it exits successfully without modifying repository files

#### Scenario: Version sources drift
- **WHEN** a descriptor or header field does not match the canonical version contract
- **THEN** the validator reports the mismatched field and exits non-zero

### Requirement: Optional Plugins Retain Independent Versions
The product version change MUST NOT alter the version fields of the optional `AngelscriptGameplayTags` or `AngelscriptGAS` plugins.

#### Scenario: Core product version is adopted
- **WHEN** the core plugin moves to Unreal AngelScript 1.0.0
- **THEN** optional plugin descriptors remain independently versioned
