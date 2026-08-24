# Current Python Generator Assessment

## Evidence inspected

- `Tools/AngelscriptCodeGen/README.md`
- `src/angelscript_codegen/model/{case,program,types}.py`
- `src/angelscript_codegen/generation/{random_source,valid,invalid,expressions,statements}.py`
- `src/angelscript_codegen/lifting/angelscript.py`
- `src/angelscript_codegen/output/{catalog,writer}.py`
- `src/angelscript_codegen/profiles/data/*.json`
- the current unit-test tree under `Tools/AngelscriptCodeGen/tests`

## Useful foundations to retain

- The tool is outside the Unreal plugin and already treats profiles as reviewed data rather than discovering arbitrary UE APIs.
- `GenerationCase` is immutable, carries a seed/profile/kind/harness, and separates program construction from lifting/output.
- Positive generation uses a typed `Program`/`Function`/`Statement` model for its small supported subset.
- Negative generation starts from a valid case and injects one named violation, which is the correct structural direction.
- Profile inheritance validates types, callables, fragments, contexts, and evidence.
- The CLI and Web preview already distinguish explicit artifact generation from in-memory preview.
- Existing tests cover deterministic regeneration, profile validation, lifting, catalog hashes, CLI, and Web behavior.

These pieces are migration inputs, not an argument to freeze the current schema.

## Depth gaps

### Program model

`Program` currently contains only a tuple of functions plus raw string fragments. `Function` has a name, return type, and statements but no parameters, owner, qualifiers, attributes, overload identity, executable inputs, or oracle. `Statement` is pre-rendered source plus a type rather than structured declaration/expression/control-flow semantics.

### Executable generation

`ValidProgramGenerator` currently emits one no-argument `GeneratedCase_NNNNNN` returning `int`. The randomized subset is native `int`/`bool` expressions, declarations, branches, bounded loops, and return. That is useful smoke generation, but it does not cover the repository's function parameter directions/positions, return families, writeback, object/reference values, definitions, reflected metadata, containers, lifecycle, or multi-section behavior.

### UE profiles

`ue-annotated` and `ue-world` currently contribute audited fixed source fragments. A fixed `UCLASS` fragment proves the profile can carry UE syntax; it does not generate the UCLASS/USTRUCT/UENUM/UINTERFACE/specifier/member/default/signature product space.

### Oracle

`GenerationCase.expected` is currently `compile-pass` or `compile-fail`, and generated catalogs mark verification as `source-only`. There is no complete typed return, writeback, metadata, side-effect, diagnostic anchor, lifecycle, cleanup, isolation, save/load, or recovery model.

### Random algorithm

`DeterministicRandom` hashes `(seed, ordinal)` with BLAKE2 and delegates choices to Python `random.Random`. This is reproducible within the current Python implementation but is not a specified cross-language observable algorithm. Replicating Python's engine/distribution behavior in C++ would couple the design to an implementation accident.

### Output policy

The CLI currently writes to `Saved/AngelscriptCodeGen` unless `--out` changes it, while Web preview is in memory. The new contract changes the general API default to in-memory and makes all writes explicit; a CLI may still choose an explicit Saved mode as its user-facing default if that mode is visible in its request/manifest.

## Planned reuse and replacement

| Current part | Plan |
| --- | --- |
| Package boundary and no-UE dependency | Retain |
| Profiles/evidence validation | Extend into versioned recipe/capability data |
| Immutable case direction | Replace with complete versioned request/result/oracle model |
| Typed expression/statement seed work | Refactor behind structured recipes and complete executable cells |
| Valid-baseline negative direction | Retain and strengthen with named mutation, diagnostic anchor, and recovery |
| BLAKE2 + `random.Random` observable output | Replace with specified portable algorithms |
| Raw UE fragments | Keep as evidence/goldens where useful; do not treat as product generation |
| Source-only catalog | Replace for rule products with canonical manifest + typed oracle; retain source-only status only for deliberately unexecuted previews |
| Existing tests | Preserve and extend test-first; no broad rewrite before parity evidence |

## Conclusion

The existing tool is a sound exploratory foundation, not a finished generator architecture. The important correction is to make coverage/product/oracle data primary and random syntax secondary. This OpenSpec plans that expansion without prematurely replacing current code.
