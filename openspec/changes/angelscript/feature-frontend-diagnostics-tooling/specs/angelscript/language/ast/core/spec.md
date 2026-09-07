## MODIFIED Requirements

### Requirement: Single reconstructed AST authority

The reconstructed frontend SHALL use the reconstructed typed hierarchy as its sole semantic AST authority and SHALL expose consumers through explicit read-only access or projections, distinguishing valid sealed compilation products from partial tooling snapshots.

#### Scenario: Consume AST facts at a subsystem boundary

- **WHEN** diagnostics, reflection, stable identity, serialization, tooling or a future code generator requests AST information
- **THEN** it traverses typed nodes or a read-only projection derived from that same hierarchy under its declared validity boundary
  > Observables: Normal downstream compilation and codec consumers retain their sealed, verified graph requirements; tooling may explicitly select an owned read-only partial result.
- **BUT** the system does not maintain a synchronized root-level wide record graph, `asCScriptNode` shadow or generic sidecar IR as another semantic truth
  > Boundaries: Diagnostic/query display values do not independently decide types or overloads. Dormant legacy source remains reference material.

## ADDED Requirements

### Requirement: Read-only partial AST results preserve ownership and validity boundaries

The frontend SHALL allow an analysis result to retain an ownership-checked, nonmutating partial view of the typed AST after its workers have joined, without classifying that view as a valid sealed publication root.

#### Scenario: Inspect a retained recovery graph

- **GIVEN** completed analysis fragments contain typed recovery nodes and later valid declarations
- **WHEN** an owning result exposes those fragments for diagnostics and semantic queries
- **THEN** traversal and source resolution remain safe for the result lifetime and incomplete or invalid facts remain explicitly marked
  > Observables: Source, AST context, type context and authenticated frozen-host dependencies remain owned once by the result; nodes do not each retain snapshot smart pointers.
- **BUT** the read-only partial state cannot satisfy normal AST codec admission, definition freezing or runtime publication
  > Boundaries: A successful partial ownership check does not replace semantic verification or recovery-reachability rejection for publication roots.

#### Scenario: Reject cross-result handles and late mutation

- **WHEN** a caller presents a node handle from another result or attempts to mutate a result already exposed as read-only
- **THEN** the operation fails explicitly and leaves the retained result unchanged
- **AND** independent cursor requests may build their own request-local state without modifying the retained result
  > Verification: Formal AST projections, diagnostics and host definitions before and after a query are identical.
