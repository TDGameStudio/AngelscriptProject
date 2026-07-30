# Documentation Source Inventory

Captured: 2026-07-25 (Asia/Shanghai)

This inventory records the inputs used to design the documentation foundation. It is evidence for planning, not permission to copy third-party prose or media.

## 1. Hazelight website source

| Field | Value |
|---|---|
| Local path | `Reference/Docs-UnrealEngine-Angelscript` |
| Remote | `git@github.com:Hazelight/Docs-UnrealEngine-Angelscript.git` |
| Branch | `master` |
| Local HEAD | `3864c72fa3c1ef67413dfaad24417bad01879b4d` |
| Remote `refs/heads/master` | `3864c72fa3c1ef67413dfaad24417bad01879b4d` |
| Working tree | Clean at capture time |
| Tracked files | 68 |
| Markdown files | 29 |
| Static media | 32 PNG, 1 SVG, 1 ICO |
| Site generator | Zola |
| Configured site | `https://angelscript.hazelight.se` |
| Main sections | Getting Started, Script Features, C++ Usage and Bindings, UE-AS Development |

The local README states that this repository contains the source text for the Hazelight documentation website. `config.toml` sets the same public base URL and enables a search index.

### Reuse boundary

The repository contains `content/project/license.md`, which describes the Unreal Engine, AngelScript library, and UnrealEngine-Angelscript plugin code licenses. It does not contain a repository-level documentation-content license, `LICENSE`, `COPYING`, or `NOTICE` file for the website prose and media.

Therefore:

- use Hazelight pages as a primary behavior/reference index;
- paraphrase and rewrite prose for the current fork;
- attribute the source and pinned revision in research and article provenance;
- do not copy whole articles or substantial passages;
- do not import screenshots, logos, or other media until their provenance and reuse rights are reviewed;
- prefer current project examples and current plugin source as behavioral evidence.

### Hazelight private source and engine-change record

The current source-level audit was authorized as read-only comparison research:

| Field | Value |
|---|---|
| Repository | private `Hazelight/UnrealEngine-Angelscript` |
| Branch | `angelscript-master` |
| Observed HEAD | `f459e6322f63deef8d345f1c1624734cc22747e3` |
| Previous maintained audit marker | `138a7e186082b639375b95545e0177b18f13c4be` |
| New commits in the observed range | 1: editor-only UASClass/UASStruct propagation |
| Local comparison revision | plugin `4e2e23ca16ae9f1786258fb96b09b268259b1aad` |
| Publication boundary | revisioned/paraphrased findings only; no private-source mirror or public excerpt |

`Documents/Hazelight/HazelightAngelscriptEngineChangeReport.txt` is a separate historical evidence object. It was generated on 2026-03-12 and visibly marks thirteen `Engine/Source` leaf files as changed, but it contains no Git revisions and is not exhaustive. Current private source verifies additional AngelScript changes under CoreUObject private implementation, Editor, Engine private implementation, EpicGames.Core, and EpicGames.UHT.

At capture time the configured Hazelight engine root and ordinary engine root resolved to the same directory, so they were not treated as an independent local diff. No absolute machine path is recorded in this OpenSpec.

Detailed evidence priority, function-bind/UHT/class/struct findings, known stale local claims, and repeatable update rules are recorded in:

- `research/hazelight-comparison-audit.md`;
- `research/hazelight-engine-change-inventory.md`.

Running this research does not advance the global Hazelight audit marker. A future Wiki update consumes a pinned comparison record; it never queries the private repository during ordinary development, test, build, or page rendering.

## 2. Host Chinese knowledge base

| Field | Value |
|---|---|
| Path | `Documents/Knowledges/ZH` |
| Markdown files | 73 |
| Approximate organization | 9 prefix families |
| Prefixes | `Arch_`, `AS_`, `Type_`, `RT_`, `Test_`, `Syntax_`, `Diff_`, `Guide_`, `Note_` |
| Index | `Documents/Knowledges/ZH/Index.md` |
| Authoring rules | `Documents/Knowledges/ZH/Rule.md` |

The knowledge rules explicitly describe these documents as maintainer-oriented material, allow source-level depth, and distinguish usage guides from syntax/runtime/type internals. They are not ready-made Wiki reader pages.

Migration policy:

- preserve all files during the foundation and first content batches;
- split large articles by reader outcome and depth;
- verify behavioral claims against current plugin source/tests;
- adapt old GitHub Markdown conventions to the selected TiddlyWiki content type;
- retain source evidence and cross-links;
- make deletion/deprecation a later per-topic decision with coverage evidence.

`Documents/Knowledges/Temp` contains additional temporary material and is excluded from the initial 73-file crosswalk. A later audit may promote individual items only after provenance and duplication review.

## 3. Other host documents

Important source groups:

- `Documents/Guides`: build, test, fork strategy, bindings, diagnostics, UHT, VS Code, and current technical-debt guidance.
- `Documents/Hazelight`: detailed Hazelight comparison and implementation notes.
- `Documents/Rules`: Git and inline AngelScript formatting rules.
- `AGENTS.md` / `AGENTS_ZH.md`: current module boundaries, feature status, dependency graph, test baselines, and maintenance rules.
- `openspec/specs` and active/archived changes: behavior contracts and change history.

