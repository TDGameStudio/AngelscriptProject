---
record: harness-workflow-evaluation-v1
result: passed
change: angelscript/test-lexer-isolated-coverage
closure_kind: completed
input_sha256: a0e98e73d9654c70dd4a50c20daeaaafddf995a8d000ff44d4fa48258fd8ea4d
captured_at: 2026-09-12T14:40:14.2944383+08:00
---

# Completed lifecycle evaluation

## Lifecycle and evidence

The Change moved the isolated tokenizer contracts from `NewVersion`, introduced one std-owned capture/check helper, added bounded spelled-kind and recovery matrices, and repaired the proven leading UTF-8 BOM whitespace defect. Four Task DAG nodes are complete. Feature-group evidence retained the task 1.1 skeleton RED, the task 1.2 first executable characterization, the task 1.3 grouped 30/31 BOM RED, and the final-content GREEN build/test identity. Final Harness build `bfecef23c75145e1af2a8cabab9291b8` succeeded; focused run `b591e841a50e4bbaa37bd60bafb27a97` passed 31/31 with zero warnings or errors across 18 Contracts, four SpelledKinds, and nine Recovery methods.

## Friction and corrective action

Planning evolved through accepted replans that unified the tokenizer-test boundary, selected standard-library ownership, incorporated the fixed Clang gap audit, and confined aliases to CQTest class scope for Unity safety. Completion verification then exposed pre-existing two-space Scenario Card detail indentation in the two affected current specs. A verification-driven task 1.4 authorized only indentation normalization; leading-whitespace-stripped line hashes remained identical, both targets passed strict validation, and no behavior text or parentage changed. One exploratory `openspec.doctor` invocation incorrectly supplied a Change argument; the documented no-argument route was rerun successfully and no repository defect was inferred.

## Durable outcome and ownership

Both delta specs are synchronized. The lexing capability now records leading `EF BB BF` as three-byte trivia with original byte ranges and no Unicode diagnostic. The testing baseline records the nested `Angelscript.UnitTest.NativeEngine.Lexer.<Scenario>.<Method>` identity and permits replacement NativeEngine sources beneath the module-root `NativeEngine/` tree. The verified isolated-lexer oracle guidance is promoted to `angelscript/language/frontend/lexing/knowledges/isolated-lexer-test-oracles.md`. Generic TestCode, source catalogs, typed rows, artifacts, and reusable generators remain owned by `angelscript/refactor-testing-unified-framework`.

## Closure scope

Strict affected-spec, Change, and repository validations pass; the closing Change ID is absent from reusable Harness defaults. There are no material issue or Review records, no performance aggregate, and no unresolved local or planning defect. Quick, Performance, Integration, PP/Sema/VM selectors, random fuzzing, and a full Unreal suite were omitted because the demonstrated implementation impact is confined to tokenizer BOM whitespace classification and the full focused Lexer prefix proves the affected contract. No Git commit, integration, push, workspace removal, or external publication is part of this closure.

This evaluation is the final active Change input except for its own excluded file. It binds every other ordinary Change file using CurrentInputSha256 `a0e98e73d9654c70dd4a50c20daeaaafddf995a8d000ff44d4fa48258fd8ea4d`, obtained from ordinary exact evolution run `808288f037e74c08924764ec9a623394` after the exact INDEX membership, completion evidence, synchronized-spec disposition, knowledge disposition, and completed closure manifest were final.
