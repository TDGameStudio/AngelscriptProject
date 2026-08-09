# Wiki Annotated Code Task 2 Report

## Status

`PASS` for the Task 2 content, source-contract, Showcase discovery, author-reference, and document-domain browser scope owned by this agent.

The parent agent explicitly assigned `Wiki/src/angelscript-tools/readme.tid` and the `plugin.info` `0.4.0` bump to the concurrent core-component agent, so this agent did not edit any path under `Wiki/src/angelscript-tools`. Before the final Task 2 verification, both cross-agent items were present in the shared working tree: `plugin.info` reported `0.4.0`, and the README documented `$angelscript-code`, `$annotated-code`, and direct-child `$code-note` authoring.

No worktree was created. No OpenSpec file, numbered experiment HTML file, generated file, unrelated dirty file, or core-component path was edited. Nothing was committed or pushed.

## Changed files

### Contract and document-domain browser tests

- `Wiki/scripts/document-content-contract.test.mjs`
  - Preserves the existing user-owned `96` formal Chinese document assertion.
  - Adds P02–P04 reader-page uniqueness, stable-title, tier/tag, purpose, catalog mapping, and source-snapshot checks.
  - Preserves the current-worktree slice comparison as a drift check.
  - Uses `git -C <repository> show <revision>:<path>` to compare every snapshot body verbatim with the pinned revision's exact inclusive line slice.
  - Resolves host AngelScript examples in the parent repository and converts the C++ header to its `Plugins/Angelscript` submodule-relative repository path.
  - Extends the existing expected Showcase page mapping without changing Base expectations.
- `Wiki/tests/playwright/product/document/document-content-foundation.spec.ts`
  - Requires 16 Pattern entries and exactly 3 mapped entries.
  - Verifies all three mapped links and opens each target page.
  - Verifies headings, language labels, block-scoped provenance text, annotated block counts, resolved-note counts, and absence of missing links.
  - For P04, independently binds the AngelScript block to the host path/revision and the C++ block to the plugin path/revision; each block also rejects the other block's provenance.
  - Verifies P04 renders AngelScript before C++, contains no comparison-grid/two-column container, and states the non-equivalence boundary.

### Reader-support source snapshots

- `Wiki/wiki/tiddlers/showcase/sources/P02-MovingObjectTick.tid`
- `Wiki/wiki/tiddlers/showcase/sources/P03-EnhancedInputBinding.tid`
- `Wiki/wiki/tiddlers/showcase/sources/P04-SessionTracker.tid`
- `Wiki/wiki/tiddlers/showcase/sources/P04-ScriptGameInstanceSubsystem.tid`

### Reader-facing Pattern pages

- `Wiki/wiki/tiddlers/showcase/pattern/P02-LineExplanation.tid`
- `Wiki/wiki/tiddlers/showcase/pattern/P03-KeyPathAnnotations.tid`
- `Wiki/wiki/tiddlers/showcase/pattern/P04-AngelScriptCppBridge.tid`

### Catalog, discovery, and author guidance

- `Wiki/wiki/tiddlers/showcase/ShowcaseCatalog.tid`
  - Changes only P02, P03, and P04 from `gap` to `mapped`.
  - Adds their exact stable `page-title` values and updates coverage wording.
  - Retains all existing purpose and planned-verification text.
- `Wiki/wiki/tiddlers/showcase/PatternIndex.tid`
  - Uses the same `mapped`-only link behavior as Base while retaining all 16 rows.
- `Wiki/wiki/tiddlers/examples/AngelscriptCodeShowcase.tid`
  - Appends one compact `Annotated source` author example.
  - Keeps source in the parent `code` attribute and supplies exactly two direct child `<$code-note>` definitions.
  - Preserves all pre-existing sections and examples.
- `Wiki/Agents.md`
  - Documents the `$codeblock` / `$angelscript-code` / `$annotated-code` author boundary, direct-child note contract, `code`-attribute source ownership, and invalid/unmatched-note fallback.

### Report

- `.superpowers/sdd/wiki-annotated-code-task-2-report.md`

