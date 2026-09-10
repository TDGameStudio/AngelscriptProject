Read all four requested files completely. The artifacts below follow their Task DAG and clause-owned Scenario Card conventions. The resolver task is an addition to the existing plan: retain the original completed `1.1` card and its graph entry. Its input-registration interface remains an unresolved prerequisite to marking the new task Ready.

Artifact 1 — parser repair `tasks.md`:

```markdown
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

## 1. Option declaration validation

- [ ] 1.1 Reject duplicate and unknown option keys without returning Options — verify: `cargo test option_policy`
  > Files: `src/options.rs`, `tests/option_policy.rs`

  Preserve `parse_options(text) -> Result<Options, ConfigError>`.
  Valid declarations continue to produce their corresponding `Options`.
  Duplicate `mode` declarations produce `DuplicateKey("mode")`; an unknown
  key produces `UnknownKey` containing that actual key. Every failure is
  an `Err` containing no `Options`.

  This repair covers duplicate and unknown-key validation. Preserve the
  existing grammar and existing behavior for malformed declarations and
  unsupported values; do not add new modes or change the public API.

  The focused cases use literal expected results:

  | Input | Expected result | Role |
  |---|---|---|
  | `mode=fast` | `Ok` with mode `fast` | Existing valid-input regression control |
  | `mode=safe` | `Ok` with mode `safe` | Existing valid-input regression control |
  | `mode=fast\nmode=safe` | `Err(DuplicateKey("mode"))` | Missing duplicate rejection |
  | `mode=fast\nmode=fast` | `Err(DuplicateKey("mode"))` | Identical repetition is still a duplicate |
  | `mdoe=fast` | `Err(UnknownKey("mdoe"))` | Missing unknown-key rejection and actual-key diagnostic |
  | `mode=fast\nextra=yes` | `Err(UnknownKey("extra"))` | Failure after valid input returns no Options |

  Each failure assertion checks the `Err` alternative and its exact error
  payload. Expected modes and key strings are literals rather than values
  computed using the parser under test.

  1. Add all listed cases to the selection executed by
     `cargo test option_policy`. Run them together before changing parser
     behavior. Record the observed RED: duplicate inputs currently succeed
     with the last value, and unknown keys currently succeed or are ignored.
     The valid-input controls should continue to pass.
  2. Implement key validation and duplicate detection within the existing
     parser. Return the required error as soon as that declaration is
     rejected, preserving the existing result type and valid parsing.
  3. Run `cargo test option_policy` again. Complete the task only when every
     listed case executes and passes. If refactoring follows GREEN, rerun
     the same command. Record the executed cases and results; a broader
     suite is unnecessary unless the change reveals impact outside this
     parser boundary.
```

Artifact 2 — resolver addition to the existing `tasks.md`:

The graph shown assumes `1.1` is the existing upstream root. If its actual graph entry has prerequisites, preserve those prerequisites. The original completed `1.1` body and evidence remain in place.

