---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260905-110535-windows-archive-watch
status: resolved
source: dogfooding
source_ref: 1a5ba7fa8957414e96a8520fec83b787
affected_tasks: ["3.4"]
created_at: 2026-09-05T11:05:35+08:00
resolved_at: 2026-09-05T11:13:13+08:00
resolution_ref: Tools/harness-web/tests/adapter/workbench.test.ts
---

## Symptom

The valid completed Change could not be moved to the archive while Harness Web watched the selected Windows workspace. Portable OpenSpec reported access denied during the directory move. The active manifest remained unchanged.

## Investigation Log

The terminal gate passed before archive. A read-only inspection confirmed that the archive failure occurred at the directory move. Isolated Git/OpenSpec fixtures then separated the listener from filesystem permissions: moving the same record succeeded while an app with watch disabled remained running; failed with EPERM while native watching was active; and succeeded immediately after closing that fixture app. A separate isolated process with Chokidar polling enabled also moved the record while watching remained active.

## Root Cause

Windows native fs.watch directory handles prevent the required external rename. Chokidar polling uses fs.watchFile instead and did not retain that directory lock in the isolated reproduction. Native and polling selection must be per workspace watcher, without global environment changes that could affect Vite.

## Disposition

Implement Windows polling with a bounded interval over the already pruned permitted tree. Preserve atomic-write event handling, external archive operation, and continued invalidations after the move. Task 3.4 owns the repair and focused regression; task 3.3 remains the independent visual refinement.

## Evidence

### Failure Evidence (RED)

`Invoke-Harness -Command openspec.change -Context $context -ArgumentList @('archive','harness/feature-web-workbench','--closure-file','openspec/changes/harness/feature-web-workbench/attachments/data/closure.yaml','--json')` failed at the directory move in Harness run 1a5ba7fa8957414e96a8520fec83b787. The ignored package .cache/archive.json retains the envelope; this record retains the failure boundary and outcome.

| Isolated condition | Rename while app is running |
| --- | --- |
| watch disabled | succeeds |
| native watch enabled | EPERM |
| native watcher closed, same move retried | succeeds |
| polling enabled with 500 ms interval | succeeds |

### Resolution Evidence (GREEN)

`npm.cmd --prefix Tools/harness-web run test:adapter` passed 17/17 after the repair, including a new regression that invokes the actual packaged CLI to archive an isolated Change while its watcher stays alive, observes old/new catalog paths and confirms search invalidation after a later edit to the moved document. The same batch verifies an environment override that disables polling fails before native handles are opened. Server TypeScript passed. The final combined package run is recorded in data/verification.md after task 3.3 completes.

### What This Proves

The native Windows directory watcher is the cause of the observed lock; polling removes it in the isolated experiment.

### What This Does Not Prove

The evidence is not a performance benchmark or proof of all external file operations. It proves the required native archive and post-move refresh boundary with independent temporary Git fixtures.

## Links

- Task 3.4 in tasks.md.
- data/verification.md for prior application acceptance and closure boundaries.
