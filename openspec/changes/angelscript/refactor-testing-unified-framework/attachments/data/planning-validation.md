# Planning delivery evidence

## Scope and disposition

Date: 2026-09-05. Selected workspace: `D:/Workspace/AngelscriptProject`.
Change: `angelscript/refactor-testing-unified-framework`.

The user authorized creation of a detailed OpenSpec Change and explicitly
excluded implementation. The delivered records are the CLI-owned manifest,
proposal, design, five delta specifications, future Task DAG, attachment index,
class contracts, provenance and this evidence. New declarations, macros, schemas
and CLI examples describe future APIs; they are not available implementation.

The Change stays active. All **16 future tasks remain unchecked**. No framework,
Python tool, generated resource, test, Skill or current-specification edit was
made by this planning work. Existing unrelated dirty files and the concurrent
Builder work remain outside the Change. No worktree creation, branch integration,
commit, push, specification synchronization or archive was performed.

## Deterministic record validation

Harness was imported and invoked in the current PowerShell 7 process:

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @(
    'angelscript/refactor-testing-unified-framework',
    '--type', 'change', '--strict', '--json')
Invoke-Harness -Command task.status -Context $context -Parameters @{
    Change = 'angelscript/refactor-testing-unified-framework'
}
```

Observed strict validation: **Succeeded**, exit 0, 1 Change passed, 0 failed,
empty issues array. Observed task status: **16 total / 0 complete / 16 remaining**,
valid prerequisites and exact verification commands for every node. Parsed file
owners contain full paths, not broken brace/comma fragments. The initial graph
nodes are 1.1, 2.1 and 2.2; their derived readiness conveys prerequisites only,
not implementation permission.

OpenSpec artifact completeness refers to the presence of proposal/design/specs/
tasks. It is not completion of implementation, verification or archive.

## Content and interface checks

The author performed focused consistency checks, including bounded independent
read-only inspection. This was ordinary planning validation, not an OpenSpec
Review lifecycle or an implementation review.

- Source facade naming, one-argument macros, SourceId/VersionTag identity,
  immutable lifetimes, exact bytes and local scope agree across records.
- SourceHistory ancestry is separate from operation order and last-good runtime
  state. The first slice does not claim unavailable live reload support.
- SourceBundle consumes the catalog and history; its integration task follows
  those dependencies. Foundation source tasks do not require a future catalog.
- Old Python delegation is restricted to SourceHistory. Unmigrated ordinary
  Contract V2 CLI and audit/strict behavior are preserved.
- Versioned JSON schemas supply Python admission authority; C++ codecs prove
  agreement with shared valid/invalid examples rather than Python inferring types.
- Local UE 5.8 declarations support the planned Automation bridge signatures and
  relative `Rows.<RowId>` name composition. The public CQTest asserter supports
  the fixture's member Run convention; no private CQTest macro is needed.
- Current frontend snapshot/source-manager/identifier/diagnostic declarations
  support the proposed source fixture and owned diagnostic capture. This does
  not pre-approve unsettled Builder APIs.
- Artifact output uses the existing ReportExportPath argument. Missing managed
  metadata remains absent; interactive fallback does not fabricate a RunId.
- Future Skill work covers class-only helpers, no anonymous namespace solely for
  one CQTest class, public hooks, visible assertions, obsolete routes and truthful
  promotion of implemented examples. The Skill itself was not changed.

The final document check resolves relative Markdown links inside this Change,
checks balanced fenced blocks and conflict markers, parses the three JSON
examples, and verifies unchecked task state. JSON parsing establishes valid
example syntax; it does not pretend future JSON schemas already exist.

Final observed document check: **12 Markdown files / 13 total Change files**,
**3 JSON examples parsed**, consistent source/case/selection identity closure,
no missing relative links, unbalanced fences or conflict markers. The class
contracts contain 999 lines and the attachment index 56 lines. Final strict
validation and Task DAG inspection both succeeded again; every task has a
verification command and no malformed file owner was reported.

## Execution evidence and intentionally omitted checks

The existing SourceHistory investigation ran:

```powershell
python -B -m pytest TestSource/Generation/python/tests/test_reload_history.py -q -p no:cacheprovider
```

Observed **2 passed**, limited to existing parser/diff behavior. Details and
historical script-corpus run reports are classified in `provenance.md`.
Historical reports were inspected rather than rerun, and do not prove the
current reconstructed runtime or the new framework.

No Unreal build, Automation run, full suite, live reload test or generator export
was run for this documentation delivery. No implementation changed, and the
future framework commands target files that owning tasks will create. The Skill
format validator was not used to claim a Skill update because none was made.
Current specifications were not synchronized merely to make planning pass.
