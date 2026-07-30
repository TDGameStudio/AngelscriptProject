# Showcase Gap Matrix

Captured: 2026-07-25

The current Wiki has useful syntax demonstrations, but it does not yet have a complete authoring-pattern system. This matrix turns the requested “more Showcase content” into a bounded catalog with three stability levels:

- **Base** is a stable rendering and interaction baseline.
- **Pattern** is a reusable way to compose real technical documentation.
- **Lab** is an explicitly experimental presentation or investigation surface.

The catalog has 42 entries: 15 Base, 16 Pattern, and 11 Lab. An entry is not the same as a required tiddler. The foundation implementation creates three tier indexes and this catalog in the Wiki, maps existing pages, and creates an individual page only when the example and its acceptance behavior are ready. The six entries added after the initial audit cover native TiddlyWiki procedures/functions/macros, trusted HTML, embedded pages, reusable WikiText components, static embed fallbacks, and embed-security experiments; their detailed contract is in `tiddlywiki-expression-showcase.md`.

## Existing coverage and classification

| Current source | Current role | Foundation disposition | Main catalog coverage |
|---|---|---|---|
| `wiki/tiddlers/examples/SyntaxShowcaseIndex.tid` | Reader-facing index for four syntax pages | Adapt into the Showcase root or a compatibility entry; retain its current title until the new links exist | Base directory |
| `wiki/tiddlers/examples/MarkdownBasicShowcase.tid` | Reader-facing rendered Markdown baseline | Classify as Base; extend only where the missing surface belongs naturally | B01, partial B07, B09, B10 |
| `wiki/tiddlers/examples/MarkdownExtendedShowcase.tid` | Reader-facing extended Markdown baseline | Classify as Base | B02, partial B09 |
| `wiki/tiddlers/examples/MarkdownMoreShowcase.tid` | Reader-facing Markdown More baseline | Classify as Base | B03 |
| `wiki/tiddlers/examples/WikiTextSyntaxShowcase.tid` | Reader-facing WikiText, filters, procedure, and temporary-state baseline | Classify as Base; preserve the transcluded fragment | B04, B05, B06 |
| `wiki/tiddlers/examples/WikiTextShowcaseTransclusion.tid` | Supporting transclusion fragment | Keep as a supporting fixture; do not make it a second directory entry | B05 |
| `wiki/tiddlers/tests/playwright/AngelscriptCodeExamples.tid` and its `$:/tests/.../Code/*` sources | Browser-test target that currently carries reader-oriented explanatory text | Split its roles: keep hidden regression fixtures under `$:/tests/...`; create or map a reader-facing Base page only after source ownership is explicit | B07, B08 and several future Patterns |
| `tests/playwright/product/document-experience.spec.ts` | Product browser regression | Extend focused coverage rather than adding a second overlapping suite for existing surfaces | Base/Pattern verification |

The current top-level count of five reader-facing Showcase pages is therefore not a target count. It is only the starting coverage. Hidden test targets and transclusion fragments must not be counted as reader pages.

## Base: stable rendering and interaction surfaces

