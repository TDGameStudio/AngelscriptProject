# LANG-REF-LIFETIME

Author reference for `FRefLifetimeGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Observation: `IDENTITY` | `REFCOUNT` | `WEAK_FLAG` | `DESTRUCTION` | `GC_STATS`
2. Owner: `OWNER_LIVE` | `SCOPE_EXIT` | `RETURNED_ALIAS` | `MODULE_RETAINED` | `MODULE_DISCARDED` | `CONTEXT_RETAINED` | `CONTEXT_RELEASED` | `GC_CYCLE`
3. Reference: `NONE` | `ONE_ALIAS` | `MULTIPLE_ALIASES` | `CYCLE` | `WEAK_FLAG`

Product ID prefix: `LANG-REF-LIFETIME`. Complete set: 5×8×5 = 200 cells. Normal-return aggregate = 150. Compile reject = 50 (`MODULE_RETAINED` and `MODULE_DISCARDED` × all observations and references). Runtime fault = 0.

Example: `LANG-REF-LIFETIME-IDENTITY-OWNER_LIVE-NONE` → `int EntryLangRefLifetimeIdentityOwnerLiveNone()`.

## Source branches

Observation is a host-workflow axis and does not change the emitted body.

- Ordinary owners emit `Primary == nullptr ? 0 : Primary.GetIdentity()` over `nullptr`, `MakeRefRoot(41)`, extra aliases, or `Link`/`ClearPeer`
- `RETURNED_ALIAS` copies `Primary` into `Returned` before that formula
- `GC_CYCLE` is the marker `return 1;`
- Module owners reject with `FRefRoot GReferenceOwner;` and optional `GReferenceAlias`

`BuildReferenceLifetimeSource` is positive-only. Empty `FunctionName` emits `Entry`.

## Observation

Independent oracle for non-reject cells:

- `NONE` ordinary owners → 0 (real expected zero)
- object-bearing ordinary owners → 1 (first isolated `MakeRefRoot` identity)
- `GC_CYCLE` → 1

Host refcount, weak-flag, destruction, and GC statistics remain limited observations. Rows are `ReturnValue` + `RequiresHostSetup`. Reject rows are `CompileReject` + `SourceOnly`. `GetExpected` returns 0 for reject and unknown IDs. That fallback is not membership proof.
