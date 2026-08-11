# B2 Slice 5 authority-correction proposal rereview

Date: 2026-08-09 (Asia/Shanghai)

Reviewed proposal:
`b2-slice5-authority-correction.md`

Reviewed exact identity:

```text
SHA-256 429B182728277F7362BD72AC1AAAA52BCE17B4B0055AE33CD58D16DF61C47558
bytes   19270
LF      377
CR      0
final LF yes
```

Independent read-only disposition: **HOLD — 0 Critical / 2 Important / 1 Minor**.
No normative authority or source edit was authorized from this SHA.

## Findings and required dispositions

1. **Cross-field failures named nonexistent containers** — the append-only
   `EAngelscriptTypeSchemaCapturedField` API has indexed row coordinates and
   top-level scalar coordinates, but no top-level `Relations`, `LayoutInputs`,
   `Properties`, `Methods`, `VFT` or `BehaviorSlots` captured field. Every
   closure failure needs an exact existing field plus `PrimaryIndex`; a missing
   required row has no row coordinate and needs one deterministic fallback
   discriminator. Count mismatches need a deterministic first unmatched/excess
   physical row. The audit must cover non-statics forms as well as statics.
2. **Behavior optional-owner validation had two owners** — proposal phase 2 and
   phase 4 both claimed the target-selected optional arm. Freeze a single split:
   phase 2 may validate only active values (including a present ScriptFunction
   owner being nonzero), while phase 4 validates absence/presence tags after the
   ordinal scan. EnvironmentSymbol owner values are inactive and must never be
   interpreted.
3. **Minor stale Method/VFT wording** — section 3.1 still called the non-statics
   form available during an earlier array pass. Earlier arrays must remain
   form-independent; any Reflection-selected presence/cardinality belongs to the
   later `ReflectionFormClosure`.

The rereview otherwise accepted the proposal's repaired duplicate-key,
raw/domain/scalar/ordinal/role/alias precedence, all-nonhash finalization,
HasDefault local/graph split, statics closure inventory, ghost-empty removal and
literal error mapping.

## Repair state

The primary agent repaired all three findings only after this rereview completed.
The repaired proposal is a new immutable identity and requires a fresh independent
review. This file does not approve that later identity.