| ID | Surface group | Documentation purpose | Current coverage | Gap before graduation/extension | Planned verification |
|---|---|---|---|---|---|
| B01 | Markdown basic | Check headings, prose, emphasis, links, quotes, lists, code, tables, and separators | Strong: `MarkdownBasicShowcase.tid` | Confirm anchors, copy boundary, and narrow overflow are intentional | Render, semantic selectors, links, table/code containment |
| B02 | Markdown extended | Check footnotes, definitions, insertion, mark, sub/superscript, abbreviations, reference links, and embedded HTML | Strong: `MarkdownExtendedShowcase.tid` | Add an explicit unsupported/escaped case only if the locked parser needs it | Render and representative semantic elements |
| B03 | Markdown More | Check checklist, admonition, nesting, example block, and heading-derived contents behavior | Strong: `MarkdownMoreShowcase.tid` | Keep product defaults and plugin upgrade boundaries visible | Render, details state, checklist initial state, containment |
| B04 | WikiText formatting, links, and tables | Check native TW5 prose, internal/external links, lists, quotes, tables, and code blocks | Strong: `WikiTextSyntaxShowcase.tid` | Separate core syntax from dynamic behavior in the page outline | Render and link behavior |
| B05 | Transclusion, filter, and procedure | Check transcluded content, filtered lists, local procedures, and dynamic links | Partial: WikiText page plus fragment | Add empty-result and dynamic-target cases without relying on Markdown link interpolation | Deterministic list/transclusion output |
| B06 | Widgets and temporary state | Check buttons, reveal state, variables, and non-persistent interaction feedback | Partial: WikiText page | Add keyboard operation and reset/isolation behavior | Keyboard activation, ARIA/state, no durable source write |
| B07 | AngelScript highlighting and line controls | Check official highlighting, source slicing, line numbers, displayed starts, highlights, scrolling, and copying | Strong but hidden/mixed-role: `AngelscriptCodeExamples.tid` | Separate reader reference from `$:/tests` targets; state invalid-range behavior | Highlight tokens, gutter, viewport, copy result, invalid input |
| B08 | Multilingual and long-line code | Check Chinese/English prose around AS/C++/text, Unicode, tabs, and long-line horizontal containment | Partial | Add deliberate Unicode identifiers/comments, mixed prose, and very long source lines | No clipping/page overflow; copy preserves source |
| B09 | Images, SVG, media, and file links | Check raster/SVG sizing, captions/alt text, external media, offline behavior, and explicit local-file links | Partial image coverage | Add SVG, broken/unavailable media, captions, and safe file-link examples; no unlicensed Hazelight media | Alt/name checks, containment, offline-safe baseline |
| B10 | Long prose, wide tables, and overflow | Check realistic long Chinese paragraphs, nested sections, wide tables, long tokens, and zoom | Partial | Add a deliberately wide technical table and unbroken identifiers | Desktop/narrow/zoom containment |
| B11 | Chinese-English mixed text and search | Check typography, punctuation, search indexing, localized caption, and Chinese fallback discoverability | Minimal | Add paired search terms, mixed titles, and deterministic result expectations | Search results, title/caption display, locale-aware link |
| B12 | Keyboard, narrow screen, print, and reduced motion | Check cross-cutting document accessibility and alternate presentation modes | Scattered product tests | Add one focused baseline that exercises navigation, focus, print layout, 200% zoom, and reduced motion | Keyboard flow, focus visibility, mobile viewport, print CSS, reduced-motion media |
| B13 | TiddlyWiki variables, procedures, functions, and legacy macros | Check parameters/defaults/quoting/scopes, nested calls, filter functions, transclusion invocation, and compatibility syntax | Minimal: one procedure in the WikiText page plus product-owned navigation procedures/functions | Add focused current-syntax examples, edge cases, and an explicitly labelled legacy `\define` case | Deterministic output, scoping, empty/default/quoted parameters, no persistent write |
| B14 | Trusted WikiText HTML and widget composition | Check semantic HTML, attributes/ARIA, widgets inside HTML, procedure output, escaping, and forbidden executable forms | Partial: product tiddlers use HTML and widgets, but no author-facing baseline | Add semantic live examples plus escaped `<script>`/event-handler anti-examples | Semantic DOM, keyboard, containment, print, no script/handler execution |
| B15 | Embedded local and external web content | Check a packaged/local iframe, optional external iframe, sandbox/referrer/title/loading, fallback, offline, denied-frame, and responsive behavior | None | Add a deterministic local fixture and an optional external/failure example without third-party test dependence | Local load, fallback, attributes, no unexpected network, narrow/offline behavior |

Base pages are stable review targets, not claims that every browser emits pixel-identical output. Tests should assert agreed document behavior, accessibility, and containment with resilient semantic selectors.

## Pattern: reusable technical-document compositions

