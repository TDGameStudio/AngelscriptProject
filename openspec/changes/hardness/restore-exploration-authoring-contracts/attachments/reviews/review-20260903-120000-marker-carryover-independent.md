---
state: closed
review_result: approve
reviewed_at: 2026-09-03T12:00:00+08:00
closed_at: 2026-09-03T12:00:00+08:00
review_scope: Marker vocabulary, pre-Change exploration carryover, post-creation attachment routing, dogfood records, Replan/DAG expansion, specifications, and focused semantic tests added above the approved 29-entry baseline
snapshot:
  base_head: 7f4e8667cf7a987111d8b3fc47da10401540ee90
  approved_baseline_manifest_sha256: 4f65a6b6693ea7c0ede7a5747dd1e7214156f46c558df413728da3ca2fb0838c
  incremental_manifest_entry_count: 17
  incremental_manifest_sha256: e1b5ed699cd26080ca715ea225f0b33f05d6be0a11967966ec2ddc53ab0ca6f2
  incremental_manifest_algorithm: "sorted ordinal UTF-8 lines of kind + TAB + path + TAB + lowercase SHA-256 + LF; incremental patches hash the LF-normalized git binary worktree diff above the staged approved/post-Review baseline, and new files hash exact bytes"
  expanded_tasks_sha256: abfd3fdbb4be79271a8cb4d3d3f2463765b89932930cfe590dec404a6ed64ef3
verdict: APPROVE
---

# Exploration Marker Carryover Independent Review

The marker/carryover increment above the previously approved 29-entry snapshot is approved. It restores visual scanning without restoring an emoji state machine, keeps deep Explore read-only and before target Change creation, and selectively carries accepted rationale or reusable knowledge only after the Change exists. No Critical, Required, or Advisory finding was identified.

The approved baseline is the closed `review-20260903-113000-exploration-authoring-independent.md` snapshot with manifest fingerprint `4f65a6b6693ea7c0ede7a5747dd1e7214156f46c558df413728da3ca2fb0838c`. This Review covers only the 17-entry marker/carryover increment below. Project instructions disable all Skills, so the review was performed directly. This file is excluded from its own snapshot; the coordinator owns INDEX registration and later lifecycle work.

## Increment Review

- **Fourteen markers:** ten core markers (`📌`, `❔`, `👉`, `❗`, `✅`, `❌`, `🚫`, `💡`, `🔗`, `📁`) and four temporary round-only markers (`⭐`, `✨`, `⏳`, `🔁`) are explicit. `✅ Settled:` means only an accepted decision, never a passing test. `🔁 Reopened:` replaces historical `🔴 Reopened`; historical `🟢 Landed` is removed, avoiding collision with the visual-explanation red/green risk/heat legend.
- **Plain-language authority:** every glyph has an explicit stable English label and complete prose meaning. Markers are forbidden in YAML, filenames, Task DAG identities/edges, Review or issue state, and commands, and cannot be parsed for readiness, completion, Review, or promotion. Removing emoji leaves the records understandable.
- **Lifecycle boundary:** Explore remains strictly read-only and pre-target-Change. `Exploration Carryover` only classifies accepted handoff material. After creation, Continue performs qualifying capture and never re-enters Explore.
- **Selective destinations:** canonical truth enters proposal/spec/design/tasks; non-obvious rationale and decision-critical visuals enter an indexed talk only when they prevent re-decision; reusable evidence-backed insight or visuals enter indexed change-local knowledge; transcript prose, temporary navigation, and one-off visuals are discarded. Attachments cannot become a second source of truth.
- **Context control and dogfood:** marker guidance is progressively loaded and optional. The talk preserves the option decision and compact visual; the knowledge candidate retains only the reusable classification model, evidence, boundaries, and application. Before this Review, all six attachment files appeared exactly once in the 38-line INDEX, and the knowledge entry was explicitly `candidate` rather than promoted.
- **Promotion order:** Task `4.7` depends on this Review task and alone owns capability promotion plus focused revalidation. Archive does not promote automatically.
- **Replan and DAG:** the user-triggered Replan preserves completed Tasks `1.1` through `4.3`, explicitly supersedes never-executed `5.1`, and adds permanent Tasks `4.4`-`4.7` plus `5.2` in chain `4.3 -> 4.4 -> 4.5 -> 4.6 -> 4.7 -> 5.2`. Its base Task SHA matches the pre-expansion staged record; result SHA `87db5bc08e5b718942d04dcb6290cecafc8a868bb0e34fda27f835fb0dfb7023` reproduces after removing only later `4.4`/`4.5` completions.
- **Tests and specs:** assertions cover marker labels, rejected red/green meanings, pre/post-creation boundaries, carryover destinations/dispositions, transcript rejection, links, and exact-once attachment indexing. Delta and current `hardness/core` specs agree.
- **Scope:** the increment does not touch README, `Tools/openspec`, executables, plugins, UE, StaticJIT, Performance, Integration, or unrelated workspace content. The baseline README mixed-hunk boundary remains unchanged.

