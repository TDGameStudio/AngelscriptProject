## ADDED Requirements

### Requirement: Plugin source SHALL NOT use UE++ fork fences

`Plugins/Angelscript` C++ 源码 SHALL NOT contain `[UE++]` or `[UE--]` fork-fence tokens. Explanatory comments that previously followed `//[UE++]:` MAY remain as ordinary comments. New edits to the maintained kernel or plugin source MUST NOT introduce these tokens.

#### Scenario: Existing fence comments are retired

- **WHEN** a maintainer searches `Plugins/Angelscript/Source` C++ headers and sources for `[UE++]` or `[UE--]`
- **THEN** the search SHALL return no matches

#### Scenario: New kernel edits do not reintroduce fences

- **WHEN** a maintainer changes `ThirdParty/angelscript` or other plugin C++ source
- **THEN** the change MUST NOT add `[UE++]` or `[UE--]` tokens
- **AND** any rationale MAY be written as a normal comment without those tokens

### Requirement: Living policy docs SHALL NOT require UE++ fences

Current strategy and knowledge documents that still prescribe adding `[UE++]` / `[UE--]` SHALL be updated so they no longer require or teach those tokens. Historical plans and previously recorded OpenSpec changes are out of scope.

#### Scenario: Fork strategy no longer mandates fences

- **WHEN** a reader follows `Documents/Guides/AngelscriptForkStrategy.md` for a ThirdParty edit
- **THEN** the guide MUST NOT require a `[UE++]` comment
- **AND** it MAY still require cherry-pick review and tests
