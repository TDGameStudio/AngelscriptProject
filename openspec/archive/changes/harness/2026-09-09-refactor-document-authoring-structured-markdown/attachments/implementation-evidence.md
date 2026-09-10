# Structured Markdown implementation evidence

## Task 1.1 — owned Task metadata

- RED: `cargo test --locked --test structured_task_contract` against the previous parser failed all 12 new cases on the absent format/ownership behavior.
- GREEN: `cargo test --locked --test task_plan_contract --test structured_task_contract` passed 27/27 (2026-09-09). The 12 new surface cases and 15 adjacent graph cases prove extraction, nesting, literal path identity, multiline commands, invalid-plan readiness suppression, graph invariants and explicit old-format rejection.
- Adjacent tests exposed a second BOM normalization and missing retired root After diagnostic; both were repaired and the exact combined group rerun GREEN. No legacy fallback remains.

## Task 2.1 — Scenario ownership

- RED: `cargo test --locked --test structured_spec_contract` failed 5/7 against the old parser: nested headings promoted into structure, missing direct WHEN/THEN accepted, detached detail accepted and two-space continuation accepted. Raw retention and BOM/CRLF were already passing controls.
- GREEN: the same exact command passed 7/7 after container-aware heading and clause validation. Complete raw Requirement cards are preserved, including nested rich Markdown in modified deltas.
- Adjacent `validate_contract` passed 12/12 during the all-target run. Current specs and delta requirement validation both use the shared clause checks.

All Rust commands ran from `Tools/openspec`. No UE build/Automation or historical business-record validation was selected: this is a portable document-parser and authoring contract change. Maintained generated test fixtures are owned; existing business records and archives are not.

## Task 3.1 — maintained consumers and authoring

- `cargo test --locked --all-targets`: 189/189 passed for the final 0.9.0 source before local publication. This includes 13 structured Task cases, 15 adjacent graph cases, 7 structured Spec cases, 13 validator cases, 20 workflow cases and all other portable targets.
- `cargo clippy --locked --all-targets -- -D warnings`: passed after replacing one obsolete let-else with Option propagation; `cargo fmt --all` applied normal formatting.
- An added record-v1 negative control first demonstrated that missing THEN was previously accepted; the new scenario check passes while generic records and absent optional specs remain valid.
- Additional RED controls exposed lazy Task paragraph continuations and one-space behavior clause roots. They now fail explicitly; the exact structured Task/Spec group passed 20/20.
- Candidate `Authoring.Tests.ps1`: filled examples and completed scaffolds passed exact parser/CLI checks, including negative controls. The three owned synchronized Requirement blocks passed isolated strict validation and complete raw-block containment checks.
- Independent generation evidence and the narrow wrapped-clause correction are recorded in authoring-exercise.md and its indexed data files.

## Local source identity

The exact source scope was committed through Harness run `25965c65907749db83e87d75bead01ee`: source commit `aa9754508c384e392eecd1c54201c623dca3404e` on local branch `release/structured-markdown-0.9.0`. Harness also recorded only its gitlink in parent commit `0f0cf23ee78e563bf93dcf20b43a55381948273d`. No other parent paths were committed, and no remote was pushed. The source has annotated local tag `v0.9.0` for the required package publisher.
