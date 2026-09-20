# Approve the six-theme Language Change

## Context

Pending/Language looks much larger than admitted Language. The format Change is done. The remaining work is coverage, not `@begin` grammar.

## Evidence

475 admitted `@begin` cases versus 558 Pending Language files. Six host-free themes sit outside the first-wave inventory. R21–R27 in the local draft log.

## Options

Thicken first-wave Rejects; migrate the six missing themes; copy all 558; combine with Unreal.

## Settled Decision

This Change admits only Auto, Class, Inheritance, Destructors, Typedef, and Mixin as theme pockets (about one positive plus CompileFail each). Identity: `angelscript/feature-language-second-wave-fixtures`. Unreal material is a sibling Change.

## Consequences

Implementation rewrites Pending second-wave files into `AngelscriptTestCode/Language/<Theme>.as`. Class/Inheritance negatives merge with the existing Syntax CompileFail pocket.

## Flip Condition

A merged theme pocket that cannot state one claim may be split into sub-pockets without reopening Unreal or first-wave thickening.

## Sources

[Design](../drafts/design.md), [handoff](../drafts/handoff.md), [pending-coverage](../drafts/findings/pending-coverage.md). Provenance: draft log R21, R24, R26, R27.
