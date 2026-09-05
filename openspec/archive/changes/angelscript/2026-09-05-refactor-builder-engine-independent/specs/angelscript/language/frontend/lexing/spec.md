## ADDED Requirements

### Requirement: Dedicated annotation and callable declaration keywords
The Lexer SHALL classify UCLASS, USTRUCT, UENUM, UFUNCTION, UPROPERTY, UMETA, delegate and event as dedicated keyword Tokens.

#### Scenario: Lex a marked declaration
- **WHEN** active language source spells one of the supported outer keywords
- **THEN** the Token carries its dedicated kind and original source range
- **AND** nested annotation arguments remain ordinary structured payload Tokens
- **BUT** UDELEGATE is not implicitly added as an equivalent delegate declaration form

