# Verification

Verified on 2026-07-23 from `Tools/AngelscriptCodeGen/`.

| Check | Result |
| --- | --- |
| `python -m pytest -q` | `34 passed in 0.08s` |
| `python -m compileall -q src` | Exit `0` |
| CLI smoke, valid and invalid, profiles `native-core`, `ue-values`, `ue-annotated`, `ue-world` | Eight invocations wrote source and `index.json` under ignored `Saved/AngelscriptCodeGen/verification/` with exit `0` |
| CLI default output | A native valid request wrote `Saved/AngelscriptCodeGen/index.json` with exit `0` |
| Determinism | Two `ue-world` valid requests (`count=3`, `seed=8848`, `max-depth=4`, `max-statements=6`) produced four matching files each (`3` sources + `index.json`), compared with SHA-256 |

No Unreal build, AngelScript compiler run, module load, world creation, or CQTest render was performed: this change is intentionally source-only. Generated expectations therefore remain marked `verification: source-only` rather than claiming runtime validation.
