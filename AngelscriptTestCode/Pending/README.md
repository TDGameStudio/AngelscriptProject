# Pending fixtures

Holding area for cases that are not in the admitted 47-file `Language/` catalog. `CodeGenTool` discovery skips the `Pending/` root, so these files do not require plugin C++ projections yet.

Promote a file by moving it to `Language/<theme>/<name>.as` (or the matching theme tree later) and running `codegen.py generate` when plugin writes are allowed.

Two populations live here:

1. **Hand-authored Language / container cases** — one concern per file. New themes this wave: Mixin, Auto, Const positives, Syntax/Function, plus thicker Class/Inheritance/Destructors/Typedef/Properties and split TArray exceptions.
2. **Absorbed `TestSource-old` leftovers** — every leftover `.as` except the 147 Language files already adapted into the admitted catalog. Re-run `python AngelscriptTestCode/Pending/tools/absorb_testsource.py` from the repo root after changing the absorb rules. Default leaves existing files in place. `--wipe` only resets absorb destinations; hand prefixes and files with no legacy dest stay.

```
TestSource-old/*.as
├─ Language + Migration "adapted"  -> skip (already in Language/)
├─ HotReload Before/After/Version_N -> one Pending/HotReload/<scenario>.as
└─ every other leftover             -> one Pending/<theme>/.../<Case>.as
```

| Theme | Legacy `.as` | Skipped adapted | Pending containers |
| --- | ---: | ---: | ---: |
| Bindings | 580 | 0 | 580 |
| Containers | 215 | 0 | 215 |
| Debugger | 3 | 0 | 3 |
| Definitions | 521 | 0 | 521 |
| Feature | 367 | 0 | 367 |
| Gameplay | 152 | 0 | 152 |
| HotReload | 207 | 0 | 97 |
| Language | 624 | 147 | 477 |
| Math | 111 | 0 | 111 |
| Optional | 116 | 0 | 116 |
| TestFramework | 59 | 0 | 59 |
| World | 124 | 0 | 124 |
| **total** | **3079** | **147** | **2822** |

See `CENSUS.md` for HotReload merges. Pending currently holds **2928** `.as` files (absorbed leftovers plus hand-authored thicken).

Bindings keep the numeric suffix (`Test_Queries_01` → `Bindings/AActor/Queries_01`). `Function/` is dropped as the default positive harness; `Reject/`, `UClass/`, `Advance/`, and `Exception/` stay in the path.

## Hand-authored Language next-wave

One concern per file. The original 30 plus this wave's siblings live under these trees; `Language/Migration.md` lists the first wave in detail.

| Tree | Files | What it covers |
| --- | ---: | --- |
| `Language/Class/` | 12 | `this`, constructors, fields, private, method call |
| `Language/Inheritance/` | 11 | override, super, final, three-level, handle upcast |
| `Language/Destructors/` | 7 | class/struct destructor, including field reads |
| `Language/Typedef/` | 9 | alias, handle alias, return, chain |
| `Language/Properties/` | 8 | get_/set_, getter-only, setter type |
| `Language/Mixin/` | 7 | function mixin + `mixin class` rejects |
| `Language/Auto/` | 6 | infer int/float/bool/ctor; void and reassign rejects |
| `Language/Const/` | 6 | const local/method/param plus the three mutation rejects |
| `Language/Syntax/Function/` | 8 | arity, duplicate param, nested function, keyword names |

Container thicken this wave: TArray exception mashups split (`SetNumNegative`, `CopySelf`, `AddAliasedElement`, …), plus TOptional / TSet / TMap one-concern observes (`Overwrite`, `AddDuplicate`, `FindMissing`).