```markdown
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
---

## 2. Exact immutable source resolution

- [ ] 2.1 Resolve exact source versions and reject invalid histories without publishing a Source — verify: `ctest -R history_contract`
  > Files: `src/history.h`, `src/history.cpp`, `tests/history_tests.cpp`

  Consume the immutable `Source` supplied by completed task `1.1`.
  Preserve the public identities and result boundary:

  ```cpp
  struct SourceRef {
      SourceId source_id;
      VersionTag version_tag;
  };

  // SourceResult contains either a Source or an Error.
  SourceResult Resolve(SourceRef ref);
  ```

  Lookup uses the complete `(SourceId, VersionTag)` pair. A successful
  result supplies exactly the requested immutable source bytes. Its byte
  storage remains valid after the input storage used to create the history
  is released. An error result contains no Source and publishes no failed
  or partial result through any externally visible publication surface.

  The outcome includes roots, single-parent descendants, source identity
  isolation, duplicate-tag rejection within a SourceId, unknown-parent
  rejection, cycle rejection, and owning result lifetime. Multiple-parent
  records, merge semantics, hash validation, and payload-corruption
  handling are outside this task.

  All fixture strings below describe exact bytes without a trailing
  newline. `A` and `B` denote distinct SourceIds; `r`, `c`, and `g` denote
  VersionTags. A parent reference is an exact SourceRef. Repeated tags in
  distinct SourceIds are valid and must not collide.

  | Case | History input and request | Independently specified expected result |
  |---|---|---|
  | Root | `(A,r)`, no parent, bytes `int Value=1;`; resolve `(A,r)` | Source bytes exactly `int Value=1;` |
  | Child | `(A,c)` has parent `(A,r)` and represents bytes `int Value=2;`; resolve `(A,c)` | Source bytes exactly `int Value=2;` |
  | Grandchild | `(A,g)` has parent `(A,c)` and represents bytes `int Value=3;`; resolve `(A,g)` | Source bytes exactly `int Value=3;` |
  | Earlier snapshot stays immutable | Retain results for `(A,r)` and `(A,c)`, then resolve `(A,g)` | Retained root is still `int Value=1;`; retained child is still `int Value=2;` |
  | Source identity isolation | `(A,r)` is `int Value=1;`; `(B,r)` is `int Value=9;`; resolve both | A returns `int Value=1;`; B returns `int Value=9;` |
  | Exact tag lookup | A contains `r` and `c`; request `(A,missing)` | Error; no fallback to another tag and no Source |
  | Exact source lookup | Only A exists; request `(B,r)` | Error; no fallback to A and no Source |
  | Duplicate version identity | Two input records both claim `(A,r)` | Reject the duplicate identity; no Source for the rejected history input |
  | Unknown parent | `(A,c)` names absent parent `(A,missing)`; request `(A,c)` | Error; no Source |
  | Self-cycle | `(A,c)` names parent `(A,c)`; request `(A,c)` | Error; no Source |
  | Longer cycle | `(A,c)` names `(A,g)` and `(A,g)` names `(A,c)`; request either | Error; no Source |
  | Owning result lifetime | Resolve `(A,c)` successfully, release the original input buffers and temporary fixture storage, then read the retained result | Source bytes remain exactly `int Value=2;` |
  | Failure preserves prior success | Retain a successful independent root result, then attempt each invalid-history case | Each operation fails without changing the retained source bytes |

  Construct invalid-history fixtures independently so that one invalid
  record cannot mask another case. The success oracles are the literal
  strings above, not an invocation of production reconstruction logic.

  Task `1.1` has already established immutable Source behavior. The retained
  snapshot and lifetime assertions are integration controls for using that
  type correctly. Exact history lookup, ancestry traversal, identity
  isolation, and invalid-history rejection are the new behavior this
  task's RED must demonstrate.

  1. Bind these fixtures to the agreed history-input interface and add the
     listed cases to `history_contract`. Ensure the configured test
     executable includes the new cases. Run `ctest -R history_contract`
     before implementing resolver behavior and retain the actual RED.
     Identify failures caused by missing resolver behavior separately from
     upstream Source regression controls.
  2. Implement the resolver and its necessary input wiring in the owned
     files. Resolve using exact identities, reject invalid ancestry, and
     return the upstream owning immutable Source only on success. Keep
     intermediate reconstruction state unobservable until success.
  3. Run `ctest -R history_contract` for grouped GREEN. Require the named
     test selection to exist, every listed case to execute, and all cases
     to pass. Record the mapping between these cases and their test names.
     If refactoring follows GREEN, rerun this command. Broaden verification
     only if evidence demonstrates impact beyond the history contract.

  Before this task is Ready, record the existing history-input API and
  record representation, the immutable Source construction/read API
  supplied by `1.1`, and the public invalid-input/publication observables.
  Those details are not provided in the raw request and must not be
  invented by the implementer.
```

The reconstruction, rejection, and ownership cases form one resolver contract here. They share the same input boundary, public function, files, and proving selection. The new task consumes `1.1`’s completed output instead of replanning the immutable `Source` implementation.