## RED evidence

Tests were changed before any production tiddler, catalog, navigation, or author-document content.

### Source/content contract RED

Command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 --call "pnpm run test:document-content"
```

Exact result:

```text
tests 48
pass 46
fail 2
Exit code: 1
```

Expected failures:

```text
repository maps the three annotated Pattern pages to exact source snapshots
P02 must identify one reader page
0 !== 1

repository maps existing Showcase pages and keeps hidden fixtures private
AS/Showcase/Pattern/P02-LineExplanation
```

All pre-existing contract assertions, including the 42-entry catalog, Lab state, source registry, and repository-wide content contract, remained green in this RED run.

### Browser command compatibility finding

The command copied verbatim from the brief was run:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 --call "pnpm run test:feature -- document --grep Showcase"
```

Current `scripts/run-product-tests.mjs` treats the first `--` as the first option and therefore receives no valid domain. Exact result:

```text
Specify at least one product test domain: shell, sidebar, document, code, tools, i18n
Exit code: 1
```

The current-runner equivalent was then used:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 --call "pnpm run test:feature document --grep Showcase"
```

Exact RED result:

```text
Running 6 tests using 1 worker
5 passed
1 failed
Exit code: 1
```

Expected failure:

```text
Pattern mapped entries
Expected: 3
Received: 0
```

### Independent provenance-review RED

The independent review identified two blind spots in the first green implementation:

- snapshot bodies were compared only with the current worktree while the revision fields were asserted as literal metadata;
- the P04 browser case searched for one path and one revision as loose whole-page substrings, so it did not prove that each revision belonged to the correct code block.

The pinned-source helper was first introduced as an explicit throwing test stub. The source/content command then produced the intended single RED:

```text
tests 48
pass 47
fail 1
repository maps the three annotated Pattern pages to exact source snapshots
Error: pinned revision source loading is not implemented
Exit code: 1
```

After implementing `git show`, the first browser-scoping attempt deliberately required provenance to be a direct sibling of the annotated block. The Showcase command produced:

```text
Running 8 tests using 1 worker
7 passed
1 failed
Expected provenance count: 4
Received: 0
Exit code: 1
```

The rendered DOM showed that the annotated block is inside a paragraph wrapper and the labeled provenance paragraphs are preceding siblings of that wrapper. The final locator therefore selects the nearest preceding `源码：` and `固定修订：` paragraphs for each individual wrapper.

## GREEN evidence

### Source/content contract GREEN

Command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 --call "pnpm run test:document-content"
```

Exact result:

```text
tests 48
pass 48
fail 0
cancelled 0
skipped 0
todo 0
Exit code: 0
```

This run includes:

- the unchanged `96` formal Chinese document count;
- exactly 42 ordered Showcase IDs;
- all Lab rows still `experiment`;
- unique P02–P04 Pattern pages with matching tier tags;
- P02–P04 `mapped` rows with exact page titles;
- exact source-snapshot body comparisons against both the current worktree slices and the pinned `git show` slices;
- existing Base/B07 mapping assertions;
- the repository-wide documentation content contract.

### Showcase document-domain browser GREEN

