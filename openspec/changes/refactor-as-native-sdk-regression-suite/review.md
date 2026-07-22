# Final OpenSpec Review

## Review conclusion

The change is schema-valid, but schema validity alone does not make the implementation record decision-complete. This review closes the remaining planning gaps before plugin implementation starts.

## Findings and resolutions

| Finding | Resolution recorded by this change |
| --- | --- |
| The builder source was still described as an uncommitted external edit. | `audits/workspace-baseline.md` records plugin commit `b903571` as the clean production baseline and retains only regression-test ownership. |
| The method count was described as approximate. | The baseline is stated exactly as 433 source methods: 12 inside three known constant-false registration blocks and 421 outside those blocks. Runtime discovery remains unknown until a fresh run. |
| File-level mapping could not prove method preservation. | `audits/test-methods.csv` maps every current method exactly once with an explicit disposition and final owner. |
| Several split destinations were phrases rather than file paths. | `audits/file-map.md` is made normative and uses exact final paths for every current and planned file. |
| Existing scenario names contained vague, conditional, or table-oriented wording. | Final names in the method ledger and scenario record describe one subject and one expected outcome. Static audit rules reject the old naming forms. |
| A soft 500-line recommendation could bias implementation decisions. | File splitting is cohesion-first. A large cohesive file is allowed with a recorded rationale; line count is not a quota. |
| The 2.38 record covered only four future language subjects. | `audits/upstream-compatibility.md` classifies relevant 2.34–2.38 language and host API capabilities, including capabilities that cannot yet be compiled against the current header. |
| CQTest rules existed in background prose but were not fully enforceable. | Design, specs, tasks, and complete-phase audit requirements now cover registration macros, body gates, matcher assertions, helper visibility, raw fixtures, exact lookup, and raw-engine ownership. |
| The raw SDK engine lifecycle appeared to conflict with `UnitTest.md`. | The record makes per-method raw `asIScriptEngine` ownership an explicit native-layer exception; wrapper CQTests retain class-level `FAngelscriptEngine` lifecycle. |
| Tasks lacked method labels. | Every task is classified as `<!-- TDD -->` or `<!-- Non-TDD -->`; tests are the product, but builds remain deferred to large checkpoints. |
| Strict validation was marked pending despite a successful review run. | `verification.md` separates the successful planning/schema validation from future implementation validation. |

## Coverage interpretation

The existing deep `Coverage/` suite is a rigor benchmark, not a numerical quota. Completion is proven by named behavior dimensions and concrete scenarios, not by estimating files or lines. Each SDK domain and each core-language theme must close all applicable public surface, input, error, execution, lifecycle, interaction, isolation, and fork/upstream classification dimensions.

`audits/test-methods.csv` keeps prohibited legacy generic suffixes out of the new OpenSpec vocabulary. Such a current source method is represented with `<legacy-generic-suffix>` plus its exact source line and SHA-256 source key; `GenerateTestMethodsLedger.ps1` derives those fields from the real current declaration. Final method names remain plain, topic-specific identifiers.

## Remaining unknowns that are intentionally implementation-time evidence

Only observed execution results remain open:

- final CQTest discovered/pass/fail/disabled counts;
- build errors caused by actual include/unity/export interactions;
- whether broad-suite failures are causal or pre-existing;
- performance impact of per-method raw-engine ownership.

These do not require design choices. They are collected by the fixed verification sequence and recorded in `verification.md` and the final audit result.

## Ready-to-implement gate

Plugin implementation may start only when all of the following are true:

- the 82-file map has no vague destination;
- the 433-row method ledger passes its consistency checks;
- all planned new scenarios have exact owners and expected outcomes;
- all relevant upstream capabilities have one classification;
- every task has a method label and phase checkpoint;
- strict OpenSpec validation passes after these records are written;
- a fresh parent/submodule workspace baseline is captured.
