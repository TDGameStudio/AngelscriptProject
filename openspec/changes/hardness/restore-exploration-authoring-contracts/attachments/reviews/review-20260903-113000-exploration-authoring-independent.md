---
state: closed
review_result: approve
reviewed_at: 2026-09-03T11:30:00+08:00
closed_at: 2026-09-03T11:30:00+08:00
review_scope: Task-owned exploration, active-Change checkpoint, executable authoring, material-issue, attachment-index, archive-immutability, capability-knowledge, English-maintenance, protocol-test, and root-README lifecycle changes
snapshot:
  base_head: 7f4e8667cf7a987111d8b3fc47da10401540ee90
  manifest_entry_count: 29
  manifest_sha256: 4f65a6b6693ea7c0ede7a5747dd1e7214156f46c558df413728da3ca2fb0838c
  manifest_algorithm: "sorted ordinal UTF-8 lines of kind + TAB + path + TAB + lowercase SHA-256 + LF; tracked entries hash the LF-normalized git binary diff from base, new entries hash file bytes, and README hashes the explicitly listed task-owned base/current line projection"
  tasks_sha256: cd9cc07055739342c0fcdf504a354b7aec45289bb1e0e243beb07f9880d72c23
verdict: APPROVE
---

# Exploration and Authoring Independent Review

The fixed working-tree snapshot is approved. The reviewed Skills, references, protocol tests, durable specification, and active recovery Change restore the required lifecycle without reviving a second workflow: deep Explore is read-only and pre-target-Change only; after creation, Continue/Update/Apply and evidence-gated Hardness Replan own the lifecycle; Apply requires the canonical active Change and OpenSpec-derived Ready node before implementation mutation. No Critical, Required, or Advisory finding was identified.

This review was performed directly because `AGENTS.md` currently disables all Skills. The review file is the sole review output and is excluded from the reviewed snapshot. The coordinator still owns INDEX registration, Task `4.1` completion, issue resolution, knowledge promotion, closure, staging, and commit scope.

## Contract Review

- **Explore boundary:** `openspec-explore` and its progressively loaded references require repository evidence, scope, viable options, an evidence-backed recommendation and flip condition, risks/failures, verification, and an OpenSpec handoff before target Change creation. They prohibit post-creation invocation and task-local use. The routing, Continue, Apply, OpenSpec, root OpenSpec README, durable spec, and project instructions agree.
- **Post-creation lifecycle:** Continue creates only the next missing artifact; Update revises existing truth and records an applied Replan only when evidence invalidates planning; Apply resolves `task.status`, reads current artifacts and the attachment INDEX, selects only a derived Ready node, keeps local uncertainty inside that node, and escalates only invalid current truth.
- **Canonical recovery:** the active manifest, proposal, design, delta spec, Task DAG, INDEX, open issue, and applied Replan preserve that implementation began before registration and was detected before commit. They do not fabricate pre-existing compliance. The Replan correctly moved issue resolution and knowledge promotion behind this Review; its recorded result hash is reproducible from the post-Replan Task DAG before Task `3.4` was checked.
- **Executable authoring:** the Task reference requires a file/artifact/exclusive-resource map, independently reviewable outcomes, exact or explicitly bounded paths, cross-node inputs/outputs, exact proving commands, requirement/acceptance coverage, permanent IDs, and concrete nested execution steps. Plan-only output is explicitly required to need no second planning pass.
- **Material issues and INDEX:** the new issue contract limits `attachments/implementation/` to one demonstrated root-cause lifecycle per material issue, distinguishes it from routine RED/GREEN work, defines status-specific frontmatter and proof limits, and requires same-edit INDEX registration. Protocol fixtures exercise valid/resolved, invalid, missing-INDEX, status-field, evidence-section, exact-command/reference, and duplicate-task-state cases. The active recovery issue conforms while honestly remaining open.
- **Archive immutability:** no task-owned archive file changed. Protocol code audits existing `closure-v1` archives read-only for a present, bounded INDEX and exactly one reference to each attachment; it does not rewrite historical issue bodies or use archived tasks as execution state.
- **Capability knowledge:** the focused reference admits only evidence-backed, repaired, verified, re-reviewed, cross-task learning into capability-local `knowledges/`; requires one INDEX entry per knowledge file with summary, served requirement/capability, provenance, and status; prohibits a project-level parallel tree and automatic archive promotion. The new Hardness core INDEX covers the two existing knowledge files exactly once. The recovery checkpoint itself is deliberately not promoted until Task `4.3`, after this Review.
- **Language and stale lifecycle:** maintained Skill/OpenSpec task-owned records contain no Han text. The package test scans maintained OpenSpec/Skill surfaces, checks local links, guards the current lifecycle vocabulary, and rejects stale root README entries. The reviewed root README replaces `openspec-work`, `/opsx`, global npm/Node CLI, Superpowers, arbitrary ordering, rewritable-task, and non-gated archive guidance with the split Hardness/OpenSpec lifecycle.

