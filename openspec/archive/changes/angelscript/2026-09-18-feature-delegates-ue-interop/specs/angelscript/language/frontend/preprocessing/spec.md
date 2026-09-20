## MODIFIED Requirements

### Requirement: Preprocessing does not implement language declarations

The preprocessor SHALL produce directive records and selected Tokens without parsing declarations, building reflection types or synthesizing language wrapper text.

#### Scenario: Preserve a deferred body input

- **WHEN** a function body is analyzed after its declaration phase and temporary caller lexer objects have been destroyed

- **THEN** analysis consumes the original selected Tokens with valid identifiers and source ranges

- **BUT** it does not re-preprocess the raw body with a new configuration or incomplete outer conditional context

#### Scenario: Route a language construct after preprocessing

- **WHEN** active source contains annotations, `DECLARE_*` callable declarations, leftover `delegate` / `event` introducers, defaults or range loops

    > Inputs: `UCLASS` / `UFUNCTION` annotations and `DECLARE_DELEGATE_OneParam(FOnDone, int);`.

- **THEN** the selected Tokens reach Parser/Sema without generated AS text

    > Observables: no synthesized `struct FOnDone { _FScriptDelegate _Inner; ... }` and no C-macro expansion of `DECLARE_*`.

    > Boundaries: Include expansion and text replacement macros remain unsupported; source backquery retains both active and inactive conditional regions.

- **BUT** `DetectClasses` / `ProcessDelegates` SHALL NOT collect leftover `delegate` / `event` text as wrapper-generation work

    > Boundaries: declaration semantics belong to Parser/Sema. Newlines increment the preprocessor line counter and do not split a Global chunk, so a multi-line `DECLARE_*` argument list stays one token stream for Parser.
