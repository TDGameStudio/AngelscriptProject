# Inline old-test .as, not the Language database

## Context

Language was explained as `AngelscriptTestCode/Language`. The user rejected that input.

## Evidence

User: do not use the database; embed some `.as` from old tests; those corpus tests are not formally landed. Draft log R13.

## Options

Compile `NullHandle.as` @begin pockets; compile the whole Language tree; or embed HotReload-style `UCLASS` strings.

## Settled Decision

Do not read `FAngelscriptTestCode` or `AngelscriptTestCode/Language`. Embed `UCLASS` / `UFUNCTION` source in NativeEngine tests.

## Consequences

The Language folder stays authors-only. This Change has no Language execute task.

## Flip Condition

Reopen when Language execute tests are formally landed and a later Change must compile those files.

## Sources

[inline-as-not-corpus](../drafts/findings/inline-as-not-corpus.md). Provenance: draft log R13.
