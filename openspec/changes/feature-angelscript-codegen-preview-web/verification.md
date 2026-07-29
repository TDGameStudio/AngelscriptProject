# Verification — AngelScript CodeGen Preview Web

Verified from `Tools/AngelscriptCodeGen` on 2026-07-23.

| Check | Command / interaction | Result |
| --- | --- | --- |
| Optional dependencies | `python -m pip install -e ".[web,dev]"` | Installed the editable package with FastAPI/Uvicorn and test dependencies. |
| Unit and API regression suite | `python -m pytest -q` | `45 passed in 0.54s` |
| Python compilation | `python -m compileall -q src` | Exit code `0` |
| CLI contract | `python -m angelscript_codegen serve --help` | Exposes only `--port` and `--open`; no host argument is available. |
| Built wheel contents | `python -m pip wheel . --no-deps --wheel-dir <temp>` then archive inspection | Wheel contains `web/static/index.html`, `app.js`, `app.css`, and Profile JSON files. |
| Loopback service smoke | Start `python -m angelscript_codegen serve --port 9877`, then request `/`, `/api/scenarios`, and `/api/preview` | Root returned `200`; four scenarios returned; `actor-lifecycle` produced `ue-world`, `compile-pass`, `source-only` source containing `BeginPlay`. The server process was stopped after the check. |
| OpenSpec and whitespace | `openspec validate feature-angelscript-codegen-preview-web --strict`; scoped `git diff --check`; scoped trailing-whitespace scan | All checks passed. |

Port `8765` was already occupied by a pre-existing local process during verification, so the smoke check intentionally used `9877` without touching that process. This does not alter the command default of `8765`.

No Unreal build, AngelScript compilation, script execution, CQTest rendering, source-artifact write, catalog write, or `Saved` output was performed by this Web preview change; those actions remain explicitly outside this source-only capability.
