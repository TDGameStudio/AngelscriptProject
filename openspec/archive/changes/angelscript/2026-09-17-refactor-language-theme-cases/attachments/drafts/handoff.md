# Handoff: Language theme pockets

Source: draft `designs/theme-case-containers/handoff.md` (Chinese). Approval: R20. Translated for this Change.

## OpenSpec Handoff

- Scope: theme-case-containers
- Target Change: angelscript/refactor-language-theme-cases

## Problem

Hand-authored Language containers stack a theme pocket, a privileged `root`, and a fake modification tree in one `.as`. The Builder requires exactly one parentless version named `root`. Casting has no real Family. `@parent root` only passes the gate. Negatives sit beside positives.

## Success criteria

- Language author files are theme pockets with several cases; only a real edit chain writes `@parent`.
- Compile-fail and runtime-fail each have `*CompileFail.as` / `*RuntimeFail.as`.
- Parser and Builder allow several parentless VersionTags; `root` is not privileged.
- Callables carry `@function` + `@summary` + `@inputs` + `@return`.
- The `angelscript-test` Skill and the code-database / language-fixtures specs match the new contract.
- The 122 generator products stay untouched.

## Evidence

- 47 live `AngelscriptTestCode/Language/*.as` files; Casting is an all-star tree.
- Exploration sketches showed `@begin`, Fail siblings, Family diffs, and function headers.
- The live Skill author page still teaches `AddRoot` and `Get(..., "root")`.

## Scope

Do: parser / Builder / CodeGenTool grammar; every Language author file and projection; `root` consumers; Skill; the two testing specs.

Do not: generator products; diagnostic oracles; Pending Bindings/Containers/World; turning the database into an execution layer.

## Constraints

- `.as` text is English; Change records are English.
- Q5=D (stay in draft) is superseded by R20.
- Task order: grammar first, then the Casting proving set, then the rest of Language, then Skill/specs.

## Approach

FileTag is the path without `.as`. Cases use `@begin`. Function contracts live on the function-header block. Lengthen the four Casting pockets. Keep other Language leaves; add Fail siblings. Parentless versions use `AddVersion`.

## Alternatives and flip conditions

- Change the story without changing the Builder: several parentless cases are impossible. Flip if the user restores the forced star.
- First Change is Casting only: R20 rejected this; one Change owns all Language. Flip if the 47-file proving set cannot stay in one DAG.
- Put the function contract only on the case header: conflicts with Q17. Flip if a Bindings mashup later proves the case header must come first.

## Failures

- Edit `.as` files without the parser: current v1 rejects them.
- Leave Bleed in a Casting Fail file: the pocket lies again.
- Leave the Skill on `root`: the next session will author the old star.

## Verification

See [design.md](design.md). Smallest proof: the parser admits two parentless cases; a Casting positive pocket plus CompileFail register; `Get(..., "root")` is no longer the Language representative.

## Exploration Carryover

The origin marker freezes the export list. This English folder is that list. Do not link back to `openspec/drafts/`.
