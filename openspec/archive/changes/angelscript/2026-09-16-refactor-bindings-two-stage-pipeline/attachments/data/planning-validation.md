# Planning validation

## Delivery result

Created angelscript/refactor-bindings-two-stage-pipeline as a planning-only Change. The delivered files are the CLI-owned manifest, proposal, design, four delta specs, 23-node tasks.md, attachment INDEX, source evidence, provider inventory and this validation record. No product task was executed; no C++/header/Build.cs/test implementation or current specification was modified.

## Executed checks

| Check | Actual result |
| --- | --- |
| Project-local OpenSpec change create through Harness | Succeeded; Change UID change_011ae428-a46e-486f-b758-c30a3f7c09cd |
| Strict Change validation | Passed with no issues; Harness run 2a3933ceb1614784b64245dd64aba239 |
| Harness task.status | Succeeded; 23 tasks, 0 complete, only 1.1 structurally Ready; run 029c167924e44586a17569d58f8eabce |
| Proving command syntax | All 23 fenced proving commands parsed with the PowerShell language parser; no commands were executed |
| Inventory/source checks | 254 lexical registration sites across 130 files; each source exists, SHA-256 matches and recorded symbol matches the recorded line |
| Text/attachment checks | UTF-8 readable files with final newlines and no trailing whitespace; no execution checkboxes outside tasks.md; bounded attachments |
| Parent tracked diff | Unchanged from creation-session baseline |
| Plugin tracked diff | Unchanged from creation-session baseline |
| Git status scope | Only new status entry is this Change directory |

Strict validation was also used during artifact construction. Before tasks.md existed it correctly reported the missing required artifact; after tasks.md was authored it passed. Structural readiness is a parser result, not authorization to start implementation in this creation session.

### Commands

Run from the selected workspace after importing Harness and creating the workspace context:

```powershell
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-bindings-two-stage-pipeline', '--type', 'change', '--strict', '--json')
Invoke-Harness -Command task.status -Context $context -Parameters @{ Change = 'angelscript/refactor-bindings-two-stage-pipeline' }
```

Additional checks used read-only git diff/status, source SHA-256/line checks, attachment/link checks, delta-to-current requirement-name checks and PowerShell Parser.ParseInput over the CLI-returned proving commands. These validate planning mechanics only; they do not prove future API behavior or successful UE execution.

## Scope fingerprints

| Repository | HEAD | Unchanged tracked diff SHA-256 |
| --- | --- | --- |
| Parent | 0f0cf23ee78e563bf93dcf20b43a55381948273d | ea58b54e3419288ebbf808a8c6ad3d7bb26fb2e34b96c66b033e5e65d65724e5 |
| Plugins/Angelscript | 7f26e86451a5857fb7096fb4321743f51ac22dd0 | e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 |

The tracked-diff fingerprint is SHA-256 over git diff --binary HEAD bytes, with diagnostics excluded. The new untracked Change files are deliberately outside that fingerprint and checked through their directory scope. The pre-existing Bind_FName.cpp working change was preserved. Other existing untracked work was not edited.

## Requirement-to-task coverage

This is acceptance mapping, not another dependency graph. The frontmatter in tasks.md is the sole DAG.

| Capability / requirement | Owning implementation and proof |
| --- | --- |
| Runtime: engine-free recording and shared database | 2.2, 4.1, 6.2 |
| Runtime: dependency-correct and callable application | 2.4, 3.2, 3.3, 4.2, 6.2 |
| Runtime: pre-installation executable-target validation | 2.4 |
| Runtime: complete primary descriptions and full migration | 1.1, 5.1 through 5.6, 6.1, 6.2 |
| Binding engine: explicit creation and single-use preparation | 2.4, 6.2 |
| Binding engine: adapter and resource isolation | 3.1, 6.2 |
| Binding engine: delegate host-storage lifetime | 3.4 |
| Binding engine: payload execution lifetime | 3.5 |
| Extensions: registration callbacks and conflict behavior | 2.2, 2.3; installed call proof in 2.4 |
| Extensions: provider generations | 2.3, 4.1 |
| Extensions: native enrichment, origin and dispatch | 2.3, 2.4, 6.1 |
| Extensions: supported public boundary | 2.1, 6.1 |
| Observability: phase and work attribution | 1.2, 4.1, 4.2, 6.3 |
| Observability: owned/shared memory and real trace attribution | 1.2, 6.3 |
| Observability: validated comparable performance samples | 1.1, 1.2, 6.3 |
| Class/SDK/UE/directory responsibilities and compatibility | 2.1, 2.4, 3.1, 3.2, 5.1 through 5.6, 6.1 |
| Final evidence and durable-spec handoff | 6.4 |

## Intentionally not run

No Unreal build, UE Automation, complete RuntimeBindings/NativeEngine suite, benchmark, Memory Insights capture, generated-wrapper build, UHT generation, Python product test suite or broader Harness Quick/Performance/Integration suite was run. This delivery changed only planning documents and a source inventory; these product checks belong to the future tasks. In particular, this record does not claim the four reported defects or automatic adapter reconstruction have been fixed.

No implementation task was checked off, no active neighboring Change was edited, no current durable spec was synchronized, no Review was started and no commit, integration, push or workspace removal was performed.

