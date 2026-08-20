## 1. Record the discussion and Spec Kit bar

**Delivers:** Planning notes on disk, isolated from apply.  
**Independent Test:** `attachments/INDEX.md` routes planning vs implementation; `attachments/planning/` has the discussion pack; `attachments/implementation/` has the apply working set.  
**Blocks later groups:** yes.

- [x] 1.1–1.7 <!-- Non-TDD --> Prior recording (conversation, Spec Kit extract, gap, clone, customization, explore, prompts, attachment conventions, progressive-log pattern). See `attachments/planning/progress.md`.

> 组 1 已完成。实现时不要打开 `attachments/planning/`，除非当前 task 卡住。

## 2. Inject the contract (later)

**Delivers:** `config.yaml` and `openspec-work` state the same required fields, multi-line task body, planning/implementation isolation, and OpenSpec-refactor logging.  
**Independent Test:** `openspec instructions tasks --change improve-openspec-task-guidance --json` includes `rules.tasks`; `openspec-work/SKILL.md` has no start-lean for `feature`/`fix`/`refactor`/`improve`/`test`; skill tells apply to skip `attachments/planning/` unless stuck.  
**Depends on:** group 1.

- [ ] 2.1 <!-- Non-TDD --> Add `openspec/config.yaml` with context and `rules.tasks` matching `specs/openspec-task-guidance/spec.md`.
  - Files: Create `openspec/config.yaml`
  - Impact: All later `/opsx:propose` and `openspec instructions tasks` in this repo; no runtime code
  - Tests: No — process config only. Confirm with `openspec instructions tasks --change improve-openspec-task-guidance --json` that `rules` lists Files/Impact/Tests
  - Verify: `openspec instructions tasks --change improve-openspec-task-guidance --json`
  - Requirement: Guidance is injected not optional chat; Executable task line

- [ ] 2.2 <!-- Non-TDD --> Rewrite `.agents/skills/openspec-work/SKILL.md`.
  - Files: Modify `.agents/skills/openspec-work/SKILL.md`
  - Impact: All OpenSpec sessions in this repo. Lean only for `chore`/`docs`. Apply reads `attachments/implementation/` only. Planning notes are blocked unless stuck. Mid-change OpenSpec edits append `attachments/implementation/openspec-refactors.md`. Apply-time findings go to `implementation/issues.md`, not `tasks.md`.
  - Tests: No — skill text. Grep that "start lean" is not the default for feature/fix/refactor/improve/test
  - Verify: Read the skill; confirm isolation and multi-line task rules are in the record-artifacts / implement steps
  - Requirement: Guidance is injected not optional chat; Apply follows group boundaries; Attachment isolation; Progressive execution record; Mid-change OpenSpec refactor is recorded

- [ ] 2.3 <!-- Non-TDD --> Align OpenSpec sections of `AGENTS.md` and `AGENTS_ZH.md` with 2.1–2.2.
  - Files: Modify `AGENTS.md`; Modify `AGENTS_ZH.md`
  - Impact: Agent always-on instructions. Do not add Spec Kit clone catalog. Do not restore start-lean-for-all-types.
  - Tests: No — docs
  - Verify: Grep those files for start-lean / attachments/planning isolation
  - Requirement: Guidance is injected not optional chat; Attachment isolation

## 3. Optional schema fork (later, only if 2 is ignored)

**Delivers:** Forked schema or an explicit "config is enough" note.  
**Independent Test:** Validated `openspec/schemas/angelscript` exists, or `design.md` Open Questions says no fork.  
**Depends on:** group 2.

- [ ] 3.1 <!-- Non-TDD --> Decide whether to fork `spec-driven` after 2 is in use.
  - Files: Maybe Create `openspec/schemas/angelscript/**`; Maybe Modify `openspec/config.yaml`; Modify `design.md` Open Questions
  - Impact: Default schema for new changes if forked; otherwise none
  - Tests: No — if forked, `openspec schema validate angelscript`
  - Verify: `openspec schema validate angelscript` or the written no-fork decision
  - Requirement: Guidance is injected not optional chat
  - Note: If this decision changes OpenSpec layout mid-change, append `attachments/implementation/openspec-refactors.md`

## 4. Smoke the new bar (later)

**Delivers:** One sample `tasks.md` rewritten to the multi-line contract.  
**Independent Test:** Sample tasks have indented Files / Impact / Tests; no slogan one-liners.  
**Depends on:** group 2.

- [ ] 4.1 <!-- Non-TDD --> Rewrite one thin existing or throwaway `tasks.md` to the template; do not implement that sample.
  - Files: Modify that sample change's `tasks.md`; Create `attachments/implementation/` before/after note if needed
  - Impact: Sample record only; no product code
  - Tests: No — format check against `attachments/implementation/task-body-template.md`
  - Verify: Every behavior-changing checkbox in the sample has Files, Impact, Tests
  - Requirement: Executable task line; Requirement trace and parallel markers
