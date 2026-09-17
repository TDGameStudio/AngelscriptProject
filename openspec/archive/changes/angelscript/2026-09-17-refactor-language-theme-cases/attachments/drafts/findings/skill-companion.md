# Test Skill must move with the contract

Source: exploration finding `skill-companion.md` (Chinese).

The live Skill still teaches `Language/Syntax/StructFields` as `root` / `add-field` / `invalid-duplicate-field`, and `references/test-code-database.md` still requires exactly one parentless node named `root`.

This Change must update, together:

```
.agents/skills/angelscript-test/SKILL.md
.agents/skills/angelscript-test/references/test-code-database.md
openspec/specs/angelscript/testing/code-database/spec.md
openspec/specs/angelscript/testing/language-fixtures/spec.md
openspec/specs/angelscript/testing/code-database/knowledges/negative-script-vs-fixture-protocol.md
```

`cqtest.md` and `legacy-source-isolation.md` do not describe container grammar. `Documents-old` is out of scope.
