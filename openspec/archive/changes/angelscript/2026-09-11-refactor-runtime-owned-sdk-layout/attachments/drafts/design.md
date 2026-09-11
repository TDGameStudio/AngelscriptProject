# Design: first-party SDK layout

Status: approved

Change ID: `angelscript/refactor-runtime-owned-sdk-layout`

## Why

The plugin already moved the maintained AngelScript SDK from
`Source/AngelscriptRuntime/ThirdParty/angelscript/source/` to
`Source/AngelscriptRuntime/angelscript/` (no nested `source/` directory). That
tree is first-party reconstruction source, not an unmodified ThirdParty drop.
Live include paths, current specs, and current guides still name the old
organization, so agents and UBT will keep targeting a deleted directory.

This Change retargets those live contracts. It does not move files again, does
not change SDK behavior, and does not rewrite immutable archives.

## Scope

In:

- `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs`
  include roots: `ModuleDirectory/angelscript` (where `as_*.h` and
  `frontend/` live). Drop `ThirdParty/angelscript`.
- Plugin `README.md` contents list if it still describes a ThirdParty SDK tree.
- Current specs and knowledges that still prescribe
  `ThirdParty/angelscript/source` as the organization:
  `openspec/specs/angelscript/language/ast/core/spec.md`,
  `language/frontend/reflection-dependencies/spec.md`, and matching
  knowledges that cite those paths as current authority.
- Current guides that instruct edits under the old path:
  `Documents/Guides/AngelscriptForkStrategy.md` and any other
  `Documents/Guides/` file that is still used as a live routing instruction
  to `ThirdParty/angelscript`.
- A consumer list in attachments: other **active** Changes that still name
  `ThirdParty/angelscript` (they replan themselves; this Change does not edit
  their `tasks.md`).

Out:

- Further SDK source moves or restoring a nested `source/` folder.
- `AngelscriptLSP/` CMake fork-root (owned by
  `angelscript/refactor-standalone-lsp-layout`, which depends on this path).
- Immutable `openspec/archive/` records.
- Historical `Documents/Knowledges/ZH/` and dated audit notes, unless they are
  the only remaining live instruction (they are not).
- `Source/AngelscriptTest/TestCode/` and `TestFramework/` (owned by
  `angelscript/refactor-testing-unified-framework`).
- Behavior, public C API (`Core/angelscript.h`), or Automation identities.

## Architecture

```
AngelscriptRuntime
├─ [include] Core/angelscript.h                    // Public C API header; location unchanged
└─ [include] angelscript/                         // First-party SDK root after this Change
   ├─ as_*.h / as_*.cpp                            // VM, engine, bytecode, metadata
   └─ frontend/                                    // Lexer, parser, sema, session; include as "frontend/…"
```

UBT public include path becomes `Source/AngelscriptRuntime/angelscript`.
Existing `#include "angelscript.h"` (from `Core/`) and `#include "frontend/…"`
keep working because `ModuleDirectory` and the new SDK root stay on the include
path. No new module, namespace, or header name.

## Vocabulary and naming

| Name | Role |
| --- | --- |
| `angelscript/refactor-runtime-owned-sdk-layout` | This Change |
| `Source/AngelscriptRuntime/angelscript/` | First-party SDK root (already on disk) |
| `Core/angelscript.h` | Unchanged public C header |

Rejected: keeping a `ThirdParty/angelscript` alias or symlink; renaming the
on-disk folder again.

## Error handling and edges

- A missing new include root must fail the Editor build, not silently fall back
  to the deleted ThirdParty path.
- Spec text that talks about "directory organization vs C++ namespace" stays;
  only the example path updates. `BEGIN_AS_NAMESPACE` rules do not change.
- Knowledge files that cite old paths as **current** source locations are
  retargeted. Knowledge that cites an archived Change's snapshot path can keep
  the historical string if it is clearly historical.

## Verification

1. Confirm `AngelscriptRuntime.Build.cs` points only at
   `ModuleDirectory/angelscript` (and `ModuleDirectory` / `Core`), with no
   `ThirdParty/angelscript`.
2. Incremental Harness `ue.build` of `AngelscriptProjectEditor` (Win64,
   Development). The moved tree currently cannot compile until this include
   root is fixed; GREEN is a successful editor build.
3. Strict OpenSpec validation of every edited current spec.
4. Grep of live specs and the listed Guides for `ThirdParty/angelscript` as a
   current instruction; remaining hits must be historical or in archive.

Intentionally omit: Automation suites, Standalone/CMake package, Quick /
Performance / Integration. No SDK behavior changed.

## Consumers to replan (do not edit here)

Active Changes whose Files still name `ThirdParty/angelscript` must replan
after this record exists. Inventory at handoff; known at design time:

- `angelscript/feature-frontend-diagnostics-tooling`
- `angelscript/refactor-sdk-drop-native-gc`
- `angelscript/refactor-bindings-two-stage-pipeline` (if its remaining tasks
  still cite the old tree)

## Relationship

`angelscript/refactor-standalone-lsp-layout` retargets `Standalone/` →
`AngelscriptLSP/` and must set its CMake fork root to this new SDK path. It
does not own Runtime.Build.cs.
