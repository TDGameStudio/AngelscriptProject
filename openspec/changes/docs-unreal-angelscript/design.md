## Context

The project currently documents its AngelScript engine as based on `AS 2.33` with selective `2.38` compatibility. That remains useful as upstream provenance, but it is no longer a good version label for the actual UE runtime. The fork has structural UE-specific behavior across memory allocation, module storage, type metadata, hot reload, object lifetime assumptions, bytecode restoration, binding, debugging, and editor workflows.

The change should therefore separate three concepts:

- Product identity: the user-facing name of the plugin and language integration.
- Runtime/fork version: the version line owned by this project.
- Upstream lineage: the historical AngelScript source baseline and selective backport range.

## Goals / Non-Goals

**Goals:**

- Use `Unreal AngelScript` as the primary user-facing identity.
- Use `UEAS Runtime` as the versioned label for the deeply customized runtime/fork.
- Keep upstream provenance visible as `AngelScript 2.33-WIP lineage + selective 2.38 backports`.
- Provide a precise implementation plan that can be applied later without changing runtime behavior.

**Non-Goals:**

- Do not rename the `Plugins/Angelscript` directory.
- Do not rename Unreal modules such as `AngelscriptRuntime`, `AngelscriptEditor`, `AngelscriptTest`, or optional extension modules.
- Do not change `.uplugin` names, public API names, automation test prefixes, namespaces, config keys, or generated asset paths.
- Do not change compiler, runtime, bytecode, debug protocol, binding, hot reload, or UHT behavior.
- Do not claim full compatibility with vanilla AngelScript 2.38 or any future upstream release.

## Decisions

### Decision 1: Use `Unreal AngelScript` as the product identity

`Unreal AngelScript` is explicit, readable, and aligns with the actual deliverable: a UE plugin that integrates AngelScript as a first-class scripting option. It avoids presenting the fork as a vanilla AngelScript version.

Alternatives considered:

- `AngelScript UE Edition`: clear, but reads like an official upstream distribution.
- `UEAS`: useful as an abbreviation, but too opaque as the first public-facing name.
- `AngelScript-UE Fork`: technically honest, but too internal for primary user-facing documentation.

### Decision 2: Use `UEAS Runtime` for fork versioning

`UEAS Runtime` gives the project an owned version line independent of upstream AngelScript version numbers. A recommended first label is `UEAS Runtime 1.0`, with upstream lineage documented separately.

Alternatives considered:

- `AS 2.33+`: still implies vanilla AngelScript compatibility.
- `AS 2.33-UE`: better than `AS 2.33`, but still anchors the runtime identity to an obsolete upstream baseline.
- `UEAS APV2 Runtime`: precise internally, but exposes implementation terminology that users do not need.

### Decision 3: Keep upstream lineage as technical metadata

Docs that discuss source provenance, selective backports, or compatibility should keep the technical formula:

```text
AngelScript 2.33-WIP lineage + selective 2.38 backports
```

This preserves auditability without making `2.33` the product version.

## Risks / Trade-offs

- Existing docs, scripts, or discussions may still use `AS 2.33` casually -> mitigate with a targeted documentation inventory and a grep-based validation task.
- Some readers may confuse `UEAS Runtime` with a module rename -> mitigate by explicitly stating that module/plugin names remain unchanged.
- A future runtime version scheme may need more precision -> mitigate by defining `UEAS Runtime` as the owned version line while leaving exact numeric policy to the implementation pass.
- Over-updating technical docs could hide upstream provenance -> mitigate by preserving `2.33-WIP lineage + selective 2.38 backports` in fork strategy and low-level SDK docs.

## Migration Plan

1. Inventory user-facing and technical documentation that currently uses `AS 2.33`, `AngelScript 2.33`, or `2.33 + selective 2.38`.
2. Classify each occurrence as product identity, runtime/fork version, or upstream lineage.
3. Update product-facing wording to `Unreal AngelScript`.
4. Update runtime/fork wording to `UEAS Runtime`.
5. Preserve or clarify upstream-lineage wording in technical docs.
6. Validate with OpenSpec validation and grep checks.

Rollback is straightforward because this is documentation-only: revert the changed documentation files and leave implementation code untouched.

## Open Questions

- Should the first owned runtime version be recorded as `UEAS Runtime 1.0`, `UEAS Runtime 2026.1`, or left unnumbered until the next release?
- Should `UEAS` be introduced globally as an abbreviation on first use, or limited to technical documents?
- Should the root README and plugin README use identical naming text, or should the plugin README stay more consumer-focused?
