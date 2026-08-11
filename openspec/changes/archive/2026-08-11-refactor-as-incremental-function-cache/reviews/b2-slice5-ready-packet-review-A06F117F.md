# B2 Slice 5 ready-packet exact-file review — rejected candidate A06F117F

## Reviewed artifact

- artifact: `b2-slice5-ready-packet.md`
- SHA-256: `A06F117FF4556C01D9E78EB380736D32F0DBEEBA1287780C080FBF22D92C3FD7`
- physical shape: `30,805` bytes / `648` LF / `0` CR / final LF
- review mode: independent read-only exact-file review against the released
  matrix, layout, wire, producer-audit and frozen source authorities
- source/build activity: none

Earlier packet identities do not participate in this review.

## Disposition

```text
Critical:  0
Important: 3
Minor:     3
Decision:  HOLD
```

The arithmetic is internally consistent, but this exact packet cannot authorize
source because its decoder-coordinate rule, fixture-assembly contract and only
allowed compile command are not executable authority.

## Mechanical results that passed

```text
Method/VFT
86 + 6 + 12 + 2 + 4 + 10 + 1
= 121 = 20 success + 101 failure

Behavior form/product
1904 - 2 B1 + 17 statics + 11 empty
= 1930 = 112 success + 1818 failure

Behavior focused
3 + 6 + 35 + 4 + 8 + 2 + 4 + 1 + 1
= 64 = 6 success + 58 failure

Behavior total
1930 + 64
= 1994 = 118 success + 1876 failure

Slice-5 producer total
121 + 1994
= 2115 = 138 success + 1977 failure

Whole-TU scenario delta
+2115 - 952 + 11 + 5 = +1179

Expected-authority classification delta
success:  138 - 773 + 5       = -630
failure: 1977 - 168 - 5 + 5  = +1809
```

The reviewer also confirmed:

- `16` non-Construct gaps + `17` per-kind duplicates + one within-group reorder
  + one group disorder = `35` focused sequence calls;
- the fourteen legal singleton `0,1` cardinality-two failures remain only in the
  product while the seventeen `0,0` duplicate-ordinal cases remain focused;
- the five owner/ordinal observations use two extra calls and three named gap
  calls without double counting;
- all nine B1 exclusions are referenced or subtracted exactly once;
- the abstract ordinary-Class Construct/Factory positive is an independent
  normative section 9.1 cross-field control and must remain;
- the Environment anti-alias and Method/VFT/Behavior reuse controls are distinct;
  and
- the local/graph boundary and unique Slice-6 ownership of Dependency negatives
  and stale final-hash negatives are otherwise correct.

## Important findings

### I1 — optional-owner decoder coordinates are overgeneralized

The candidate said that present-row failures use `BehaviorSlot` and placed the
canonical Environment owner-present-zero failure at the physical Behavior row.
That conflicts with the released wire authority:

- Script owner present-zero: `BehaviorDeclaringOwner[row]`;
- Script owner absent: `BehaviorSlot[row]`;
- Environment owner present, zero or nonzero:
  `BehaviorDeclaringOwner[row]`, while the inactive stored value is not
  interpreted.

The nonempty decoder rewrite must distinguish reference/key/ABI subfields, active
Script owner values, optional-owner tags, ordinal/group coordinates and later
form/cardinality coordinates. The five new paired-owner scenarios also need exact
captured field and physical PrimaryIndex rather than generic trace prose.

### I2 — the product lacks its required mechanical companion-state contract

The `101` product successes cannot be constructed uniquely by adding only the
primary Behavior row. The packet must freeze these non-semantic assembly rules:

- Class Script Construct or Factory receives the opposite group at equal count;
- every locally valid Destruct success sets `HasDestructor`;
- Script CopyConstruct receives an exact Script Construct peer;
- Class Script CopyFactory receives an exact Factory peer plus a count-matching
  Construct group;
- Environment CopyConstruct/CopyFactory receives no Script peer except in the
  four explicit anti-alias controls;
- the Delegate route starts from a Behavior/flag-clean canonical baseline while
  retaining non-Behavior Method/callable dependencies; and
- focused alias negatives start from a canonical companion fixture and mutate
  exactly key, ABI, owner or peer presence.

In particular, an Environment CopyFactory anti-alias fixture that adds a Script
Factory peer must also add the otherwise-valid matching Construct group, or Class
count closure masks the intended success.

### I3 — the only allowed PowerShell compile wrapper does not parse

The candidate used backslash-escaped quotes:

```powershell
-ExtraArgs @(\"-SingleFile=$TypeSchemaTestTu\", '-NoHotReloadFromIDE')
```

PowerShell requires:

```powershell
-ExtraArgs @("-SingleFile=$TypeSchemaTestTu", '-NoHotReloadFromIDE')
```

Because the packet labels this its only allowed wrapper, the parser error is an
Important release blocker.

## Minor findings

1. References to nonexistent sections `6.1` and `6.2` must become section `6`
   and sections `8.1`/`8.2` respectively.
2. The IC-173 replacement method name must be frozen exactly, rather than left as
   prose for the source author to invent.
3. TemplateCallback has no locally legal target arm. Its gap fixture should use a
   wire-valid, active-value-valid ScriptFunction/nonzero-owner row so
   `OrdinalGap` wins before the later forbidden-kind result, without calling that
   target arm legal for TemplateCallback.

## Required rereview

Repair all six findings, freeze a new exact packet identity and perform a fresh
independent exact-file review. This rejected SHA remains historical evidence and
must never be described as RELEASE or source authorization.
