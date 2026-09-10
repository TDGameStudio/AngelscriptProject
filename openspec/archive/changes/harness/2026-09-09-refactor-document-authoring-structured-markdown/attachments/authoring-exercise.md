# Independent authoring exercise

The same three raw requests were given independently to agents reading only the Task/Spec references and project templates. They did not inspect business records, implementation or the other agent's conclusions, and did not implement the hypothetical features. Full actual outputs are retained in data/authoring-before.md and data/authoring-after.md; the focused correction is in data/authoring-after-spec-corrected.md.

## Raw requests

1. Plan an options-parser repair. Public `parse_options(text) -> Result<Options, ConfigError>` accepts `mode=fast` and `mode=safe`. Duplicate keys currently last-win and unknown keys are ignored. Require `DuplicateKey("mode")`, `UnknownKey(actual key)` and no Options on failure. Owned paths: `src/options.rs`, `tests/option_policy.rs`; command: `cargo test option_policy`.
2. Plan exact SourceId + VersionTag history resolution. Immutable root/single-parent children; reject duplicate tags within one source, unknown parents and cycles; no Source on failure; identical tags under different SourceIds are distinct; returned Source owns bytes after input storage release. Public SourceRef, SourceResult(Source or Error), Resolve(SourceRef). Existing completed 1.1 supplies immutable Source. Owned history header/implementation/tests; command `ctest -R history_contract`. Preserve the unavailable original 1.1 rather than inventing it.
3. Write durable sibling-ancestry and corruption cards: root `int Value=1;`, left `int Value=2;`, right `int Value=3;`, both children parent=root. Resolving right after left uses root, not left; consumer unchanged; parent/child hash mismatch rejects before publishing a Source.

## Observed comparison

| Aspect | Before | After |
| --- | --- | --- |
| Concrete parser cases | Already supplied six useful literal cases and grouped RED/GREEN | Retained six explicit named cases, selection/nonempty execution checks and error payload oracles |
| Task navigation and metadata | Old inline verify and two-space blockquote Files | Short title, four-space Outcome/interfaces/Cases/Implementation/Files/Verification; exact parser projection passed |
| Complex interface task | Detailed 13-case proposal; honestly identified unavailable APIs | Detailed nine-case proposal with identity, sibling/lifetime/failure contracts; preserved upstream record as an additive fragment and identified unavailable APIs |
| Durable Spec content | Useful literal branch and failure-state detail, old two-space continuation | Useful literal branch and integrity detail with mostly correct four-space ownership |
| Structural defect discovered | Expected old-format incompatibility, not evaluated as a new-format pass | Two wrapped GIVEN continuation lines still used two spaces; actual strict validation rejected lines 52 and 74 |

The old guidance was not content-empty and is not presented as a fabricated failing quality baseline. The demonstrated improvement is navigation, explicit executable metadata and consistently owned expansion, not a claim that more lines automatically mean better planning. Both exercises correctly refused to invent unspecified history registration, Source construction/access, Error discriminators or build preparation. The history fragments are not complete standalone Ready plans because the original upstream record and interfaces were not supplied.

## Narrow iteration and actual checks

The Scenario reference now explicitly says wrapped behavior sentences also require at least four spaces, even before a blank line. The consumer changed only the two offending continuations and retained its original output unchanged.

`Authoring.Tests.ps1 -Executable <candidate> -ExercisePath <after.md>` used the actual CLI in an isolated fixture: the parser-repair Task passed, while the Spec failed specifically for the two indentation diagnostics. `Authoring.Tests.ps1 -Executable <candidate> -ScenarioPath <after-spec-corrected.md> -OwnedDeltaPath <this change/specs/harness/core/spec.md> -CurrentSpecPath <current harness/core/spec.md>` then passed. The latter also proves that the three owned synchronized Requirement cards remain complete and validate independently of untouched historical content.

The default authoring gate tests filled reference examples and completed project scaffolds, exact Files/command/readiness projection, old-format rejection with zero Ready work, and missing-THEN rejection under record-v1. It replaces changed authoring word/regex assertions; it does not pretend to mechanically judge information sufficiency.
