---
replan_id: replan-20260915-083041-entry-names-and-case-exports
status: applied
source: user
source_ref: current-session-pascalcase-full-case-export-and-directory-requests
scope: canonical entry spelling, one generator test and complete run-local case artifacts
base_commit: acb127e8539638b0a2ff6392b894d976a81b5bdb
base_tasks_sha256: 759e8bdab210f7f4b81df3e621c9cba696c4114058fef102c6db1f4b64b92fff
result_tasks_sha256: cc20502da78a2af56f8ecd293342319b94658cb9b0e227cfdfb9317b6833bfda
created_at: 2026-09-15T08:30:41.548847+00:00
resume_task: '1.1'
---

# Readable entries and complete artifact export replan

## Trigger and Evidence

The user explicitly requested camel-style entry names without underscores, all individual .as sources beside the test log and one unit test per generator. Harness run paths and UE 5.8 absolute-log resolution were inspected. Existing tests use aborting assertions, requiring export attempts before aborting verification to retain useful artifacts.

## Decision

Use EntryPascalCaseId and keep CaseIds stable. Each generator exposes one GeneratesAndExportsAllCases unit-test method; full canonical sources and a descriptor index are saved under the actual log parent's GeneratedCases/<ClassWithoutF> directory. C++ implementation remains in the plugin Framework/Generate; tests and the I/O helper remain in FrameworkTests.

## Impact

Task 1.1 adds the test-only exporter and consolidates ForLoop's old assertions while migrating gold entry names. All product tasks add full-export checks and exact single-method selectors. The final task owns one VerifiesCompleteCorpus method and no repeated exports.

## Old Task Disposition

All 123 pending task IDs remain. No completed work is unchecked. The five existing ForLoop assertion scenarios are retained within one method; their old individual method identities intentionally change under the user's explicit grouping request.

## Diff Snapshot

- Affected parent Change directory was untracked; no plugin implementation file is changed by this planning operation.
- Task ~: every product interface example, selector, naming/export checks; 1.1 shared test helper and existing gold; 14.1 registration/name verification.
- Edges: unchanged from the case-descriptor replan; 1.1 precedes the other 121 products, and 14.1 depends on all products.
- Artifacts ~: proposal, spec delta, design, tasks, glossary/seed precedence, catalogs, inventory and planning evidence.
- Attachments +: this immutable applied record and one decision talk, indexed exactly once.
- Candidate validation before writes: identical 123-node DAG, no lost IDs and exactly 122 single-method product selectors.

## Preserved Work

The 122 products, 36,686 target cells, owned descriptors, aggregate and per-case APIs, typed builder defaults and source-only verification boundary remain. Existing runnable product C++ is not changed yet.

## References and Result

The current design fixes the path derivation, filename mapping, JSON index fields and partial-failure behavior. Resume at 1.1 after strict validation; actual exports are produced only when implementation tests run.
