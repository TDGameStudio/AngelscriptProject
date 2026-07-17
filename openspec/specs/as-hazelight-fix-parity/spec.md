# as-hazelight-fix-parity Specification

## Purpose
TBD - created by archiving change improve-hazelight-fix-parity. Update Purpose after archive.
## Requirements
### Requirement: Complete path-scoped audit range

The audit helper SHALL support a complete-range mode that enumerates all commits affecting configured Angelscript-related paths after a supplied base marker and before the selected head.

#### Scenario: Complete core plugin range

- **WHEN** the helper runs with `472bb2fab5a0` as base and `138a7e186082` as head for `Engine/Plugins/Angelscript`
- **THEN** it reports all 34 core plugin commits after the base marker, including commits older than the recent preview window

#### Scenario: Repository compare limit is avoided

- **WHEN** the repository contains more than 10,000 commits between the repository root and the audit head
- **THEN** complete-range mode uses paginated path history and does not depend on the repository-wide compare response

### Requirement: Stable upstream inventory

The change record SHALL preserve each reviewed upstream commit's full SHA, title, author, affected path group, local mapping, classification, and next action.

#### Scenario: Deferred change remains visible

- **WHEN** an upstream change is not safe to merge into the standalone plugin
- **THEN** the inventory records it as deferred, reference-only, already absorbed, or out of scope with a concrete reason

#### Scenario: Duplicate path result

- **WHEN** one commit affects multiple configured audit paths
- **THEN** the inventory contains one entry for that full SHA and retains all relevant path classifications

### Requirement: Low-risk binding parity

The plugin SHALL adopt the five selected low-risk Hazelight fixes without changing unrelated runtime behavior.

#### Scenario: TrimQuotes output flag

- **WHEN** a script calls `FString.TrimQuotes(bool& OutQuotesRemoved)`
- **THEN** the binding forwards the reference output flag correctly in supported non-JIT and StaticJIT build paths

#### Scenario: UObjectTickable destruction

- **WHEN** a script-callable `UObjectTickable` is destroyed
- **THEN** its tick type becomes `ETickableTickType::Never` before it is marked garbage

#### Scenario: Widget determined output type

- **WHEN** `WidgetBlueprint::CreateWidget` is inspected or compiled with a concrete `WidgetType`
- **THEN** its reflected signature identifies `WidgetType` as the determined output type

#### Scenario: Latent constructor registration

- **WHEN** `FLatentActionInfo` bindings are registered
- **THEN** the explicit constructor remains available without an incorrect trivial native constructor registration

#### Scenario: EnhancedInput handle nativization

- **WHEN** `FEnhancedInputActionEventBinding::GetHandle()` is inspected for a native form
- **THEN** the method is excluded from trivial StaticJIT nativization

### Requirement: Checkpoint integrity

The audit checkpoint SHALL be updated only after the complete range is reviewed and verification evidence is available.

#### Scenario: Reviewed head is recorded

- **WHEN** the full range and first implementation batch have been reviewed and verified
- **THEN** `audit-state.json` records the reviewed head, base range, author summary, and UE-follow signals

#### Scenario: Preview does not advance checkpoint

- **WHEN** the helper runs only in recent-window preview mode
- **THEN** it does not advance `lastReviewedHeadSha`
