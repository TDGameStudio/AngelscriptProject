# Approve the host-API fixtures Change

## Context

The Bindings holding tree is a second host-API corpus, not the Unreal first batch. Value containers need an admitted `Containers/` root. The directory name Bindings stays rejected.

## Evidence

580 Bindings files / 126 types / ~2420 `Observe_*`. Pending/Containers 240 with Fail and pointer types. Pending/Math 111 overlaps Bindings math. Sibling Changes already created for Language second wave and Unreal UClass+World. Draft log R27–R29.

## Options

Home `Containers/` vs `Unreal/Containers/`. Wave = value four vs TArray pilot vs all 580. Third Change vs fold into Unreal. Non-T* destinations: split Unreal/<Type> vs all Containers vs Library/ vs park 550.

## Settled Decision

Create `angelscript/feature-host-api-fixtures` now (Q36/Q37). `Containers/` holds T* and SoftObjectPath plus Pending/Containers (Q32/Q33). Remaining Bindings folders rewrite to `Unreal/<Type>` (Q35). This Change is independent of `feature-unreal-fixture-root` (Q34).

## Consequences

Implementation must rewrite old root stars and mashups before generate. Unreal first-batch FileTags stay owned by the sibling Change; collisions merge. Misfiled TSet gameplay moves out of Containers, not into delete.

## Flip Condition

If rewriting 580 types plus 240 container files cannot be proven as one Change, split by family (value containers first, then math, then UObject) without moving material into Language or reviving Bindings/.

## Sources

[Design](../drafts/design.md), [handoff](../drafts/handoff.md), [bindings-intake](../drafts/findings/bindings-intake.md), [host-destinations](../drafts/findings/host-destinations.md). Provenance: draft log R27, R28, R29.
