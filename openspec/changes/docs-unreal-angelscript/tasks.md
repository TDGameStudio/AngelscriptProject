## 1. Scope And Inventory

- [ ] 1.1 <!-- Non-TDD --> Inventory current naming references with `rg -n "AS 2\\.33|AngelScript 2\\.33|2\\.33 \\+|2\\.38 compatibility|selective 2\\.38" README.md AGENTS.md AGENTS_ZH.md Documents Plugins -g "*.md"`.
- [ ] 1.2 <!-- Non-TDD --> Classify each relevant occurrence as product identity, runtime/fork version, upstream lineage, or historical/archive text.
- [ ] 1.3 <!-- Non-TDD --> Decide whether the first owned runtime label is `UEAS Runtime 1.0`, an unnumbered `UEAS Runtime`, or a date-based version such as `UEAS Runtime 2026.1`.

## 2. Documentation Updates

- [ ] 2.1 <!-- Non-TDD --> Update `README.md` so the project identity is `Unreal AngelScript` and the runtime label is no longer presented as plain `AS 2.33`.
- [ ] 2.2 <!-- Non-TDD --> Update `AGENTS.md` and `AGENTS_ZH.md` so agent guidance distinguishes `Unreal AngelScript`, `UEAS Runtime`, and upstream AngelScript lineage.
- [ ] 2.3 <!-- Non-TDD --> Update `Plugins/Angelscript/README.md` to use consumer-facing `Unreal AngelScript` terminology without implying module or directory renames.
- [ ] 2.4 <!-- Non-TDD --> Update `Documents/Guides/AngelscriptForkStrategy.md` to state that `AS 2.33` is lineage metadata, not the current runtime version label.
- [ ] 2.5 <!-- Non-TDD --> Update any additional non-archival docs found in task 1.1 where `AS 2.33` is being used as the product or runtime identity.

## 3. Validation

- [ ] 3.1 <!-- Non-TDD --> Run `openspec validate docs-unreal-angelscript --strict` and fix OpenSpec formatting issues only.
- [ ] 3.2 <!-- Non-TDD --> Re-run the naming inventory command from task 1.1 and record intentional remaining lineage references.
- [ ] 3.3 <!-- Non-TDD --> Run `git diff -- README.md AGENTS.md AGENTS_ZH.md Documents/Guides/AngelscriptForkStrategy.md Plugins/Angelscript/README.md openspec/changes/docs-unreal-angelscript` to review the final documentation-only scope.
- [ ] 3.4 <!-- Non-TDD --> Do not run build or automation tests unless implementation scope expands beyond documentation.

## 4. Stop Point

- [ ] 4.1 <!-- Non-TDD --> Stop after OpenSpec artifacts are recorded; do not implement documentation updates in this session.
- [ ] 4.2 <!-- Non-TDD --> Hand off `docs-unreal-angelscript` as a ready-to-implement OpenSpec change for a later session.
