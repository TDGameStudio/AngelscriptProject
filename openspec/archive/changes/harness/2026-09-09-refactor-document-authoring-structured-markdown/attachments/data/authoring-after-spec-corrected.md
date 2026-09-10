## Purpose

Preserve recorded branch ancestry and prevent corrupted history payloads from
publishing reconstructed Sources.

## ADDED Requirements

### Requirement: Recorded branch ancestry

The resolver SHALL reconstruct each requested version from its recorded
parent. Earlier resolutions SHALL NOT change the requested version's
ancestry, previously returned Sources, or consumer state.

#### Scenario: Resolve right after resolving its sibling left

- **GIVEN** a root and two children belonging to one SourceId

    | VersionTag | Recorded parent | Complete logical text |
    | --- | --- | --- |
    | `root` | none | `int Value=1;` |
    | `left` | `root` | `int Value=2;` |
    | `right` | `root` | `int Value=3;` |

    Both children have `root` as their parent. The text contains exactly the
    displayed characters, without an additional trailing newline.

- **WHEN** the consumer resolves `right` after successfully resolving `left`

    Each request identifies the version using its SourceId and VersionTag.
    The preceding lookup of `left` does not supply the parent of `right`.

- **THEN** the returned Source contains exactly `int Value=3;`

    The reconstruction uses the root text `int Value=1;` as the parent
    baseline for `right`. The sibling text `int Value=2;` is not its parent.

- **AND** previously returned Sources and consumer state remain unchanged

    A retained root Source still contains `int Value=1;`, and a retained
    left Source still contains `int Value=2;`. Resolving `right` does not
    apply its text to consumer state.

### Requirement: Reject corrupted history payloads before publication

The resolver SHALL reject a parent-hash mismatch or a child-hash mismatch
before publishing any Source for the failed request. Failure SHALL leave
consumer state and previously returned Sources unchanged.

#### Scenario: Reject a parent-hash mismatch

- **GIVEN** a root whose complete text is `int Value=1;` and its child `right`
    whose intended complete text is `int Value=3;`

    The child's recorded parent is `root`. The parent hash expected by the
    child payload differs from the hash of the recorded parent's actual
    bytes under the history format's hash rule.

- **WHEN** the consumer resolves `right`

    The request uses the SourceId and VersionTag of that child.

- **THEN** the result contains Error and no Source

    The parent-hash mismatch rejects the request before any reconstructed
    Source is published. Intermediate bytes do not become successful output.

- **AND** consumer state and previously returned Sources remain unchanged

    Any retained root Source still contains exactly `int Value=1;`.

#### Scenario: Reject a child-hash mismatch

- **GIVEN** a root whose complete text is `int Value=1;` and its child `right`
    whose reconstructed complete text is `int Value=3;`

    The child's recorded parent is `root`, and the parent-hash check succeeds.
    The payload's expected child hash differs from the hash of the
    reconstructed child bytes under the history format's hash rule.

- **WHEN** the consumer resolves `right`

    The request uses the SourceId and VersionTag of that child.

- **THEN** the result contains Error and no Source

    Producing the reconstructed bytes is insufficient for success. The
    child-hash mismatch rejects the request before those bytes are published
    as a Source.

- **AND** consumer state and previously returned Sources remain unchanged

    Any retained root Source still contains exactly `int Value=1;`.
