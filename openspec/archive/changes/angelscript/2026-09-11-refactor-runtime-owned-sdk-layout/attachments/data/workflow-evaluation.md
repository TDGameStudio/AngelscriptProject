---
record: harness-workflow-evaluation-v1
result: passed
change: angelscript/refactor-runtime-owned-sdk-layout
closure_kind: completed
input_sha256: b130d77b7bcecac09a5193d4337bd2da70609abbd88c2613419785abddfa8e67
captured_at: 2026-09-11T12:12:30+00:00
---

# Terminal workflow evaluation

## Lifecycle

- Created from the approved `runtime-owned-sdk-layout` draft.
- Implemented include-root retarget, live spec/knowledge path language, ForkStrategy/README/LICENSE docs, and a sibling consumer-replan list.
- First Editor build failed on leftover `#include "source/as_*.h"`; those live includes were rewritten in task 1.1. Legacy deleted-header includes stayed untouched.

## Verification

- Task proofs: 1.1 GREEN Harness `ue.build` `AngelscriptProjectEditor` Win64 Development RunId `f0fb5e1625a24ed88dc39b916347bd05` (exit 0). RED RunId `09a518d2884e4f1bb0318b2acc32f47b` (exit 6, C1083 `source/as_*.h`).
- 2.1/3.1 Select-String of owned live specs/guides/README/LICENSE/Build.cs found no current `ThirdParty/angelscript` instruction.
- 4.1 consumer list names diagnostics-tooling, drop-native-gc, bindings-two-stage, and delegates-ue-interop.
- `openspec doctor` and strict change validation succeeded. Synced scenarios "Include the reconstructed language headers" and "A caller names the reconstructed preprocessing API" have no spec-validator errors.
- Affected current specs `angelscript/language/ast/core` and `angelscript/language/frontend/reflection-dependencies` still fail strict validation on unspecified scenarios (81 and 70 four-space indent findings). Those are pre-existing baseline formatting failures, not introduced by this delta; this Change does not migrate the rest of those records.

## Material friction and corrective action

- Flattened SDK root does not satisfy `#include "source/as_*.h"`. Live consumers now include `"as_*.h"` or `"frontend/as_*.h"`.

## Spec and knowledge disposition

Durable path-language deltas were merged into the two named current specs. Change-local `first-party-sdk-root.md` is promoted to `openspec/specs/angelscript/language/ast/core/knowledges/first-party-sdk-root.md`.

## Scope boundary and provenance

Harness Quick, Performance, Integration, Automation suites, and CMake host package were omitted: no SDK behavior change. Raw Unreal runs remain under ignored `Saved/Harness/Unreal/Runs/<RunId>/`. Sibling Changes replan their own Files. This Change ID is not a reusable Harness gate default fixture.
