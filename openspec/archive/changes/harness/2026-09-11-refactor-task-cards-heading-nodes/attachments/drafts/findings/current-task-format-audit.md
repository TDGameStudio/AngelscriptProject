# Audit of active `tasks.md` files (2026-09-11)

Source: `openspec/changes/**/tasks.md` (7 active), `task.status` per Change, `.agents/skills/openspec/references/tasks.md` (the current contract).

## Numbers

| Change | Tasks | Lines | Lines/task | Numbered impl steps | `**Cases**` | `**Context and interfaces**` | Code fences in cards | `task.status` Ready |
|---|---|---|---|---|---|---|---|---|
| feature-delegates-ue-interop | 10 | 182 | 18 | 0 | 0 | 0 | 0 | 0 (retired format) |
| feature-frontend-diagnostics-tooling | 9 | 187 | 21 | 0 | 0 | 0 | 0 | 0 (retired format) |
| feature-memory-gc-observability | 1 | 42 | 42 | 0 | 0 | 0 | 0 | 0 (retired format) |
| refactor-defaults-constructor-unification | 1 | 42 | 42 | 0 | 0 | 0 | 0 | 0 (retired format) |
| refactor-testing-unified-framework | 16 | 239 | 15 | 0 | 0 | 0 | 0 | 0 (retired format) |
| refactor-sdk-drop-native-gc | 3 | 181 | 60 | 9 | 3 | 3 | 6 | 1 |
| refactor-bindings-two-stage-pipeline | 24 | 1206 | 50 | 3 | 24 | 24 | 48 | 1 |

Two populations:

- **Five Changes in the retired inline format** (`— verify:` on the title line, `> Files:` quote). The parser reports "unsupported format" and exposes **zero Ready work**. These plans cannot be executed through Harness at all until migrated. Cards are 15–20 lines: a title, a verify command, a file list. No cases, no interfaces, no steps.
- **Two Changes in the current rich format.** Cards are long (50–60 lines) but the length is mostly prose. In the 24-task bindings plan there are **3 numbered implementation steps in total**; `Implementation` is a paragraph. `Cases` are sentences ("a test module includes Public/Bindings only and registers a captureless lambda; its callback records one fixture type and is discoverable"), not literal input → expected output. Code fences are almost all the Verification command, not test or interface code.

## What one rich card looks like (bindings 2.1, abridged)

- **Outcome**: "Introduce the named public Registration/Context/Builder/Database/Installer boundary and Framework directories with bounded old-header adapters." — five components in one task.
- **Context and interfaces**: three sentences pointing at design §3/§8; no signatures.
- **Cases**: three prose bullets plus a note that RED may be skipped for a structural task.
- **Implementation**: one paragraph: "Introduce minimal public headers and forwarding bridge, move responsibility owners into Framework, update internal includes and generated-wrapper paths, and compile the independent consumer. Move metrics to Diagnostics…"
- **Files**: 13 entries, several `**` globs over whole directories.
- **Verification**: one `ue.test` prefix.

A zero-context implementer cannot start this card without re-deriving the design: which headers, which names, in what order, what does the first failing test look like.

## Preamble bloat

Both rich plans open with 40–60 lines of per-Change "conventions" (how to import Harness, when to build, what counts as PASS, authorization notes). The same text is repeated across Changes with small drift. It belongs in a reference, not in every `tasks.md`.

## Diagnosis

1. **Granularity is defined by "feature outcome", which in practice becomes "component".** The contract says one node = smallest independently acceptable feature outcome; authors read that as one subsystem slice. Nothing forces the card to break the work into steps small enough to execute blind.
2. **Sections are optional labels, so they degrade to prose.** `Cases`, `Implementation`, `Context and interfaces` have no required shape; under time pressure they become sentences. Only `Files` and `Verification` are machine-checked, so only those are consistently filled.
3. **No required code in cards.** The contract allows code fences; it does not require the failing test, the interface signature, or the RED/GREEN command output to appear. superpowers requires them.
4. **Nested checkboxes are forbidden** (parser: one root checkbox = one node), so the step-level tracking superpowers uses is unavailable; numbered lists are the substitute and are rarely written.
5. **No plan-level header.** Goal, architecture summary, spec link, and global constraints are scattered across proposal/design and an ad-hoc preamble.
6. **Migration debt.** Five of seven active plans are unexecutable by Harness. Any format iteration must decide what happens to them.
