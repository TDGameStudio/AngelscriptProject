# Task 2 — TDD production Showcase content and author documentation

## Context

Task 1 will have added `<$annotated-code>`, enhanced `<$angelscript-code>`, and direct child `<$code-note>` support in the `Wiki/src/angelscript-tools` plugin. Build three reader-facing Pattern Showcase pages using those public interfaces, make them discoverable, and document the author contract.

Work in `D:/Workspace/AngelscriptProject`. Read and obey `AGENTS.md` and `Wiki/Agents.md`. Preserve all unrelated dirty work, especially the existing `90 → 96` edit in `Wiki/scripts/document-content-contract.test.mjs` and the current language/start document batch. Do not create a worktree, commit, push, reset, run a formatter, or edit the numbered OpenSpec experiment HTML files.

Use `superpowers:test-driven-development`: update the content/source contract and document-domain Playwright expectations first, run the focused tests and observe the expected missing-page/mapping failure, then add content/navigation and rerun green. Record RED/GREEN evidence in the report.

Use official TW5 syntax and the now-implemented child widget syntax. Do not use Markdown-only syntax inside `.tid` WikiText.

## Source snapshots

Create four reader-support source snapshot tiddlers under `Wiki/wiki/tiddlers/showcase/sources/`. Each must carry:

- a stable `AS/Showcase/Source/...` title
- an appropriate type (`text/x-angelscript` for AS; `text/plain` for C++)
- `as-source-path`
- `as-source-revision`
- `as-source-start-line`
- body copied byte-for-byte in logical text from the clean source slice, preserving tabs and blank lines

Snapshots:

1. `P02-MovingObjectTick`
   - source: `Script/Examples/Core/Example_MovingObject.as`
   - parent revision: `c99d47b50726bcea3f3713317d513ed27613f744`
   - inclusive source lines `52–72`
   - displayed `startLine="52"`

2. `P03-EnhancedInputBinding`
   - source: `Script/Examples/EnhancedInput/Example_EI_PlayerController.as`
   - parent revision: `c99d47b50726bcea3f3713317d513ed27613f744`
   - inclusive source lines `20–56`
   - displayed `startLine="20"`

3. `P04-SessionTracker`
   - source: `Script/Examples/Extended/Example_SubsystemLifecycle.as`
   - parent revision: `c99d47b50726bcea3f3713317d513ed27613f744`
   - inclusive source lines `78–102`
   - displayed `startLine="78"`

4. `P04-ScriptGameInstanceSubsystem`
   - source: `Plugins/Angelscript/Source/AngelscriptRuntime/Subsystem/ScriptGameInstanceSubsystem.h`
   - plugin revision: `dc99986febf1f0911a3ebfdc6d987cc3c0594907`
   - inclusive source lines `17–56`
   - displayed `startLine="17"`

Tests must compare snapshot bodies to the exact slices from the host/plugin source, not only hard-coded prose.

## Reader pages

Create the pages under `Wiki/wiki/tiddlers/showcase/pattern/` with:

- `type: text/vnd.tiddlywiki`
- `tags: [[ASWiki/Docs/showcase-lab]] [[ASWiki/Showcase/Pattern]]`
- caption and description
- `as-doc-kind: showcase`
- unique `as-showcase-id`
- `as-showcase-tier: Pattern`
- non-empty `as-showcase-purpose`

### P02 — 源码逐行解释：Actor 移动状态

Stable title: `AS/Showcase/Pattern/P02-LineExplanation`

Use `<$angelscript-code>` with the P02 snapshot and `startLine="52"`. Add concise notes for:

- line 55, `FVector NewLocation = OriginalPosition;` — establish the candidate state from the previous frame
- line 56, `if (bHeadingBack)` — direction chooses the sign of this frame’s displacement
- line 58, `DeltaSeconds * MovementPerSecond` — frame-rate-independent displacement
- lines 60–61 — crossing the left boundary flips the next-frame direction
- lines 67–68 — crossing the right boundary flips the next-frame direction
- line 71, `OriginalPosition = NewLocation;` — commit the calculated state once

The prose must explain that the example mutates `OriginalPosition` as its running position despite the name; do not falsely describe it as an immutable spawn origin.

### P03 — 源码关键路径：Enhanced Input 绑定