Artifact 3 — durable resolver specification cards:

```markdown
## Purpose

Resolve immutable source versions through their declared ancestry while
preserving consumer state and rejecting payloads whose integrity cannot
be established.

## ADDED Requirements

### Requirement: Resolution follows the requested version's ancestry

The resolver SHALL reconstruct a requested source version from that
version's declared ancestry. Previously consumed versions SHALL NOT
replace a declared ancestor. Resolving a version SHALL NOT mutate the
consumer's current source state or previously returned immutable sources.

#### Scenario: Resolve a sibling branch after consuming another sibling

- **GIVEN** one source has a root and two children that both declare the
  root as their parent, and the consumer currently holds the left child

  | Version | Declared parent | Exact source text |
  |---|---|---|
  | root | None | `int Value=1;` |
  | left | root | `int Value=2;` |
  | right | root | `int Value=3;` |

  The text values have no trailing newline. The consumer has already
  consumed `left` before requesting `right`.

- **WHEN** the consumer resolves the exact source reference for `right`

  The requested ancestry is `root` followed by `right`. The consumer's
  current `left` version is not an ancestor of `right`.

- **THEN** the resolver returns an immutable Source whose bytes are
  exactly `int Value=3;`

  > Observables: The result is the same as resolving `right` without
  > previously consuming `left`; the result does not depend on consumer
  > traversal history.

- **AND** the consumer continues to hold `left` with bytes exactly
  `int Value=2;`

  Resolving `right` supplies a result without selecting it as the
  consumer's current source.

- **AND** any retained root and left Sources keep their original bytes

  | Retained Source | Bytes after resolving right |
  |---|---|
  | root | `int Value=1;` |
  | left | `int Value=2;` |

### Requirement: Payload integrity is established before source publication

The resolver SHALL reject a child payload if its expected parent hash
does not match its resolved parent, or if its reconstructed child bytes
do not match the expected child hash. It SHALL establish both applicable
integrity conditions before publishing a Source. A rejected resolution
SHALL return Error without a Source and SHALL preserve previously
published sources and consumer state.

#### Scenario: Parent hash mismatch rejects the child payload

- **GIVEN** the declared parent resolves to bytes `int Value=1;`, and the
  child payload declares an expected parent hash that differs from the
  hash of those bytes

  > Inputs: The mismatch is between the payload's recorded parent hash
  > and the actual resolved parent. The declared parent exists, so this
  > case isolates integrity rejection from unknown-parent rejection.

- **WHEN** the resolver resolves the child's exact SourceRef

- **THEN** resolution returns Error without a Source

  The mismatched parent cannot be accepted as the base for a published
  child Source.

- **AND** no reconstructed or partial child Source is published

- **AND** previously published Sources and the consumer's current source
  remain unchanged

#### Scenario: Child hash mismatch rejects reconstructed bytes

- **GIVEN** a child payload's expected parent hash matches its resolved
  parent's bytes, but reconstruction produces bytes whose hash differs
  from the payload's expected child hash

  > Context: Parent validation succeeds in this case, so rejection is
  > attributable to the reconstructed child rather than its base.

- **WHEN** the resolver resolves the child's exact SourceRef

- **THEN** resolution returns Error without a Source

  > Observables: Reconstructed bytes do not become an externally
  > available Source merely because parent validation succeeded.

- **AND** no reconstructed or partial child Source is published

- **AND** previously published Sources and the consumer's current source
  remain unchanged
```

Genuine unresolved input ambiguities:

- The resolver’s history-registration/input interface and record encoding are unspecified. In particular, it is unclear whether descendant inputs contain full snapshots or reconstruction payloads, and whether duplicate identities are rejected during registration or through `Resolve`.
- The public `Source` construction/read operations and the relevant `Error` representation are absent from the request. The task can name required behavior, but cannot give executable C++ fixture wiring or exact error-value assertions without that upstream contract.
- “Publishes no source” does not identify any observable publication surface beyond `SourceResult`. Any registry, callback, or cache visibility requiring assertions needs its existing interface identified.
