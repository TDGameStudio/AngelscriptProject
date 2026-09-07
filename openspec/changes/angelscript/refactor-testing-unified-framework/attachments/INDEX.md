# Attachment index

## Current status and reading order

This Change is **planning-only**. The authorized delivery creates its proposal,
design, delta specs, future tasks, and supporting evidence/examples. It does not
implement the framework or modify current Skill/specification behavior.

When resuming, read `../tasks.md` and this index first, then the one focused
attachment needed for the selected task. `../design.md` owns implementation
decisions; delta specs own proposed durable behavior. Every new symbol shown in
an attachment is proposed until its future implementation task is verified.

## Accepted decisions

- Preserve `FAngelscriptTestCode` as the sole public AS source center; merge
  ScriptCorpus/Snippet source responsibilities into it. SourceStore is internal.
- Keep file-based TestSource authoring and deterministic plugin-owned embedded
  C++ release generation; runtime consumption needs neither Python nor TestSource.
- Support external AS, terse `AS_TEST_SOURCE(...)`, exact inputs, and AS-free C++.
- Use `SourceId + VersionTag`; source ancestry and C++ reload operation order are
  separate. Local inline source receives case scope on logical-file binding.
- Keep ordinary CQTest; typed data fixtures inherit `Assert` and expose member
  `Run(const FRow&)`. Independent rows use `.Rows.<RowId>` public identities.
- Separate source input, case/oracle truth, and run evidence. Availability,
  structural validation, and embedding are never evidence of runtime execution.
- Keep legacy runtime/tests dormant and authoring helpers within the replacement
  module. Keep scenario flow visible and class-only helpers inside their class.

## Indexed supporting material

| Artifact | Purpose | Read when |
|---|---|---|
| [Class contracts](data/class-contracts.md) | Proposed class-to-file map, concrete C++ signatures, errors, ownership, source/history/catalog/data fixture/Automation/report lifecycle, and call examples | Implementing or checking an interface landing decision |
| [Provenance](data/provenance.md) | Classification of current implementation, historical prototypes, and source evidence | Checking what exists today and what can be selectively reused |
| [Planning validation](data/planning-validation.md) | Document checks and evidence that this delivery performed no implementation | Checking the planning-only delivery result |

The coordinating author adds other completed attachments to this table once,
without copying their contents into this index.

## Forbidden completion shortcuts

- Do not apply C++, Python, generator, test, or Skill changes in this delivery.
- Do not mark future tasks checked because the design is detailed or valid.
- Do not change the concurrent Builder Change or invent its unsettled APIs.
- Do not restore legacy gates, engine pools, force includes, or old test roots.
- Do not apply, synchronize current specs, archive, commit, integrate a worktree,
  or publish generated resources because planning validation passes.
- Do not report unexecuted cases, skipped capability, or generator success as PASS.

## Evidence boundary

The framework inventory and historic prototypes are design evidence. Future
verification records must identify the exact selected workspace, command, result,
and artifacts. The current delivery validates documents only; it makes no fresh
Unreal build, Automation pass-count, or runtime reload claim.