## README Ownership Boundary

The root `README.md` contains mixed work relative to the fixed base. This approval includes only the Hardness/OpenSpec lifecycle replacements represented by current lines `138`, `164`, `168-169`, `171`, `174-176`, `179`, `181`, `281`, `305-310`, `312`, `345`, and `365`, paired with base lines `138`, `164`, `168-169`, `171`, `174-177`, `180`, `182`, `282`, `305`, `307`, `340`, and `360`.

The following pre-existing user hunks are explicitly unrelated and excluded from this review and from the task-owned staging claim:

- bootstrap command replacements at current lines `204` and `210`;
- `Documents/Guides/OpenSpecSystemRefactor.md` navigation additions at current lines `285` and `366`.

The task-owned README projection hashes to `e830b6d6943a79c98455c77602cad75329f1c3d19918e6962c60b55d2c496bf8`. The projection algorithm concatenates `B<line><TAB><base text>` for the listed base lines and `C<line><TAB><current text>` for the listed current lines, in listed order, as UTF-8/LF with a final LF.

## Verification Evidence

The review accepts the supplied exact evidence and performed focused static checks against the current snapshot:

- strict active validation: PASS;
- `quick_validate.py` for the five changed Skill directories: PASS;
- `OpenSpecSkill.Tests.ps1`: PASS;
- `Protocol.Tests.ps1`: PASS;
- PS7 Quick: `5/5` PASS — Hardness `18547 ms`, GateContract `4863 ms`, Protocol `898 ms`, Workspace `47302 ms`, OpenSpecSkill `5644 ms`;
- `git diff --check`: PASS;
- targeted Han scan of the task-owned maintained Skill/OpenSpec records: no matches;
- current `tasks.md` SHA-256: `cd9cc07055739342c0fcdf504a354b7aec45289bb1e0e243beb07f9880d72c23`;
- applied Replan result SHA-256 `be6c80897f20f7388efce489480b5267673261e5b25a5de1ae67df7b8b74892f` reproduces when the later Task `3.4` completion-state change is removed.

Full Quick was not rerun during review. UE, Editor, Automation, StaticJIT, Performance, Integration, Standalone, binary/package publication, and `Tools/openspec` gates are outside this Skill-only change.

## Snapshot Manifest

Each `tracked-diff` digest covers that path's complete `git diff --binary --no-ext-diff --no-color` from base, normalized to UTF-8/LF. `tracked-partial-diff` is the root README projection described above. Each `new-file` digest covers exact file bytes. The sorted entry list, with a final LF, hashes to `4f65a6b6693ea7c0ede7a5747dd1e7214156f46c558df413728da3ca2fb0838c`.

