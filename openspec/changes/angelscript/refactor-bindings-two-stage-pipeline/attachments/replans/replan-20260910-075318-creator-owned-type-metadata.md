---
replan_id: replan-20260910-075318-creator-owned-type-metadata
status: applied
source: user
source_ref: "User: replan for host-owned C++ metadata, Engine-owned generated metadata, Registry ID/query only"
scope: "Type ownership, neutral registration API, reference lifetime and instance GC"
base_commit: 0f0cf23ee78e563bf93dcf20b43a55381948273d
base_tasks_sha256: 7358352bef9500f8a0a79614a59be8fb1eab4481c8c07c93095b1e5348b2e816
result_tasks_sha256: fa7a0c79e290d11022e919c240703799828dc29407127315b16f1333913c1ee3
created_at: 2026-09-10T07:53:18+00:00
resume_task: 0.1
---

# Applied creator-owned type metadata replan

## Trigger and Evidence

The user accepted explicit host versus Engine ownership and requested this replan. Existing MetadataImage and TypeInfo AddRef/Release already provide graph lifetime. The SDK Change's indexed ownership/GC talk pins source evidence; previous public publication/lease API requirements add unnecessary ownership concepts.

## Decision

Host owns its graph; Engine owns its generated graph; Registry owns only numeric issuance and weak active indexes. Replace PublishExternal/public TypePublication with neutral Register/Unregister and existing MetadataImage. Acquired outputs carry one AddRef. Internal registration state separates withdrawal from memory retention. Host withdrawal rejects live Engine/dependency uses; metadata is not script-object GC, and instance GC uses explicit Engine ownership.

## Impact

Update current proposal/design, complete affected Scenario Cards, tasks, query matrix and indexes; align the binding prerequisite. No implementation, current-spec sync or UE work. Historical review/talk/replan/source evidence stays intact.

## Old Task Disposition

All task IDs, dependencies, unchecked states and proving selectors preserved: SDK 13 tasks, binding 24 tasks. Refine SDK 2.1/2.2/2.4/3.1/3.2/4.2/5.1 ownership and GC cases in place. No +/- tasks or edges; numeric concurrency tasks and final regression scopes remain.

## Diff Snapshot

```text
?? openspec/changes/angelscript/feature-types-external-ownership/
?? openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/
```

No tracked diff: both Change directories were already untracked.

Artifacts ~ current planning, deltas, query/index navigation; + ownership talk, applied replan and later actual validation evidence. Candidate frontmatter graph and checklist equality were verified before canonical writes. Full CLI validation follows application.

## Preserved Work

Process-wide bounded thread-safe issuance, ID non-reuse, generation checks, global host inspection, Engine-private admission, immutable shared graphs, independent VM bindings, source cache contracts, complete binding migration/repairs, scoped formatting corrections and source-bound SDK handoff.

## References and Result

Resume 0.1; downstream 0.1 still requires implemented and verified SDK handoff. See current design/tasks, indexed owner/GC decision and validation evidence. Product tests remain pending and no commit/push is performed.