| ID | Composition group | Intended authoring use | Current coverage | Required content before an individual page exists |
|---|---|---|---|---|
| P01 | Minimal runnable example | Smallest complete `.as` example with prerequisites, file placement, expected result, and verification | Scattered examples | One current, tested Actor example and a copy boundary |
| P02 | Code with line-by-line explanation | Explain every significant statement without breaking code readability | No canonical pattern | Stable numbered explanation linked to displayed lines and a narrow-screen order |
| P03 | Code with key-path annotations | Call out only important branches/lines in longer source | AS line highlighting exists | Author contract for ranges, notes, and accessible fallback |
| P04 | AngelScript/C++ comparison | Compare syntax, ownership, defaults, or APIs without implying semantic identity | No canonical pattern | Labeled columns/sections, source provenance, mobile stacking, “different behavior” notes |
| P05 | AngelScript/Blueprint mapping | Map script declarations and flow to Blueprint concepts | No canonical pattern | Semantic labels, Blueprint terminology, textual fallback for images/graphs |
| P06 | API signature and parameter table | Document callable shape, inputs/outputs, metadata, constraints, and examples | Generic tables only | Field contract and one current bound API example |
| P07 | Lifecycle timeline | Explain ordered events such as engine/subsystem or Actor lifecycle | No canonical pattern | Text-first ordered sequence, ownership, re-entry/skip conditions |
| P08 | State transition | Explain compiler/module/reload/test states and legal transitions | No canonical pattern | States, triggers, guards, failures, and text/table fallback |
| P09 | Call sequence | Explain calls across AS, runtime, editor, Unreal, or debug adapter boundaries | No canonical pattern | Participants, sync/async meaning, alternate/failure branches |
| P10 | Compilation/binding/execution data flow | Explain transformations and artifacts from source to runtime | No canonical pattern | Inputs/outputs, ownership, fallback paths, source/test links |
| P11 | Module architecture and dependencies | Explain UE modules, optional plugins, load phases, and source ownership | Prose/module graph outside Wiki | Machine-readable or text-first nodes/edges plus dependency semantics |
| P12 | Decision tree and limitation list | Help readers choose reload type, binding path, test layer, or recovery action | Prose only | Explicit decision inputs, outcome links, version/boundary notes |
| P13 | Version, source, and test evidence | Show which fork/version a claim applies to and how it was verified | SDK metadata exists | Standard evidence panel using stable source keys and revision fields |
| P14 | Placeholder, draft, and migration state | Present planned/unreviewed content honestly and link its inputs | No canonical pattern | Required placeholder sections, visible status, exclusion from completion counts |
| P15 | Parameterized WikiText documentation component | Reuse a procedure/function/transclusion composition for evidence panels, API notes, source links, or comparisons | Product code has internal procedures; no author-facing contract | Purpose, parameter/default/escaping/nesting table, empty/error state, accessible markup, call examples, source tests |
| P16 | Embedded interactive companion with static fallback | Attach a packaged mini-page, diagram, or allowed external tool without making it authoritative | No canonical pattern | Origin/network/sandbox policy, prose authority, static/offline/print fallback, artifact-size and failure contract |

Patterns may be expressed with WikiText, Markdown, tables, inline SVG, Draw.io output, or a small product-owned widget. The author-facing semantics, reading order, accessibility, and containment are the contract; exact DOM is not.

## Lab: experimental presentation and investigation surfaces

