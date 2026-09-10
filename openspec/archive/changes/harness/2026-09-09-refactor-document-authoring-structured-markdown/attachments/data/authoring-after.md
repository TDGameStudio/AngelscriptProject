Below are the three Markdown artifacts. The history artifact is an additive fragment: the unavailable completed task `1.1`, its existing dependency entry, and its evidence must remain intact. I have not fabricated a replacement record.

Artifact 1 — parser repair, complete `tasks.md`:

````markdown
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

- [ ] 1.1 Reject duplicate and unknown option keys without partial output

    **Outcome**

    Preserve successful parsing of `mode=fast` and `mode=safe`. Replace the
    current last-declaration-wins behavior for duplicate keys and the current
    acceptance of unknown keys with the required errors. A failed parse
    returns no Options.

    This outcome does not add modes or change unrelated value validation,
    whitespace handling, or export behavior.

    **Context and interfaces**

    The public boundary remains `parse_options(text) -> Result<Options, ConfigError>`.

    The accepted key in this repair is `mode`. A repeated `mode` key produces
    `DuplicateKey("mode")`, including when both declarations have the same
    value. An unknown key produces `UnknownKey(actual key)`, preserving the
    spelling of the offending key.

    An error is the Error alternative of the public Result. No successfully
    parsed prefix may escape as an Options value.

    The request does not supply the internal representation of Options.
    Successful assertions must use its actual public observation surface to
    establish the selected mode, without introducing a new Options layout.

    The fixtures below use newline-separated declarations; `\n` denotes one
    actual newline in the input. Confirm that separator against the existing
    input grammar before constructing the multiple-declaration fixtures.

    **Cases**

    | Case | Literal input | Expected result | Role |
    | --- | --- | --- | --- |
    | `option_policy_fast` | `mode=fast` | Successful Options selecting `fast` | Existing regression control |
    | `option_policy_safe` | `mode=safe` | Successful Options selecting `safe` | Existing regression control |
    | `option_policy_duplicate_different_values` | `mode=fast\nmode=safe` | `Err(DuplicateKey("mode"))`; no Options | New RED case |
    | `option_policy_duplicate_same_value` | `mode=safe\nmode=safe` | `Err(DuplicateKey("mode"))`; no Options | New RED case; duplicate identity is sufficient |
    | `option_policy_unknown_key` | `mdoe=fast` | `Err(UnknownKey("mdoe"))`; no Options | New RED case |
    | `option_policy_unknown_after_valid` | `mode=fast\nextra=safe` | `Err(UnknownKey("extra"))`; no Options | New RED case; reject partial success |

    Each error fixture has one kind of policy violation. These cases do not
    establish precedence between different errors in a single input.

    Assertions call the public parser and compare against these independently
    specified expectations. Expected errors must not be calculated by calling
    parsing or validation helpers from the implementation under test.

    **Implementation**

    1. Add the six cases in `tests/option_policy.rs`, ensuring each test name
       contains `option_policy` so the proving command selects it. Run the
       complete group. Observe the four new policy cases fail because of the
       current duplicate or unknown-key acceptance, with both successful-mode
       controls passing.
    2. Update key handling in `src/options.rs` to reject unknown keys and track
       accepted key identities. Reject a second `mode` declaration regardless
       of whether its value differs from the first declaration.
    3. Preserve the public Result boundary and return the required error
       without returning a partially built Options value.
    4. Run the same group for GREEN. If shared setup or parser structure is
       refactored afterward, rerun the same command and retain the literal
       expectations.

    **Files**

    - `src/options.rs`
    - `tests/option_policy.rs`

    **Verification**

    Run from the Rust package root containing the relevant Cargo manifest,
    with its normal dependencies available:

    ```sh
    cargo test option_policy
    ```

    Completion requires exit code zero and execution of all six named cases.
    The two successful-mode controls must remain valid; all four new cases
    must return the specified error and no Options. Check the executed case
    count so an empty selection cannot count as proof.

    This selection covers the parser policy outcome. An unrelated full suite
    is not required by the supplied scope.