These sources are authoritative only for the scope and revision they describe. Generated reports and legacy `Documents/Plans` are research history, not current planning destinations.

## 4. Current executable AngelScript examples

The host `Script/` tree contains 36 `.as` files:

- 18 core examples in `Script/Examples/Core`
- 3 Enhanced Input examples
- 6 extended examples
- 1 game example
- 8 script tests

Example content is preferred over copied third-party snippets when it matches the current fork. Before promoting a test or example to documentation, the content must be checked for reader intent, current API behavior, minimal dependencies, and a reproducible expected result.

## 5. Plugin source boundaries

### Core plugin

`Plugins/Angelscript/Source` contains:

- `AngelscriptRuntime`
- `AngelscriptEditor`
- `AngelscriptTest`
- `AngelscriptUHTTool`

Captured repository facts:

| Field | Value |
|---|---|
| Local path | `Plugins/Angelscript` |
| Remote | `git@github.com:TDGameStudio/UnrealAngelscriptPlugin.git` |
| Canonical browser URL | `https://github.com/TDGameStudio/UnrealAngelscriptPlugin` |
| Branch | `main` |
| Captured committed revision | `4e2e23ca16ae9f1786258fb96b09b268259b1aad` |
| Working tree | Dirty; not eligible as a Wiki source snapshot input |
| Top-level license | MIT, Hazelight Games AB and TDGameStudio |
| Embedded kernel license | AngelScript zlib under `Source/AngelscriptRuntime/ThirdParty/angelscript/` |

The future Wiki corpus synchronizes an exact published GitHub commit in an isolated temporary checkout. It does not copy this local worktree and does not flatten third-party license boundaries.

Runtime subject areas:

- Binds
- ClassGenerator
- Core
- Debugging
- Dump
- Extension
- FunctionBinding
- FunctionLibraries
- Hash
- Preprocessor
- StaticJIT
- Subsystem
- Testing
- ThirdParty

Editor subject areas:

- BaseClasses
- BlueprintImpact
- CodeGen
- ContentBrowser
- Core
- Dump
- EditorMenuExtensions
- FunctionLibraries
- HotReload
- LearningTrace
- Snippet
- SourceNavigation
- Tests

Test subject areas:

- AngelScriptSDK
- Bindings
- Compiler
- Core
- Coverage
- Debugger
- Delegate
- Dump
- Editor
- FileSystem
- Functional
- GC
- Generator
- HotReload
- Memory
- Networking
- Performance
- Preprocessor
- StaticJIT
- Syntax
- UHTTool
- Validation

### Optional plugins

- `Plugins/AngelscriptGameplayTags`: Runtime, Editor, and Test modules; depends on Angelscript.
- `Plugins/AngelscriptGAS`: Runtime and Test modules; depends on Angelscript, AngelscriptGameplayTags, and GameplayAbilities.

### Domain integrations that are not optional AngelScript plugins

- Enhanced Input is enabled as a dependency of the core Angelscript plugin and has dedicated examples.
- Networking/RPC behavior is implemented and tested through the core integration.
- UI/UMG and AI/BehaviorTree are engine-domain surfaces reached through bindings and examples.

Documentation taxonomy must not confuse “special topic” placement with packaging.

## 6. Wiki product baseline

| Field | Value at capture |
|---|---|
| Submodule path | `Wiki` |
| Branch | `main` |
| Captured HEAD | `69ad90dcd4563d21b2cd4ce9677f63c17561b847` |
| TiddlyWiki | 5.4.1 |
| Node baseline | 24 |
| pnpm baseline | 11.8.0 |
| Tracked `wiki/tiddlers` files | 34 |
| Formal reader-content files outside `tests/` and `system/` | 17 |
| Current showcase directory/index pages | 5 (one index plus four primary syntax pages) |

The Wiki worktree was dirty before this OpenSpec and contains user-owned/in-progress toolchain, translation, icon, navigation, theme, and test changes. This OpenSpec creation must not alter those paths.

## 7. Revision keys for future provenance

Repository-level source families for `as-sources`:

| Key | Meaning |
|---|---|
| `hazelight-docs` | Pinned Hazelight website source; revision recorded in the source registry |
| `hazelight-private-source` | Restricted pinned source observation used for comparison metadata only; never emitted as a public excerpt |
| `hazelight-engine-report` | Dated local folder-comparison report with explicit non-exhaustive/missing-revision limitations |
| `project-knowledge-zh` | `Documents/Knowledges/ZH` at a recorded parent revision |
| `project-guide` | Current host guide or rule at a recorded parent revision |
| `angelscript-plugin` | Core Angelscript submodule source at a recorded submodule revision |
| `gameplaytags-plugin` | Optional GameplayTags plugin source at a recorded revision |
| `gas-plugin` | Optional GAS plugin source at a recorded revision |
| `script-examples` | Host `Script/` example/test source at a recorded parent revision |
| `openspec` | Current/archived OpenSpec requirement or design evidence |

Machine-specific absolute paths must never become source keys or reader-visible provenance.

Article-level source keys use the more specific namespaces and seed entries in `research/source-reference-seeds.md`. The broad keys above identify repository families; they are not substitutes for a stable file/symbol/excerpt key in a reviewed internals page.
