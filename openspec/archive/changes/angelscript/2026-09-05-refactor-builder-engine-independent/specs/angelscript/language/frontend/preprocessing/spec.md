## MODIFIED Requirements

### Requirement: Frozen conditional configuration
The frontend SHALL evaluate conditional directives against one immutable, explicitly identified flag configuration for the lifetime of a source snapshot.

#### Scenario: Select one branch deterministically
- **GIVEN** frozen source tokens and boolean flags
  > Inputs: Conditions support flags, 0/1, defined, !, &&, || and parentheses with normal boolean precedence.
- **WHEN** a balanced conditional section is evaluated
- **THEN** the first eligible true branch is selected deterministically
- **BUT** flag lookup does not expand ordinary source identifiers as textual macros

## ADDED Requirements

### Requirement: Preprocessing does not implement language declarations
The preprocessor SHALL produce directive records and selected Tokens without parsing declarations, building reflection types or synthesizing language wrapper text.

#### Scenario: Preserve a deferred body input
- **WHEN** a function body is analyzed after its declaration phase and temporary caller lexer objects have been destroyed
- **THEN** analysis consumes the original selected Tokens with valid identifiers and source ranges
- **BUT** it does not re-preprocess the raw body with a new configuration or incomplete outer conditional context

#### Scenario: Route a language construct after preprocessing
- **WHEN** active source contains annotations, delegate/event declarations, defaults or range loops
- **THEN** the selected Tokens reach Parser/Sema without generated AS text
  > Boundaries: Include expansion and text replacement macros remain unsupported; source backquery retains both active and inactive conditional regions.

