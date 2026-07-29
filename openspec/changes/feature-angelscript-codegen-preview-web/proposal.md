## Why

`AngelscriptCodeGen` currently exposes its deterministic source generation only through a command line. Test developers need a quick, local way to select an audited generation context and inspect one resulting AngelScript source without writing generated files or setting up an Unreal execution run.

## What Changes

- Add an optional FastAPI-powered, loopback-only Web preview entry point to `Tools/AngelscriptCodeGen`.
- Add four Chinese-labelled scenario cards that select the existing native-core, UE value-environment, annotated UClass, and Actor lifecycle profiles.
- Generate exactly one valid case in memory and return its source and source-only metadata to a no-build static page.
- Add Web API, scenario, CLI, static-page contract, and no-file-write regression tests.

## Capabilities

### New Capabilities

- `angelscript-codegen-preview-web`: Provide a local browser UI that selects reviewed generator scenarios and previews one in-memory AngelScript source case.

### Modified Capabilities

- None.

## Impact

- Adds optional `fastapi` and `uvicorn` dependencies under the generator's `web` extra while preserving the existing CLI's base dependency-free runtime.
- Adds a `serve` CLI subcommand, package-owned static assets, and Python tests under `Tools/AngelscriptCodeGen`.
- Does not modify the plugin, existing Coverage tests, source-generation semantics, default output directories, or Unreal test runners.
