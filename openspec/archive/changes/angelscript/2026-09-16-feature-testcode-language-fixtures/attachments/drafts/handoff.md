# Handwritten Language fixture handoff

## Authorization and source

Source identity: angelscript/test-code-language-corpus / designs/language-fixture-corpus. Q106 accepted all 47 files, Q108 selected a separate second Change, Q110 settled `angelscript/feature-testcode-language-fixtures`, and the current user explicitly requested its creation. The session preference to summarize relevant rationale and knowledge into Changes is retained.

## OpenSpec Handoff

- ID: angelscript/feature-testcode-language-fixtures.
- Outcome: 47 publicly queryable complete-version source containers and matching projections, with production Counter retired safely.
- Integration fixture: Language/Syntax/StructFields, root/add-field/invalid-duplicate-field.
- Primary author checks: current codegen check plus the attached exact per-fixture verifier.
- Admission proof: focused Framework tests; no AS compilation or execution.
- All six themes and every accepted tag are listed in findings/container-inventory.md. Raw source routing appears in findings/legacy-source-inventory.md.

## Exploration Carryover

| Source | Destination | Reason |
|---|---|---|
| Q10/Q106, selected design/files/glossary | English draft exports and 47-file inventory | Preserve the complete accepted author scope |
| Current legacy tree and source check | Legacy inventory and migration-check finding | Concrete source paths and hidden Counter consumers |
| Q108 and current second-Change request | Talk: independent-handwritten-corpus | Prevent coupling to generator implementation |
| Counter replacement decision and current integration source | Talk: real-fixture-adoption | Preserve database/annotation proofs during replacement |
| Current author/runtime layer contract | Knowledge: source-admission-boundary | Negative material is not a container parse failure |
| Old source wrappers and host dependencies | Knowledge: scenario-migration | Migrate concerns and provenance rather than copy host wrappers |

## Completion boundary

All 47 exact tags, complete versions, matching projections, bounded source dispositions, updated examples and focused Framework queries pass before implementation completion. Creation itself changes only this planning record and local draft navigation. The 47-file target is not permission to reduce coverage to a sample.
