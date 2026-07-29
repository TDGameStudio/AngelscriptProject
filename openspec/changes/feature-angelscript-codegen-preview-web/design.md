## Context

The completed `feature-angelscript-codegen-foundation` change produces deterministic source through `ValidProgramGenerator` and formats it through `lift_case`. It deliberately writes to disk only through an explicit output layer. The requested Web surface is a developer preview tool, not a runner, catalog browser, or persistent generation history.

## Goals / Non-Goals

**Goals:**

- Offer four reviewed scenario cards and Chinese user-facing controls.
- Generate exactly one valid case in memory, preserving visible seed-based reproducibility.
- Keep the Web service loopback-only and retain the base CLI's zero runtime dependencies.
- Show source and source-only metadata without creating generated artifacts.

**Non-Goals:**

- Writing `.as` files, `index.json`, run histories, downloads, or output directories.
- Invalid/compile-fail preview, batch generation, arbitrary profile editing, or arbitrary UE API generation.
- Compiling, executing, or running the generated source in Unreal.
- Replacing the CLI or adding a Node/Vite/React toolchain.

## Decisions

### FastAPI plus package-owned static assets

The `web` optional dependency group installs FastAPI and Uvicorn. `serve` lazily imports these packages so `generate` remains dependency-free. FastAPI serves both a small JSON API and static HTML/CSS/ES-module assets from the package. This avoids a second frontend build system while keeping the Python generator as the sole source of generation behavior.

### Scenario cards wrap existing profiles, not new generator semantics

`native-control-flow`, `ue-value-environment`, `uclass-annotation`, and `actor-lifecycle` each map to one existing Profile. Cards are presentation metadata and set profile-specific default bounds. The UE value-environment card must describe the current declared capability environment only; it must not claim that the existing generator emits random FVector or FString operations.

### In-memory valid preview API

`POST /api/preview` accepts a scenario ID, seed, depth, and statement bound. It looks up a reviewed scenario, calls `ValidProgramGenerator.generate(ordinal=0)`, lifts the result, and returns a source-only response. It never calls `generate_cases`, `write_cases`, or any output writer. The API only accepts bounds no greater than the selected Profile's declared limits.

### Local-only, accessible code-workbench UI

`serve` always binds to `127.0.0.1` and offers only a port and browser-open option. The static interface uses Chinese operational copy, text-labelled controls, semantic radio choices, keyboard focus, live error feedback, and plain-text code insertion. Its dark source-workbench presentation derives hierarchy from code metadata rather than marketing decoration, and it respects reduced motion.

## Risks / Trade-offs

- **[Optional dependency not installed]** → `serve` returns a concise Chinese command showing how to install `.[web]`; `generate` stays usable.
- **[A profile's advertised data is mistaken for emitted syntax]** → scenario copy names UE values an environment and tests enforce that card descriptions do not promise unimplemented random value expressions.
- **[Browser endpoint writes files accidentally]** → API tests replace the writer with a failing function and still require a successful preview response.
- **[A local endpoint becomes network-visible]** → the CLI has no host override and runs Uvicorn exclusively on `127.0.0.1`.

## Migration Plan

1. Install `python -m pip install -e ".[web,dev]"` only when using the Web preview.
2. Run `python -m angelscript_codegen serve --open` from the tool directory.
3. Roll back by removing the follow-up Web package/assets and its OpenSpec change; no generated data or plugin migration exists.

## Open Questions

- None for the first in-memory preview release.