| ID | Experimental group | Question to investigate | Initial data/source candidates | Boundary |
|---|---|---|---|---|
| L01 | AST/source linkage | Can a reader select source syntax and see the corresponding AST or parser production without losing the text explanation? | `AS_Parser.md`, `AS_Compiler.md`, parser source and compiler tests | Static fixture first; no browser AS compiler dependency |
| L02 | Bytecode/VM execution | Can a bytecode trace explain stack/register/context behavior at a useful scale? | `AS_ByteCode.md`, `AS_VirtualMachine.md`, SDK/runtime tests | Recorded deterministic trace; no claim of executing project AS in Wiki |
| L03 | Hot-reload before/after state | Which class/default/component/instance facts survive each reload class? | `RT_HotReload.md`, reload tests, BlueprintImpact evidence | Compare recorded states; do not connect directly to a live editor in this change |
| L04 | Reflection-object generation | How do script declarations become UClass/UStruct/property/function artifacts? | `Type_ClassGeneration.md`, `Type_StructGeneration.md`, ClassGenerator sources | Text/table fallback required |
| L05 | DebugServer and call stack | How do editor/VS Code requests, stack frames, scopes, and stepping state flow? | `RT_Debugger.md`, DebugServer V2 and extension protocol tests | Use sanitized recorded messages; no remote service |
| L06 | Test matrix and coverage | Which behavior is protected at language, runtime, integration, editor, and browser levels? | test catalogs, CodeCoverage, state dump, current suite data | Counts must be revisioned and not conflated |
| L07 | Tag, navigation, and search layouts | Which topic/depth/status layout remains usable with real content volume? | Proposed metadata plus seeded fixtures | Lab-only until real-page accessibility and responsive review |
| L08 | Code folding, focus, and annotation | Which interactions improve long implementation listings without harming copy, keyboard, or mobile use? | Existing AS code widget and test sources | No per-frame tiddler writes; graduate only with author contract |
| L09 | SVG, Draw.io, HTML, and Canvas comparison | Which rendering approach best fits each mechanism while remaining offline-readable? | Selected Draw.io plugin, inline SVG, ordinary HTML | Canvas/WebGL/WASM lazy or external; saved textual/static fallback |
| L10 | Future test-framework concept interface | Can prospective test runner, filter, result, and trace ideas be evaluated without pretending the UI is implemented? | current runtime/CQTest/automation contracts | Clearly fictional data and experimental labeling |
| L11 | Web-embed security and packaging policy | Which `srcdoc`, packaged page, sandboxed external iframe, or new-window link form fits the single-file/offline product and its CSP? | Synthetic/product-owned fixtures and publishing configuration | No credentials, arbitrary remote scripts, or production dependency; CSP/privacy/threat/accessibility review before graduation |

## Implementation order

1. Create the root and three tier indexes plus one catalog tiddler containing all 42 entries.
2. Add tier metadata and documentation-purpose fields to the existing reader-facing Showcase pages without changing their content behavior.
3. Resolve the mixed role of `AngelscriptCodeExamples.tid`: hidden `$:/tests/...` fixtures remain test infrastructure; a reader page is created only if it can be maintained as documentation.
4. Close Base gaps in small, focused changes tied to theme/document behavior.
5. Add Pattern pages only when a real Chinese document needs the composition.
6. Keep Lab entries as catalog records until an experiment has deterministic sample data and an explicit isolation boundary.

## Verification inventory

The later foundation implementation should assert:

- exactly one of `ASWiki/Showcase/Base`, `ASWiki/Showcase/Pattern`, or `ASWiki/Showcase/Lab` on every Showcase entry page;
- a nonempty documentation-purpose field;
- catalog IDs are unique and cover B01–B15, P01–P16, and L01–L11;
- reader-facing pages do not use `$:/tests/...` titles;
- hidden fixture tiddlers do not appear as Showcase directory entries;
- Base, Pattern, and Lab remain discoverable and accurately labeled;
- a Lab page is never counted as a stable Base/Pattern compatibility surface;
- heavy experimental runtimes are absent from the initial product path.
- B13 distinguishes procedures/functions from legacy macro compatibility and covers parameter/scope edge cases;
- B14 contains no live script or inline event handler and keeps nested widgets accessible;
- B15 uses a deterministic local fixture, minimal iframe permissions, explicit network/offline fallback, and responsive containment;
- P15/P16 expose stable author contracts before repeated use, while L11 remains experimental.