## Evidence

Accepted supplied evidence: focused 14-marker/diff check PASS; post-dogfood `OpenSpecSkill.Tests.ps1` PASS; `Protocol.Tests.ps1` PASS; strict validation run `84270aa9b99a429992e00b7a3a582a74` PASS; Task status `10/13` complete with `4.6` Ready.

Targeted read-only inspection additionally confirmed ten core plus four round-only entries, no active historical red/green semantics, six pre-review attachments indexed exactly once, INDEX length 38, no Han text in the increment, and `git diff --check` success. No full Quick or product test was run.

## Incremental Snapshot Manifest

Each `incremental-patch` digest covers the complete LF-normalized `git diff --binary --no-ext-diff --no-color` from the staged approved/post-Review state to the worktree. Each `new-file` digest covers exact bytes. Sorting these 17 lines ordinally and appending LF hashes to `e1b5ed699cd26080ca715ea225f0b33f05d6be0a11967966ec2ddc53ab0ca6f2`.

```text
incremental-patch	.agents/skills/openspec-continue-change/SKILL.md	01725b8535ab355477b4d82e844313d47cdc6ac6df00aecced849bca9df07fac
incremental-patch	.agents/skills/openspec-explore/references/deep-exploration.md	2718f438a7a4002b2d0585007c131d038c7fae5fe8666650354948f9f4d4223b
incremental-patch	.agents/skills/openspec-explore/references/question-rounds.md	f2ced73274daeee81f04913517c3eb735564fca0d91f45c45d66324f13ae24fb
incremental-patch	.agents/skills/openspec-explore/SKILL.md	01930822940a0d80c31fa8a618c1f4b300c4916b7eff3eb6413ad74c809c9846
incremental-patch	.agents/skills/openspec/references/attachments.md	060c491461d21c9f85676da02cf757cf33677e4f610d4cab123406e29721535f
incremental-patch	.agents/skills/openspec/references/knowledge.md	178a4f694b03916a1f73f1edcf80f9f0051818403698375d815b9630e745be48
incremental-patch	.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1	7f32e4d206c7d017e791800d0d98a0e3a5076c8ca5428fdcc9504cccb656aa48
incremental-patch	openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/INDEX.md	39cdddc4cb945dbccbfd1f80bf6d9c174cf22ba1354d379c391e4a997b814d91
incremental-patch	openspec/changes/hardness/restore-exploration-authoring-contracts/design.md	c1d060e5d4045c61aaf4c5a751a6e0a88aa63574beb727d291dee86246750bf3
incremental-patch	openspec/changes/hardness/restore-exploration-authoring-contracts/proposal.md	ee5f77429790b02f9b38a7c37b50d2f2e0feeada94d451e62c4336086701a664
incremental-patch	openspec/changes/hardness/restore-exploration-authoring-contracts/specs/hardness/core/spec.md	71df6133f3b51dceb10f5daec5e08a4a16155882ef0df3ab72bbb3a218f67bfe
incremental-patch	openspec/changes/hardness/restore-exploration-authoring-contracts/tasks.md	e3639917c20d1e9f3c5c3e74c84f9471f060923f6cb6ed0729fe24552a259e21
incremental-patch	openspec/specs/hardness/core/spec.md	1f75008583025f08a5af0c47172a59511fe12bc0c41fc27a311c283a3c034387
new-file	.agents/skills/openspec-explore/references/markers.md	0b831956d71090ba16b2a3718d46e72bf1cc4574d6de46ebc53238084fb49099
new-file	openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/knowledges/exploration-marker-carryover.md	68dbcb6638872c02e51d7b0fd3a6a9b3e294a9cfaddec4dc96a412186a4b5d67
new-file	openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/replans/replan-20260903-115455-preserve-exploration-marker-carryover.md	c434080e3dd09f95583f2a278be194727d71ab5ce49809fa365d6fd56481ddc1
new-file	openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/talks/talk-20260903-115455-exploration-marker-carryover.md	d3c805c2855a1fc110cee5ee8966d264a85567ef684751bdfcd486d59c4ae376
```

## Findings

No Critical, Required, or Advisory finding.

## Decision

**APPROVE.** The coordinator may index this Review, complete Task `4.6`, and execute Task `4.7` to promote only the reviewed reusable carryover guidance before closure.
