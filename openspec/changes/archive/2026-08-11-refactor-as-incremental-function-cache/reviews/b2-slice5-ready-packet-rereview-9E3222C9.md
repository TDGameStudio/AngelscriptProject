# B2 Slice 5 ready-packet rereview — rejected repair 9E3222C9

## Reviewed artifact

- artifact: `b2-slice5-ready-packet.md`
- SHA-256: `9E3222C92135C01BE4A8712BE26D9F982BD49C386AAD8764CAD3C4E607F38A6D`
- physical shape: `34,822` bytes / `701` LF / `0` CR / final LF
- review mode: independent read-only exact-file review of the first repair
- source/build activity: none; the PowerShell wrapper received a parser-only probe

## Disposition

```text
Critical:  0
Important: 2
Minor:     1
Decision:  HOLD
```

The repair closes all findings from the A06F candidate, but its newly materialized
Script-copy companion recipes do not yet preserve the intended first failing
coordinate.

## Important findings

### I1 — owner-absent Script Copy companions can fail before the primary row

The packet unconditionally gave Script CopyConstruct/CopyFactory an exact peer
with the same `{key, ABI, owner}` tuple. That is correct for a locally admitted
owner-present-nonzero cell, but not for a represented owner-absent failure:

- Construct group `1` is stored before CopyConstruct group `16`;
- Factory group `4` is stored before CopyFactory group `17`; and
- copying the absent owner to that earlier peer makes the peer return
  `InvalidPresence` before the primary Copy row is checked.

This masks at least Struct and Delegate Script CopyConstruct/owner-absent and
Class Script CopyFactory/owner-absent coordinates, including their cardinality-two
variants. It also recreates a Delegate Script Construct/owner-absent shape that
the packet says is cited from B1 rather than copied.

The companion recipe must distinguish owner shape:

- owner-present-nonzero Script Copy: add the exact alias peer;
- owner-absent Script Copy: keep every earlier peer owner-valid or add no alias
  peer so the primary Copy row is the first optional-owner failure; and
- Class CopyFactory owner-absent: keep Construct/Factory at `0/0` or at an
  unrelated, owner-valid, count-balanced `1/1` pair.

### I2 — focused Script CopyFactory no-peer can be masked by count mismatch

The candidate told focused alias negatives to start from the canonical exact-peer
fixture and mutate only peer presence. Removing the exact Factory while retaining
its count-matching Construct produces `Construct=1, Factory=0`, so
ReflectionFormClosure returns `InvalidPresence` before the required script-copy
alias result `InvalidQualifierCombination`.

The no-peer case must either:

- remove both the exact Factory and the Construct that existed only to balance it,
  leaving valid `0/0`; or
- replace them with an unrelated, owner-valid Construct/Factory `1/1` pair that
  does not match the CopyFactory tuple.

Afterward the fixture still rebuilds dependencies, sorts and finalizes.

## Minor finding

Section 6 said “Each producer method and repaired decoder method” owns an empty
baseline per legal form. Only the Behavior producer ledger contains these eleven
calls; the 121-call Method/VFT producer does not. Freeze the subject as “The
Behavior producer method and repaired decoder method”.

## Checks that passed

- the direct normative text supports retaining the abstract ordinary-Class
  Construct/Factory positive, so the focused ledger remains 64 rather than 63;
- 64 focused calls, singleton/product deduplication, per-kind gaps/duplicates and
  all owner/ordinal winners are arithmetically correct;
- the repaired decoder captured fields and five exact PrimaryIndex coordinates
  match released wire authority;
- all three A06F Minor findings and its PowerShell parser defect are closed;
- totals remain `121 = 20/101`, `1994 = 118/1876`,
  `2115 = 138/1977`, whole-TU delta `+1179` and classification delta
  `-630/+1809`;
- dependency/finalizer discipline, local/graph order and Slice-6 ownership remain
  correct; and
- the abstract nine-coordinate B1 subtraction is numerically correct, though I1
  would recreate a masked B1 fixture shape if implemented literally.

## Required rereview

Repair both companion recipes and the wording Minor, freeze a new exact packet
identity and run another independent exact-file review. This SHA remains
historical HOLD evidence and cannot authorize source.
