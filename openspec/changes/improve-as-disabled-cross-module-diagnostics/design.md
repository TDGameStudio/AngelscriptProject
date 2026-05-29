## Context

`AngelscriptFunctionTableExporter` scans all UHT session modules and records skipped Angelscript-callable functions. For functions whose direct signature builder fails with `unexported-symbol`, the exporter currently reports `target-module-disabled` whenever the module is outside `AngelscriptRuntime.Build.cs` supported modules. That is useful as a coarse boundary marker, but it prevents planning the next coverage step because it does not say whether enabling that module would produce a frame wrapper.

## Goals / Non-Goals

**Goals:**

- Quantify disabled-module unexported-symbol candidates that are already safe for cross-module frame-wrapper generation.
- Reuse the same signature and protocol classifier used by enabled modules so the diagnostic is comparable.
- Keep CSV output simple and stable enough for tests and manual reporting.

**Non-Goals:**

- Do not add new supported modules.
- Do not generate cross-module wrapper files for disabled modules.
- Do not change direct-bind runtime ABI or AngelscriptRuntime dependencies.
- Do not implement out/ref, container, interface, delegate, WorldContext, or RPC protocols.

## Decisions

- Use reason prefixes rather than adding new CSV columns. `disabled-safe-cross-module` represents a disabled module candidate that passes the current cross-module classifier. Other disabled candidates use `disabled-<existing-reason>`, such as `disabled-needs-out-param-protocol`.
- Keep `target-module-disabled` only as a fallback for cases where classification cannot run. This preserves a coarse bucket for unexpected future states without hiding diagnosable candidates.
- Source the classifier from `AngelscriptFunctionTableCodeGenerator.TryClassifyCrossModuleOutcome` so enabled and disabled module diagnostics stay aligned.

## Risks / Trade-offs

- `disabled-safe-cross-module` is still a planning diagnostic, not a guarantee that enabling the module is dependency-safe. The module may be editor-only, plugin-gated, or otherwise inappropriate for default generation.
- Classifying disabled modules may add small UHT diagnostic cost. The classifier already runs during generation and only reads UHT metadata/header resolver state, so the cost should be acceptable.