```text
new-file	.agents/skills/openspec-explore/references/deep-exploration.md	d661e71d6c4a9b7541a0e27fb5135cca0b32d06eda7a1d88dba859ece7187cf8
new-file	.agents/skills/openspec-explore/references/question-rounds.md	d494a4e5a0ad9a39145be7f7612b462646e5aefdc09154730e813ab10ef15b5b
new-file	.agents/skills/openspec/references/implementation-issues.md	2be93b72c09a289580cfa4927c4aedd74714f660aa64c5ea1cc49cc1e1b315d3
new-file	.agents/skills/openspec/references/knowledge.md	a3985c0cf89db383f0f180c15cbd30c6d731ad585493ea39b6fe25cddf8dc97a
new-file	openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/implementation/issue-20260903-111408-change-created-after-implementation-start.md	63811d2084220ecdb471e0d46128bbcb6642a835cf139373a5ebb918ff7cfbd3
new-file	openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/INDEX.md	98ab2ed11d1775669cd933753c382a8829125967349c7ab3a3c51bbc8562bedb
new-file	openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/replans/replan-20260903-112507-order-review-before-knowledge-promotion.md	2ae4d2b8e4db06afdb04cc57db092ff2c3410973b27760ff0b77daaec0be6d60
new-file	openspec/changes/hardness/restore-exploration-authoring-contracts/change.yaml	724edcf414fd190fe91178cdfdb51390d4eced112510f2909131d1f26e1a7030
new-file	openspec/changes/hardness/restore-exploration-authoring-contracts/design.md	4669a6916e68827fc6c783fd625b22c0cd99b4e6c6a2a3f035aea5946cae7ca5
new-file	openspec/changes/hardness/restore-exploration-authoring-contracts/proposal.md	6aff74e104a6d833c947a5c9761e4ce8d940f1a70672640f1895156f70e38539
new-file	openspec/changes/hardness/restore-exploration-authoring-contracts/specs/hardness/core/spec.md	071b8125462bc2e423db796443c6a985ecb8325f961d7300e098c572a0c822ca
new-file	openspec/changes/hardness/restore-exploration-authoring-contracts/tasks.md	cd9cc07055739342c0fcdf504a354b7aec45289bb1e0e243beb07f9880d72c23
new-file	openspec/specs/hardness/core/knowledges/INDEX.md	7669b5aaf1e986a7f02588784ea4770f8d609ab439af5448c1bca905a7677d5c
tracked-diff	.agents/skills/hardness/references/routing.md	7f53e66b7f75fdc787032c52ca6ca96ad9bf6a085589d75df40b1c3b28fab875
tracked-diff	.agents/skills/hardness/SKILL.md	e0be1d476c4f01331474d814f946ced96127235666d1676afca304764d08b425
tracked-diff	.agents/skills/hardness/tests/Protocol.Tests.ps1	1005bfee3d5ebf8448b170a73ede6f752dcd89e62a42d17262dfe88c4dafdabe
tracked-diff	.agents/skills/openspec-apply-change/SKILL.md	abb80a8e9653a672c8ce652b5b7eaaaf4126b69eae5f7e69ad224be0c759f9d5
tracked-diff	.agents/skills/openspec-continue-change/SKILL.md	daba0fd371f972c4171ec394f066e0dc60618a410ca33b75a6abe7792fc5f8a8
tracked-diff	.agents/skills/openspec-explore/SKILL.md	fa524a56bf092078304d0e7f45b39e058a1fccf47277afe6301bf6d562858974
tracked-diff	.agents/skills/openspec/references/attachments.md	3ac861de0657b937b5c8b11ad84c34ea6f3576e91aebfeb0b4a7f66817b29f2c
tracked-diff	.agents/skills/openspec/references/record-schema.md	e849dab38132a7d27279a2cc27fedaab1bdd2f8470397425956be38282efa6ad
tracked-diff	.agents/skills/openspec/references/tasks.md	67213d0a00390a26a045cdf6061aa7ef77013aa5e0a13b6524e0a0964b5b3ba3
tracked-diff	.agents/skills/openspec/SKILL.md	9f1bc963686149e8ac98ead142215c991f32eea778dc2af3254bd3cb10f134a6
tracked-diff	.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1	45b7a660d640c3d43a584856557efdf4145683609a25a73419ffd967f3543e5d
tracked-diff	.agents/skills/README.md	a3092e9edbd53316cc3006c0e719f6c2ba6826f9018f74a2fa5dbbeea97f77a2
tracked-diff	AGENTS.md	8267d3c8b324a6aedadd60a21a9e054b8351c0c29d5559e33d2470b6ead7344d
tracked-diff	openspec/README.md	47c66133317d3edb243b7394ea519a4c729b1b66cbfca8d3b31207f674c58eb2
tracked-diff	openspec/specs/hardness/core/spec.md	dcbe1415fa77df22a2186142681ba4ee036b06503d6822d18b446e39ed06f75a
tracked-partial-diff	README.md	e830b6d6943a79c98455c77602cad75329f1c3d19918e6962c60b55d2c496bf8
```

## Excluded Scope

The approval excludes all unrelated dirty or untracked files, the inactive `.agents/skills/openspec-work/_SKILL.md` draft, binaries, `Tools/openspec`, plugin submodules, generated JIT output, bootstrap/tool refactors, UE/runtime code, StaticJIT, Performance, Integration, Standalone, and all root README hunks identified above as unrelated. No conclusion here stages, commits, archives, syncs specs, promotes knowledge, resolves the open issue, or authorizes merge, push, publication, or deletion.

## Findings

No Critical, Required, or Advisory finding.

## Decision

**APPROVE.** Close this independent review for Task `4.1`. The coordinator may register this file in `attachments/INDEX.md`, complete Task `4.1`, then execute Task `4.3` to resolve the recovery issue and promote the generalized active-Change checkpoint before final closure.
