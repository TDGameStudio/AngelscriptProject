# Final verification and scope

## Observed runtime proof

Task Evidence retains each actual grouped RED/GREEN command and result. The final
integration selection ran against the implemented runtime and passed:

```powershell
pwsh -NoProfile -File .agents/skills/harness/tests/HarnessLifecycle.Tests.ps1
pwsh -NoProfile -File .agents/skills/harness/tests/Harness.Tests.ps1
pwsh -NoProfile -File .agents/skills/harness/tests/HarnessMutationGate.Tests.ps1
pwsh -NoProfile -File .agents/skills/harness/tests/HarnessEvolution.Tests.ps1
pwsh -NoProfile -File .agents/skills/harness/tests/Test-Harness.Tests.ps1
```

HarnessLifecycle executes the real temporary-repository closure fixture with
Create and Replan, the incomplete closure fixture with a real plugin, and two
binary/shared-file withdrawal tests. It covers normal-hook rejection, exact
recovery, primary/replica record ownership, checkpoint/withdrawal/carryover,
preserved unrelated staging and truthful queue advancement. Fake host approvals
remain confined to those fixtures and never authorize the actual Change.

Earlier direct selections for tasks 1.1–1.6 and 2.1 passed on the same runtime
content or were superseded by a final integration run of their affected path:
GitOperations, PluginCommits, HarnessChangeGate (including the added missing-link
preflight), HarnessHandoff, HarnessWorkflow, HarnessQueue, HarnessFeedback,
HarnessDraft and direct Replan/queue/execution/withdrawal Python cases. The
queue/execution unit runs contained 25 and 36 cases respectively. Do not add
overlapping fixture counts as if they were distinct behaviors.

Final integration exposed stale main-fixture expectations for the old feedback
JSON/inbox and ordering of native init after newly created draft content. A
bounded native reproduction returned the documented pre-manifest-layout
rejection. The fixture now initializes its record repository before capture,
checks actual source and the single owning draft, and separately checks the
explicit grouped feedback view. The production init/feedback rules were not
weakened. The test-inventory counts were updated for its three new fixtures;
its correctness-only performance samples are not a latency claim.

## Guidance, specification and consumer proof

`Protocol.Tests.ps1 -ActiveChange harness/feature-lifecycle-git-closure` passed.
The focused OpenSpecSkill audit passed with SurfacePaths selecting the OpenSpec
and lifecycle Skills, Brainstorming, explaining-work, harness/core and harness/git.
It checks authoring examples, package safety, links and knowledge indexes.

Both affected current specs passed strict native validation before and after
the semantic merge. `spec-sync-audit.json` retains baseline digests and exact
Requirement/Scenario names. Unspecified cards/requirements retained their full
logical Markdown. Old feedback-storage and parent-stage scenarios were explicitly
included as same-name replacements, and legacy hook formatting was qualified
against the already accepted expected-revision contract. These align the existing
scenario owners with the approved design, without a new behavior choice or archive
migration. Original accepted candidate exports remain unchanged.

Seed and plan verification and exact Change strict validation passed. Final
terminal verification and the content-bound close preview are recorded by their
actual route results; no real final approval, commit or archive is claimed here.

`lifecycle-consumer-audit.md` separates actual independent consumer outputs from
runtime proof. Matched four-turn discussion arms both continued; the historical
premature stop did not reproduce. Current Gate branches retained pending and
cancelled forms and respected host capability limits. Explanation consumers
actually read relevant source/spec/knowledge and retained feedback in one topic.
The isolated factual-publication branch published and later reread one article
and its unique INDEX entry. All original responses and submitted synthetic forms
are indexed raw evidence. No UI-render, comprehension or numerical reliability
claim follows from these bounded exercises.

## Known audit boundaries and omitted work

- Default Protocol remains non-green on four missing-proof fields in unrelated
  `angelscript/refactor-builder-source-entry` issue
  `issue-20260913-105100-shared-source-makes-emit-real.md`. The unchanged HEAD
  Protocol reproduced the same failure. The explicit ActiveChange selector only
  narrows active material-issue ownership; all other checks still execute.
- Default OpenSpecSkill language audit rejects original-language provenance and
  raw consumer evidence, including 24 lines already present in this Change's
  unchanged HEAD origin and an unrelated active draft export. Do not rewrite real
  user/export sources to disguise a global pass. The maintained Skill/spec surface
  passed its supported scoped audit. A source-backed, unselected question remains
  in ignored topic `harness/lifecycle-validation-feedback`, scope
  `source-evidence-language`; capture is not a selected repair or successor Change.
- Existing historical archive format failures may appear in the CLI's aggregate
  archived selector. Actual close checks the exact archived item and cannot infer
  aggregate success. Historical records remain unchanged.
- No Unreal build/Automation run was selected: there is no product C++/AngelScript
  or UE behavior change. No broad performance profile or statistical LLM benchmark
  was selected. The affected runtime uses direct/integrated hermetic fixtures.
- No push, integration, workspace removal or old-workspace cleanup is included.
  Reference/README.md, _scratch_prec.py and the unrelated diagram remain outside
  this Change. The source draft's old INDEX-compatibility question and separate
  workspace-backlog draft keep their previous dispositions.

## Persistence boundary

The planning commit is 2afe4b9090a3fc849545ee6301b2b83839fa8f84. Implementation,
current specifications/knowledge, tests and final evidence await the actual exact
close Gate. The owning source manifest captures the final non-Change file bytes;
the terminal input digest binds the Change records. Later generated close receipt,
source checkpoint, evaluation refresh and native manifest/archive move are named
derived outputs of that preview, not unseen implementation additions.
