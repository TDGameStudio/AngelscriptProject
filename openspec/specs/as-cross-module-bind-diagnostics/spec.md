# as-module-binding-bind-diagnostics Specification

## Purpose
TBD - created by archiving change improve-as-disabled-module-binding-diagnostics. Update Purpose after archive.
## Requirements
### Requirement: Disabled module module-binding candidates are protocol-classified

The UHT skipped diagnostics SHALL distinguish disabled-module unexported-symbol candidates that are safe for module-binding frame wrappers from candidates blocked by signature or parameter protocols.

#### Scenario: Disabled module candidate is safe

- **WHEN** an Angelscript-callable UFunction fails direct binding with `unexported-symbol`, belongs to a module outside the enabled module-binding set, and passes module-binding signature/protocol classification
- **THEN** `AS_FunctionTable_SkippedEntries.csv` records `disabled-safe-module-binding`
- **AND** `AS_FunctionTable_SkippedReasonSummary.csv` includes the `disabled-safe-module-binding` count

#### Scenario: Disabled module candidate needs a protocol

- **WHEN** an Angelscript-callable UFunction fails direct binding with `unexported-symbol`, belongs to a module outside the enabled module-binding set, and fails module-binding classification for a known protocol reason
- **THEN** the skipped reason is prefixed with `disabled-`
- **AND** the suffix matches the enabled-module protocol reason

#### Scenario: Enabled module diagnostics remain unchanged

- **WHEN** a candidate belongs to a currently enabled module-binding module
- **THEN** the existing enabled-module reasons and generated entry classifications remain unchanged
- **AND** no additional module-binding wrapper thunks are emitted by this diagnostic change

