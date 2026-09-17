# Talk: approve and scope the first Change

## Context

Exploration had Q5=D (stay in draft). The user asked whether planning was ready and wanted to refactor `AngelscriptTestCode/Language` first.

## Evidence

47 Language author files. The live parser still requires `root`. The Skill still teaches `Get(..., "root")`. The design had no handoff until R20.

## Options

Wait in draft versus create a Change. First Change is Casting only versus parser + all Language + Skill/specs.

## Settled Decision

Q18=create. Q19=parser/Builder + every Language author file + Skill/specs. Generator products stay out. Task DAG does Casting first as the proving set, then the rest. Change ID `angelscript/refactor-language-theme-cases`.

## Consequences and Flip Condition

One Change is large. Flip if implementation evidence shows the 47-file move cannot share one verification contract; then split a follow-up Change rather than silently shrink this one.

## Visual

```
parser/Builder  ->  Casting proving set  ->  remaining Language  ->  Skill/specs
```

## Sources

Exploration log R20. User answers: go; language-full.
