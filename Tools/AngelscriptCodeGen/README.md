# AngelScript Code Generator

`AngelscriptCodeGen` is a standalone Python source producer for reproducible AngelScript test cases. It is deliberately outside the Unreal plugin: this foundation creates `.as` sources and a machine-readable catalog, but does **not** start Unreal, compile a module, execute a script, render C++ CQTest code, minimize failures, or manage a fuzzing corpus.

The generator has separate positive and negative paths. Positive cases are assembled through a typed internal model; negative cases start from that valid baseline and apply exactly one named violation. This keeps a generated failure attributable to one rule rather than random source damage.

## Install and run

The command-line source generator requires Python 3.10 or newer and has no third-party dependency. `pytest` is only needed for development verification. The optional local Web preview installs FastAPI and Uvicorn through the `web` extra.

From this directory, install the package in editable mode:

```powershell
python -m pip install -e ".[dev]"
python -m angelscript_codegen generate --profile native-core --kind valid --count 10 --seed 424242
```

For a no-install source-tree invocation in PowerShell, set `PYTHONPATH` for the current shell:

```powershell
$env:PYTHONPATH = "src"
python -m angelscript_codegen generate --profile ue-annotated --kind valid --count 4 --seed 424242
```

Unless `--out` is supplied, generated files are written to the ignored project directory `Saved/AngelscriptCodeGen/`.

## Local Web source preview

Install the optional Web dependencies, then start the loopback-only preview site:

```powershell
python -m pip install -e ".[web,dev]"
python -m angelscript_codegen serve --open
```

The service listens only on `http://127.0.0.1:8765/`. Use `--port 9000` to choose another local port; there is deliberately no host override that would expose the preview to a network.

The Chinese workbench presents four reviewed scenario cards, a reproducible unsigned 64-bit seed, Profile-bounded expression/statement controls, metadata, source preview, and a copy action:

| Web scenario | Existing Profile | Scope of the preview |
| --- | --- | --- |
| 原生表达式与控制流 | `native-core` | Randomized typed `int`/`bool` expressions, branches, loops, and returns |
| UE 值类型能力环境 | `ue-values` | The reviewed UE capability environment; function-body randomness remains native `int`/`bool` today |
| UCLASS 注解类 | `ue-annotated` | The reviewed `UCLASS` / `UPROPERTY` / `UFUNCTION` fragment plus a valid function sample |
| Actor 生命周期 | `ue-world` | The reviewed `AActor` `BeginPlay` lifecycle fragment in the annotated-class context |

`serve` is a **pure in-memory, single-valid-case preview**. It does not create `.as` files, `index.json`, a corpus, downloads, run history, or any `Saved` output. It also does not start Unreal, compile native or UE AngelScript, execute a script, or render/run CQTest. Use `generate` when a reviewed source artifact and catalog need to be written explicitly.

## CLI contract

```text
python -m angelscript_codegen generate \
  [--profile native-core|ue-values|ue-annotated|ue-world] \
  [--kind valid|invalid] \
  [--count N] [--seed UINT64] \
  [--max-depth N] [--max-statements N] \
  [--out DIRECTORY]
```

- `--profile` defaults to `native-core`.
- `--kind` defaults to `valid`; `invalid` cycles deterministically through the selected profile's declared invalid rules.
- `--count` is a positive number of cases and defaults to `1`.
- `--seed` is an unsigned 64-bit seed and defaults to `0`. A case-local sub-seed is derived from the pair `(seed, ordinal)`, so cases do not depend on process-global random state.
- `--max-depth` and `--max-statements` bound the generated integer/boolean expression and statement subset. They default to `3` and `8`.
- `--out` selects an explicit directory. The tool only writes the generated case names and `index.json` in that directory.

Running the exact same request into two empty output directories produces byte-identical sources and catalogs.

## Profiles

Profiles are versioned JSON data in [`src/angelscript_codegen/profiles/data`](src/angelscript_codegen/profiles/data). They are the only capability source for generation; the Python tool does not discover arbitrary Unreal bindings.

| Profile | Parent | Harness metadata | Current reviewed additions |
| --- | --- | --- | --- |
| `native-core` | — | `native-sdk` | scalar core types, `Record(int)`, positive control-flow subset, and four isolated negative rules |
| `ue-values` | `native-core` | `ue-module` | reviewed UE value/container type declarations and `FMath::Abs` capability metadata |
| `ue-annotated` | `ue-values` | `ue-annotated` | audited `UCLASS` / `UPROPERTY` / `UFUNCTION` source fragment |
| `ue-world` | `ue-annotated` | `ue-world` | audited `AActor` lifecycle fragment plus `actor-lifecycle` cleanup context |

The JSON loader merges parent types, callables, source fragments, contexts, limits, invalid rules, and evidence in deterministic order. It rejects inheritance cycles, unknown type references in callable signatures, duplicate declarations, malformed data, and a callable/fragment that requires an undeclared context. Each UE profile records the relevant `AngelscriptTest/Coverage` source in its evidence field.

The foundation currently randomly constructs the type-safe native `int`/`bool` expression and statement subset (declarations, conditionals, bounded `for` loops, and typed returns). UE values and callable declarations are retained as reviewed profile capability data; randomly invoking arbitrary engine APIs is intentionally deferred until their side effects, world requirements, and cleanup are modeled. The annotated and World profiles do emit their declared source fragments, but the generator does not execute them.

## Generated artifacts

Each `.as` file begins with stable `@as_codegen` comments:

```angelscript
// @as_codegen.case_id: ASCG-native-core-valid-0000000000000000-000000
// @as_codegen.profile: native-core
// @as_codegen.kind: valid
// @as_codegen.seed: 0
// @as_codegen.expected: compile-pass
// @as_codegen.harness: native-sdk
// @as_codegen.verification: source-only
```

`index.json` has `schema_version: 1` and one entry per source. Every entry records `case_id`, `profile`, `kind`, `seed`, `expected`, `harness`, `invalid_rule`, `verification`, relative source `path`, and the source `sha256`.

`expected: compile-pass` and `expected: compile-fail` are generator expectations, not execution results. All foundation cases carry `verification: source-only`; an eventual UE/native runner must update its own result data rather than treating this catalog as runtime proof.

## Development verification

```powershell
python -m pytest -q
$env:PYTHONPATH = "src"
python -m angelscript_codegen generate --profile ue-world --kind valid --count 3 --seed 8848 --out D:\Temp\as-codegen-smoke
```

The unit suite covers semantic invariants, profile inheritance/context validation, deterministic random derivation, valid/invalid case construction, lifting, catalog hashes, CLI generation, and byte-identical regeneration.

## Extension seams intentionally deferred

The package boundaries are intentional future extension points:

- `generation/` — additional typed expressions, statements, calls, classes, handles, and profile-aware API generation;
- `profiles/` — reviewed capability/profile expansion, potentially fed by future state-dump exports;
- `lifting/` — formatting and future module/namespace/class IR support;
- `output/` — runner result attachment or a future persisted corpus;
- a separate future layer — native/UE execution, failure reduction, coverage guidance, and CQTest/C++ rendering.

Do not add generated sources to `Plugins/Angelscript` or `AngelscriptTest/Coverage` from this tool. Those consumers should be connected by a later, explicitly reviewed change.