Command compatible with the current runner:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 --call "pnpm run test:feature document --grep Showcase"
```

Exact result:

```text
Running 8 tests using 1 worker
8 passed
Exit code: 0
```

This was a fresh final run after the concurrent core-component changes and their Playwright sequence had completed. It therefore exercises the final shared widget implementation together with the Task 2 reader pages and corrected per-block provenance assertions.

The selected tests include:

- Showcase tier discovery, Base 15/7 baseline, B07, Pattern 16/3 mapping, all three link destinations, and Lab 11/experiment behavior;
- all three annotated Pattern pages with block-scoped provenance, language labels, annotated blocks, resolved note counts, and no missing links;
- independent P04 AngelScript host-path/host-revision and C++ plugin-path/plugin-revision assertions, including rejection of the other block's path and revision in each provenance scope;
- P04 single-column AS-before-C++ ordering and absence of comparison-grid/two-column containers;
- all five existing syntax Showcase browser tests.

The npm wrapper emitted only its pre-existing warnings about future handling of `strict-peer-dependencies` and `public-hoist-pattern`; tests themselves had zero failures.

## Source snapshot comparison evidence

The automated contract test compares every snapshot body twice after LF normalization and inclusion of the final selected line ending:

1. against the current host/plugin source slice, preserving the existing drift check;
2. against `git -C <repository> show <revision>:<repository-relative-path>`, proving the body at the declared pinned revision.

The three AngelScript snapshots use the parent repository. The C++ snapshot invokes Git in `Plugins/Angelscript` and removes the parent checkout's `Plugins/Angelscript/` prefix from the repository path.

| Snapshot | Inclusive lines | Current logical SHA-256 | Pinned logical SHA-256 | Equal |
|---|---:|---|---|---|
| `P02-MovingObjectTick` | 52–72 | `fe3e4f08a76e8d81dc80e45e84eaed869788e80963a17a0715d3aee855b5b635` | `fe3e4f08a76e8d81dc80e45e84eaed869788e80963a17a0715d3aee855b5b635` | `true` |
| `P03-EnhancedInputBinding` | 20–56 | `0ad53de52b606076d36d5c4a158fbe442e2b0c586096af9b5c7a910f4793adbf` | `0ad53de52b606076d36d5c4a158fbe442e2b0c586096af9b5c7a910f4793adbf` | `true` |
| `P04-SessionTracker` | 78–102 | `77ed980a7edc188bd12941de3f2f06a4c006b977384438fb5e1c48c7971272ef` | `77ed980a7edc188bd12941de3f2f06a4c006b977384438fb5e1c48c7971272ef` | `true` |
| `P04-ScriptGameInstanceSubsystem` | 17–56 | `8de05c822f0b41fb4ec21e11fba187584a996c5c0dbcece6107c2499f040655c` | `8de05c822f0b41fb4ec21e11fba187584a996c5c0dbcece6107c2499f040655c` | `true` |

Pinned revisions:

- Host examples: `c99d47b50726bcea3f3713317d513ed27613f744`
- Angelscript plugin header: `dc99986febf1f0911a3ebfdc6d987cc3c0594907`

## Self-review

- P02 has the requested six notes at line 55, line 56, line 58, lines 60–61, lines 67–68, and line 71. Its prose explicitly says `OriginalPosition` is mutable running position state, not an immutable spawn origin.
- P03 has the requested seven notes at lines 23, 27, 33, 34, 35, 42, and 47. It states the exact owner → component → delegate target → trigger semantics → payload pipeline and explicitly says this snippet does not install `DefaultMappingContext`.
- P04 has four AS notes and four C++ notes over the exact requested ranges. Prose appears between the two blocks, defines distinct ownership, and denies textual/one-to-one equivalence.
- P04 browser coverage scopes provenance to each annotated block's nearest labeled source and revision paragraphs. It cannot pass by finding the host and plugin revisions elsewhere on the page.
- All three pages use official TW5 WikiText/widget syntax; no Markdown-only headings, bold syntax, lists, or fenced code were introduced into the `.tid` bodies.
- Source remains in the parent widget `code` attribute. Every annotation is a direct `<$code-note>` child.
- Pattern discovery is copied from the Base mapped-link shape, not a separate navigation behavior.
- Catalog ordering and row count are unchanged; only P02–P04 state/page-title/coverage fields changed.
- B01–B07 mappings were not edited.
- No two-column wrapper, comparison grid, custom runtime dependency, or new page CSS was added.
- Existing unrelated dirty changes, including the user-owned `90 → 96` document count update and language/start document batch, were preserved.

## Concerns and handoff

1. The brief's exact browser command contains a separator form incompatible with the current feature runner. The equivalent command without the first `--` is green and is the command that actually executes the requested document-domain Showcase coverage.
2. The concurrent plugin README author-contract documentation and `0.3.1 → 0.4.0` minor-version bump were present before the final Showcase `8/8` run. This agent verified their presence but intentionally did not modify or reconcile those core-owned paths.