````

Artifact 2 — history resolution, additions to the existing `tasks.md`:

The following entry belongs inside the existing `task_graph.depends_on` mapping. Retain every existing entry, including the unavailable entry for `"1.1"`:

```yaml
"1.2": ["1.1"]
```

Append the following task card in numeric order. This fragment is not a replacement standalone plan; validating the whole plan requires the original task `1.1` record.

````markdown
- [ ] 1.2 Resolve exact history identities with owned immutable output and atomic failure

    **Outcome**

    Resolve an immutable root or a single-parent descendant using the exact
    SourceId and VersionTag pair. Reject duplicate tags within one SourceId,
    unknown parents, and cycles without publishing a Source. Equal tag
    spellings under different SourceIds remain distinct. Every successful
    returned Source retains its bytes after the input storage is released.

    Task 1.1 is already complete and supplies immutable Source. Preserve its
    checked state, text, graph entry, and evidence. This task consumes that
    completed interface; it does not recreate the Source abstraction.

    The current history implementation and its present failures have not been
    supplied. Do not treat the proposed RED cases below as observed failures.
    This task excludes payload-hash policy, consumer application behavior, and
    a new history serialization format.

    **Context and interfaces**

    The supplied public contract is:

    ```text
    SourceRef { SourceId, VersionTag }
    SourceResult contains Source or Error
    Resolve(SourceRef) -> SourceResult
    ```

    A successful result contains an immutable Source. A failed result contains
    Error and no Source; reconstructed prefixes and partial output are not
    successful results.

    VersionTag alone is insufficient identity. Parent references in these
    fixtures identify a version of the same SourceId, using its exact pair.
    A root has no parent. Every non-root fixture has exactly one parent.
    Resolution follows recorded ancestry, regardless of earlier lookups.

    The returned Source must remain readable after the caller releases all
    storage used to provide the history input. Retaining only a borrowed view
    into that storage does not satisfy the lifetime contract.

    Concrete constructors, history input registration, Source byte access,
    and Error discriminator names are not supplied. Use the established
    interfaces from task 1.1 and the owned history files. The tables below
    describe logical input records, not an invented C++ registration API or
    serialized payload format.

    **Cases**

    Use independent histories for the valid fixture and each invalid fixture,
    so one invalid graph cannot mask another case.

    The valid logical history contains:

    | SourceId | VersionTag | Parent SourceRef | Complete logical bytes |
    | --- | --- | --- | --- |
    | 7 | `root` | none | `int Value=1;` |
    | 7 | `left` | `(7, root)` | `int Value=2;` |
    | 7 | `right` | `(7, root)` | `int Value=3;` |
    | 8 | `root` | none | `int Value=9;` |

    Byte expectations include exactly the displayed characters, with no
    additional trailing newline.

    | Case | Concrete action | Expected result | Role |
    | --- | --- | --- | --- |
    | `history_root` | Resolve `(7, root)` | Source bytes exactly `int Value=1;` | Root integration control for the Source supplied by 1.1 |
    | `history_child` | Resolve `(7, left)` | Source bytes exactly `int Value=2;` | New descendant acceptance case |
    | `history_sibling` | Resolve `(7, left)`, retain its Source, then resolve `(7, right)` | Second Source bytes exactly `int Value=3;`; retained left bytes remain `int Value=2;` | New ancestry and immutability case |
    | `history_distinct_sources` | Resolve `(7, root)` and `(8, root)` | Respective bytes `int Value=1;` and `int Value=9;` | New exact-identity case |
    | `history_owned_lifetime` | Resolve `(7, right)`, retain the returned Source, release all history input storage, then read that Source | Bytes still exactly `int Value=3;` | New lifetime case |

    Invalid histories and requests are:

    | Case | Concrete logical input | Request | Expected result |
    | --- | --- | --- | --- |
    | `history_duplicate_tag` | Two roots with SourceId `7`, tag `root`, and bytes `int Value=1;` and `int Value=9;` | Resolve `(7, root)` | Error for duplicate identity; no Source |
    | `history_unknown_parent` | SourceId `7`, tag `child`, parent `(7, absent)`, logical bytes `int Value=2;`; no `(7, absent)` record | Resolve `(7, child)` | Error for unknown parent; no Source |
    | `history_self_cycle` | SourceId `7`, tag `loop`, parent `(7, loop)`, logical bytes `int Value=2;` | Resolve `(7, loop)` | Error for a cycle; no Source |
    | `history_two_node_cycle` | `(7, a)` has parent `(7, b)` and logical bytes `int Value=2;`; `(7, b)` has parent `(7, a)` and logical bytes `int Value=3;` | Resolve `(7, a)` | Error for a cycle; no Source |

    The four invalid-history cases are proposed RED cases for rejection
    behavior. Together with the four new valid-history cases, they define
    this task's missing-behavior group. The root case is the regression
    control. Classify the actual initial results from observation; behavior
    already present must remain a passing control.

    "Error for duplicate identity", "Error for unknown parent", and "Error
    for a cycle" describe required failure causes, not invented enum values
    or literal diagnostic messages. Use existing public discriminators if
    available. The supplied contract guarantees Error versus Source but does
    not prescribe diagnostic spelling.

    **Implementation**

    1. Recover the unchanged completed 1.1 record and identify its actual
       immutable Source construction and observation interfaces. Identify the
       existing history input representation and the configured CTest
       invocation directory. Do not create substitute APIs merely to match
       this plan.
    2. Prepare the nine named cases in `tests/history_tests.cpp`, constructing
       independent fixtures through the actual supported history input
       boundary. For the lifetime case, ensure the original input owners have
       been released before checking the retained Source.
    3. Run the full `history_contract` selection and retain grouped RED
       evidence. Diagnose failures to distinguish missing required behavior
       from fixture or configuration failures. Retain any already-passing
       acceptance cases and the root control.
    4. Implement and wire exact-pair identity handling, recorded-parent
       traversal, duplicate detection, unknown-parent rejection, and cycle
       rejection in the owned history files. Consume the immutable Source
       from 1.1 and ensure the final returned Source owns its bytes.
    5. Publish a Source only for a successful resolution. Return Error without
       a Source for every rejected request, including after intermediate
       reconstruction has begun.
    6. Run the same group for GREEN. After any relevant refactoring, rerun it
       and retain task-specific results for all nine cases.

    **Files**

    - `src/history.h`
    - `src/history.cpp`
    - `tests/history_tests.cpp`

    **Verification**

    Run from the configured CMake build directory containing the registered
    `history_contract` CTest test, after rebuilding the affected test
    executable using the project's existing build configuration:

    ```sh
    ctest -R history_contract
    ```

    Completion requires exit code zero, a nonempty CTest selection, and
    execution and success of all nine cases listed above. The selected test
    must cover exact identity, root and descendant output, sibling ancestry,
    both cycle shapes, duplicate and unknown-parent rejection, and output
    lifetime. Every rejection must expose Error and no Source.

    The concrete build directory and preparation command must be obtained
    from the existing record or project configuration before execution; they
    were not supplied with this request. No test results are claimed here.
````

Artifact 3 — durable specification cards:

````markdown
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
````

Genuine unresolved inputs are limited to details the requests did not supply:

- The parser’s declaration separator and concrete successful Options observation surface. The task uses newline-separated declarations provisionally and does not invent Options fields.
- The original completed `1.1` card and graph entry. They are necessary to produce and validate a complete history plan, but must be preserved rather than reconstructed.
- The history input construction API, immutable Source construction/access API, CMake build directory, and preparation command. These are execution prerequisites, not reasons to invent new public interfaces.
- History Error discriminator names and hash algorithm/encoding were not supplied. The artifacts preserve the required error outcomes and mismatch relationships without choosing diagnostic strings or fabricated digest values.

No repository files were changed, and no tests were run.
