## MODIFIED Requirements

### Requirement: Dedicated annotation and callable declaration keywords

The Lexer SHALL classify UCLASS, USTRUCT, UENUM, UFUNCTION, UPROPERTY and UMETA as dedicated keyword Tokens. The Lexer SHALL classify `delegate` and `event` as dedicated Tokens solely so the Parser can reject them as removed callable introducers. Those two Tokens are a transitional reject surface for this Change; deleting `KwDelegate` / `KwEvent` from the identifier table belongs to a later Change.

    Script callable types are declared with the UE `DECLARE_*` identifier spellings owned by the declarations capability. Those spellings are not additional lexer keywords.

#### Scenario: Lex a marked declaration

- **WHEN** active language source spells one of the supported outer annotation keywords

    > Inputs: `UCLASS`, `USTRUCT`, `UENUM`, `UFUNCTION`, `UPROPERTY`, `UMETA`.

- **THEN** the Token carries its dedicated kind and original source range

    > Observables: token kind and source range.

- **AND** nested annotation arguments remain ordinary structured payload Tokens

- **BUT** UDELEGATE is not implicitly added as a declaration form, and `DECLARE_*` spellings remain identifier Tokens

    > Boundaries: `DECLARE_DELEGATE` and the other five supported families are parsed as declaration-form identifiers, not lexer keywords.

#### Scenario: Lex removed callable introducers

- **WHEN** active language source spells `delegate` or `event` as a declaration introducer

    > Inputs: `delegate void FOnDone();` or `event void FOnChanged();`

- **THEN** the Token carries a dedicated kind and original source range so Parser can emit the removed-syntax diagnostic

    > Observables: dedicated token kind, source range, later `removed-delegate-event-keyword` diagnostic.

- **BUT** the Token does not admit a callable type

    > Boundaries: identifier uses inside strings or comments are not this scenario. Removing the dedicated Token kinds so `delegate` / `event` become ordinary identifiers is out of this Change.
