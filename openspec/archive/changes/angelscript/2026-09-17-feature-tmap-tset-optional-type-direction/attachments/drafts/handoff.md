# Handoff: TMap / TSet / TOptional type-axis and directions

Source draft: `openspec/drafts/angelscript/remaining-container-type-direction/designs/tmap-tset-optional/handoff.md` (Chinese original; approval R3).

## OpenSpec Handoff

- Scope: tmap-tset-optional
- Target Change: angelscript/feature-tmap-tset-optional-type-direction

## Problem

After the directory rewrite, admitted TMap / TSet / TOptional leaves are almost all local int observes. Old `TestSource-old/Containers/<Type>/Function` already wrote Observe plus `const&in` / `&out` / `&inout` per Subject, with each tree's type suffixes. The TArray Change ported that contract as one observation per file. These three trees did not.

TMap is half-done: `ContainsKey` / `NumCountsPairs` / `IndexAccess` have typed leaves and `*In`, but no `&out` / `&inout`, and Add-family subjects are still local. TSet / TOptional have almost no directions and no type axis.

## Success

- All three trees expose the old Function type leaves and three-direction leaves; existing int observes remain.
- Admitted TMap `*In` FileTags are not renamed.
- `codegen.py check` is synchronized; the corpus can `Get` a representative FileTag per tree (one typed observe and one `&out`).
- Every author `.as` is hand-written. Admission does not compile or execute AngelScript.

## Evidence

- [old-function-gap.md](findings/old-function-gap.md)
- [design.md](design.md)
- [glossary.md](glossary.md)

## Scope

Do: remaining TMap holes plus TSet plus TOptional. One Change. Three author groups have no edges. Generate and corpus sit on the join.

Do not: pointer wrappers, SoftObjectPath, Advance / Negative / Reject, misplaced TSet Function files, Language / Unreal, conversion scripts, parser edits.

## Constraints

- One observation per file; stem = `@begin` = entry.
- Type tables are per tree; do not copy TArray Float.
- TMap omits float keys; TSet omits float elements.
- `EmptyConstruction` gets typed observes only, not three directions.

## Approach

Keep existing leaves. Split old Function Subjects into `Read` / `FillBy` / `Mutate` and `<Stem><Type>`. For TMap `*In`, fill only the missing directions and subjects.

## Alternatives and flip

- Three Changes, one per type: not selected at R2. Split later if one bundle's parallel writes collide.
- Rename TMap `*In` to `Read*`: not selected at R3. Reopen only if mixed `*In` / `Read*` names break generate or corpus; do not rename during apply.
- Include pointer wrappers: not selected at R1.

## Failure

- Packing many UFUNCTIONs back into one file.
- Inventing an element-type axis for SoftObjectPath.
- Generating author files from old Function sources with a script.
- Treating admission as AngelScript compile or execute.

## Verification

Author parse tests go RED then GREEN. `codegen.py generate` / `check`. Corpus Fast prefix includes the new `Get`s.

## Exploration Carryover

Exported from the approved draft handoff. Required copies live beside this file.
