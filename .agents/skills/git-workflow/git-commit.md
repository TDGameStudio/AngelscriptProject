
# Git Commit Guide

## Commit Format

```text
[<Scope>] <Type>: <description>

<body optional>

<footer optional>
```

## Format Details

- `Scope`: Optional. Indicates the primary module, system, or feature area affected by the commit, such as `UI`, `Build`, `Physics`, or `Inventory`.
- `Type`: Required. Indicates the kind of change. Use clear and consistent categories such as `Fix`, `Feat`, `Refactor`, `Docs`, `Test`, and `Chore`.
- `description`: Required. A concise summary of the core change. Focus on the outcome and avoid vague wording.
- `body`: Optional. Adds context such as why the change was made, what background is relevant, or any notable impact.
- `footer`: Optional. Used for task references, issues, breaking changes, or other supplemental notes.

## Writing Guidelines

- Keep the title line concise and prioritize the most important change.
- Use capitalized `Type` values consistently to align with common UE commit style.
- `Docs` represents the change type, not the scope. When the affected module is clear, include a `Scope` as well.
- Write `description` with a clear action and result. Avoid vague phrases like "update something" or "adjust content".
- If the change spans multiple modules, you may omit `Scope` or choose the most important affected area.
- If the commit needs additional context to be understood, add a `body`. Otherwise, the title line alone is enough.

## Branch Naming

Use slash-separated branch names with one of these type prefixes:

```text
feature/<slug>
fix/<slug>
refactor/<slug>
test/<slug>
docs/<slug>
chore/<slug>
```

- `<slug>` uses lowercase words separated by hyphens.
- Match the branch prefix to the primary intent of the work.
- For OpenSpec-backed work, use the same slug as the change name when practical. Example: `test-as-static-jit-engine-state` maps to `test/as-static-jit-engine-state`.
- When changing `Plugins/Angelscript`, use the same branch name inside the submodule as the root repository branch.

## Worktree Location

Create local git worktrees under the repository-local `.worktrees/` directory:

```text
.worktrees/<change-name>
```

- Do not create project worktrees in sibling directories, `worktrees/`, or user-global locations unless the user explicitly requests it.
- Use the OpenSpec change name as the worktree directory name when the work is OpenSpec-backed.
- `.worktrees/` is ignored by git and is the canonical local workspace root for parallel branches in this repository.

## Examples

```text
[Physics] Fix: prevent character teleport jitter on steep slopes
[UI] Feat: add inventory hotkey hints for enhanced input
[Build] Chore: update plugin compatibility to UE 5.5
[Inventory] Refactor: simplify item stack merge flow
[Angelscript] Docs: clarify module setup steps
```

## Example With Body

```text
[UI] Feat: add inventory hotkey hints for enhanced input

Show the current hotkey bindings directly in the inventory panel so
players can discover the enhanced input mappings without leaving gameplay.
```

## Example With Footer

```text
[Build] Chore: update plugin compatibility to UE 5.5

Refs: TASK-128
```
