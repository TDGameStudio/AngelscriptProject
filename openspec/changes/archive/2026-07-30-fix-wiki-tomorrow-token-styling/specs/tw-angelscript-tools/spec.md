## ADDED Requirements

### Requirement: Tomorrow Light preserves semantic color without incidental bold text

The shared AngelScript highlighting pipeline SHALL follow the reference Wiki's classic Tomorrow Light semantic roles. UE reflection macros SHALL render cyan, preprocessor directives brown, class declaration titles yellow, function titles blue, keywords and types purple, numbers/attributes/symbols orange, strings green, comments muted gray, and operators plus format-string substitutions in the base foreground. Normal semantic source tokens SHALL use the code surface's regular weight; only content explicitly classified as `strong` MAY be bold.

#### Scenario: Reader views representative Unreal AngelScript

- **WHEN** a reader opens an AngelScript example containing reflection macros, a class declaration, a lifecycle function, control flow, types, strings, numbers, operators, format substitutions, a preprocessor branch, a symbol, and a comment
- **THEN** the rendered `hljs-*` scopes SHALL expose the reference Tomorrow Light color roles
- **AND** keywords, class titles, function titles, types, and built-ins SHALL compute to regular font weight
- **AND** the code surface SHALL continue to use the bundled Fira Code variable font

#### Scenario: Call-shaped control flow is highlighted

- **WHEN** AngelScript source contains `if (...)`, `for (...)`, `while (...)`, `switch (...)`, or `catch (...)`
- **THEN** the control-flow word SHALL use the `keyword` scope
- **AND** it SHALL NOT use the `title.function` scope

#### Scenario: UE macro and preprocessor roles differ

- **WHEN** source contains `UCLASS`, `UPROPERTY`, or `UFUNCTION` and also contains `#if` or `#endif`
- **THEN** the UE macro name SHALL use the cyan `built_in` role
- **AND** the preprocessor directive SHALL use the brown `meta` role
