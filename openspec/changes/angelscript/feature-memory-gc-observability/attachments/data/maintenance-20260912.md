# Current-baseline maintenance — 2026-09-12

## Authorized boundary

The user requested inspection and correction of stale active Changes and their format. This is record maintenance through openspec-update-change in the existing selected workspace. No implementation, task completion, spec synchronization or archive is inferred from a valid record. Previously completed task IDs/checks and all dependency edges are preserved.

## Evidence and applied correction

The September 6 collector-instrumentation target conflicts with the accepted pending native-GC removal. The proposal and planning node now target final release, retained cycles and shutdown drain, with UE GC/schema/tombstone observations separate. Native collector metrics become unavailable after removal. The collector still exists today: this update neither claims deletion nor runs instrumentation. Historical research and metrics matrices are retained verbatim and are superseded where they prescribe native collector probes.

Source baseline: parent HEAD `afeff74519a0d81e40702f140503cffe911789c6`, including the user's existing uncommitted workspace changes. Current source was inspected directly; historical attachment hashes are not rewritten to fit it.

Relevant baseline authorities:

- `AGENTS.md`, `.agents/skills/openspec/references/tasks.md`, `specs.md`, and Harness impact-scoped verification.
- Completed SDK layout, language-surface, type-ownership, SDK compile-lifecycle, frontend-phase-directory and isolated-lexer archives under `openspec/archive/changes/angelscript/`.
- Current `Core/AngelscriptTypeBindInfoDraft.h`, `Core/AngelscriptEngine.h`, `angelscript/as_module_definition_set.h`, `angelscript/as_builder.h`, and `angelscript/as_scriptengine.h` beneath the owning Runtime module.
- Active `refactor-sdk-drop-native-gc` and `docs-class-reload-replaced-tombstone-lifetime` for accepted lifetime boundaries; their presence is not evidence that native collector deletion landed.

## Verification boundary

The baseline `openspec.validate --changes --strict --json` checked 9 active Changes: 7 passed, diagnostics/tooling and unified testing failed with 140 total diagnostics. Candidate Task DAG frontmatter, permanent IDs and checkbox states were compared to the baseline before writes and remained unchanged. Completed tombstone and LSP-layout Change contents were preserved byte-for-byte.

Final strict validation, current PowerShell command parsing and local attachment-link results are recorded below after execution. No UE build, Automation, Quick, Performance or Integration suite is needed for these document-only edits; no product GREEN is claimed.

## Resume boundary

Resume task `1.1` only when its planned work is selected. Existing proposal-stage planning tasks stay planning tasks. A structurally valid Task DAG does not certify behavior-card preflight: older future product cards still require exact consumed signatures, named case roles/oracles and supported selectors to be checked through the existing Ensure plan/update route before execution. This maintenance does not manufacture missing design decisions or claim those product cards were executed.

## Executed record checks

- Harness `openspec.validate --changes --strict --json`: Succeeded, exit 0, runId `f12458c2491b4760a319240252fd62c4`; 9 passed, 0 failed.
- Harness `task.status` for all 9 active Changes: Succeeded; original task IDs/checks/dependencies retained. Derived graph readiness is not behavior-card preflight approval.
- PowerShell parser: all 61 fenced PowerShell proving commands across the active plans parsed, 0 syntax failures; Python commands were not executed as product tests.
- Pre-existing evidence attachment bytes (excluding navigation INDEX) and both completed active Changes were compared with the captured working snapshot; unchanged.
- Local Markdown navigation: 43 links resolved; every attachment in the 7 updated indexes has exactly one entry. No missing index target remains.
- Integrity: 69 task IDs/states and all dependency edges retained; 52 historical-evidence/completed-record files byte-identical to the initial workspace snapshot.
- Scoped git diff --check: passed after whitespace normalization.