Stable title: `AS/Showcase/Pattern/P03-KeyPathAnnotations`

Use `<$angelscript-code>` with P03 and `startLine="20"`. Add notes for:

- line 23 `GetPawn()`
- line 27 `Cast<UEnhancedInputComponent>`
- line 33 dynamic signature creation
- line 34 `BindUFunction`
- line 35 `ETriggerEvent::Triggered`
- line 42 `ETriggerEvent::Started`
- line 47 callback signature / input payload

Explain the pipeline as “find owner → establish component boundary → bind delegate target → choose trigger semantics → receive payload”. Do not claim that the unused `DefaultMappingContext` is installed by this snippet.

### P04 — AngelScript 与 C++：Subsystem 生命周期桥接

Stable title: `AS/Showcase/Pattern/P04-AngelScriptCppBridge`

Keep a single reading column: explanatory prose, then the AS block, then more prose, then the C++ block. Do not use a two-column comparison.

AS notes:

- line 79 script derives from `UScriptGameInstanceSubsystem`
- lines 84–85 script-facing `Initialize` override
- line 87 state update
- lines 91–94 `Deinitialize` override

C++ notes:

- lines 17–26 creation guards and the script-overridable final decision
- lines 29–37 current-engine/owner-script-engine compatibility
- lines 40–46 Unreal lifecycle first, then guarded script bridge
- lines 49–56 guarded script deinit before superclass teardown and local state reset

State explicitly that the two listings are not textual or one-to-one equivalents: AS supplies gameplay lifecycle behavior while the C++ wrapper owns Unreal lifecycle and current-VM safety before bridging to script events.

## Catalog and discovery

- Change P02, P03, and P04 rows in `AS/Showcase/Data/Catalog` from `gap` to `mapped`.
- Add exact `page-title` values matching the stable page titles above.
- Update coverage to describe the implemented reader pages; keep the existing purpose and planned-verification intent unless a small wording correction is needed.
- Update `AS/Showcase/Pattern` to use the same mapped-entry link behavior as Base while preserving all 16 rows.
- Keep the root inventory exactly 42 entries and all Lab rows `experiment`.
- Keep all B01–B07 mappings unchanged.

## Existing author reference and plugin docs

- Preserve every current section and example in `AngelscriptCodeExamples`.
- Append one compact “Annotated source” author example using `<$angelscript-code>` with two direct child `<$code-note>` widgets; do not duplicate a full Pattern page.
- Update the plugin readme with:
  - ordinary `<$codeblock>`
  - line-control `<$angelscript-code>`
  - annotated AS `<$angelscript-code> ... <$code-note> ...`
  - generic C++ `<$annotated-code language="cpp">`
  - full attribute tables and invalid-note fallback behavior
  - source remains the `code` attribute; body is note definitions, not source
- Update `Wiki/Agents.md` configuration-placement guidance so future agents know the new author boundary.
- Bump the internal Angelscript Tools plugin minor version from `0.3.1` to `0.4.0`.

## Required tests

Update tests before content:

1. Source/content contract recognizes P02–P04 as unique Pattern pages and verifies tier-tag agreement.
2. Repository Showcase expected-page mapping includes the three new pages without changing the existing user `96` formal-document count.
3. Catalog remains 42 ordered IDs; P02–P04 are mapped with matching page titles.
4. Pattern directory renders 16 entries, exactly three mapped entries, and each mapped link opens the right page.
5. Each page renders expected headings, language labels, source path/revision, and annotated code blocks without missing links.
6. P04 renders AS before C++ and has no comparison grid/two-column container.
7. Snapshot bodies equal the selected host/plugin source ranges.
8. Existing Base/B07 assertions remain green.

Use:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 --call "pnpm run test:document-content"
npm exec --yes --package=node@24 --package=pnpm@11.8.0 --call "pnpm run test:feature -- document --grep Showcase"
```

Do not edit OpenSpec in this task.

## Deliverable and report

Write:

`D:/Workspace/AngelscriptProject/.superpowers/sdd/wiki-annotated-code-task-2-report.md`

Include status, changed files, RED/GREEN commands with exact results, source-snapshot comparison evidence, self-review, and concerns. Do not commit or push. Return only the short status summary.
