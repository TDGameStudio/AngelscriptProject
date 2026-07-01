# as-compileout-bind-safety Specification

## Purpose
TBD - created by archiving change fix-as-compileout-previous-bind-null-guards. Update Purpose after archive.
## Requirements
### Requirement: Previous-bind compile-out helpers tolerate missing script functions

The Angelscript bind system SHALL treat `CompileOutPreviousBind()` and `CompileOutPreviousBindAsMethodChain()` as no-ops when the previous bind cannot be resolved to an `asCScriptFunction`.

#### Scenario: Previous bind lookup returns null

- **WHEN** either previous-bind compile-out helper resolves the previous function id through `GetFunctionById()` and receives null
- **THEN** the helper returns without dereferencing the function pointer
- **AND** no crash occurs

#### Scenario: Previous bind lookup returns a valid function

- **WHEN** either previous-bind compile-out helper resolves a valid script function
- **THEN** the helper sets that function's `compileOutType` to the same value as before this change

