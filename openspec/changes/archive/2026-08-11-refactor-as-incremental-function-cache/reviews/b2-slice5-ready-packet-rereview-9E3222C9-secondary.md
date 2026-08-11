# B2 Slice 5 ready-packet secondary rereview — rejected repair 9E3222C9

## Identity and disposition

```text
Artifact:   b2-slice5-ready-packet.md
SHA-256:    9E3222C92135C01BE4A8712BE26D9F982BD49C386AAD8764CAD3C4E607F38A6D
Bytes/LF:   34,822 / 701
CR/final:   0 / yes
Test TU:    frozen 61 TEST_METHODs
Critical:   0
Important:  2
Minor:      1
Decision:   HOLD
```

This was a second independent read-only review of the same exact repair. It made
no file edits, build or Automation call. Its findings independently match the
primary rereview.

## Important findings

1. The exact-alias companion recipe copied an absent primary Script Copy owner
   into an earlier Construct/Factory group. That earlier row would return
   `InvalidPresence`, so six represented primary cells would not prove their own
   owner-required rule:

   ```text
   Struct   Script CopyConstruct owner absent × cardinality {1,2} = 2
   Delegate Script CopyConstruct owner absent × cardinality {1,2} = 2
   Class    Script CopyFactory   owner absent × cardinality {1,2} = 2
                                                                  ---
                                                                    6
   ```

   Nonzero owners may retain exact peers. Absent owners need no invalid earlier
   peer, or an independently owner-valid companion, so the primary Copy row wins.

2. Removing only the exact Factory peer from the canonical Class CopyFactory
   no-peer fixture leaves `Construct=1/Factory=0`. Class count closure would return
   `InvalidPresence` before copy-alias closure can return the frozen
   `InvalidQualifierCombination`. Remove the solely balancing Construct too and
   preserve `0/0`, or use an unrelated balanced `1/1` pair; then rebuild
   dependencies, sort and finalize.

## Minor finding

Section 6's “Each producer method” was ambiguous because the Method/VFT producer
does not own eleven empty calls. It must name the Behavior producer and repaired
decoder method only.

## Passing evidence

The secondary review independently confirmed:

- exact arithmetic `121=20/101`, `1930=112/1818`, focused `64=6/58`,
  Behavior `1994=118/1876`, Slice `2115=138/1977`, TU delta `+1179` and
  classification delta `-630/+1809`;
- nine B1 coordinates counted once;
- no singleton/product duplication;
- all earlier A06F decoder-coordinate, wrapper and editorial findings repaired;
- the abstract ordinary-Class cross-field positive is directly required by
  normative section 9.1;
- dependency/finalizer and local/graph boundaries remain correct; and
- `openspec validate ... --strict` and wrapper parser-only probing succeeded.

This corroborating review does not authorize source. A new exact packet must close
the two companion findings and receive fresh review.
