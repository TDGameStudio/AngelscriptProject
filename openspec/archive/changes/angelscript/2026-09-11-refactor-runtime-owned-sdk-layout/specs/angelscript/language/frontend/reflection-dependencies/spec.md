## MODIFIED Requirements

### Requirement: The compilation facade returns one concrete semantic result

The fork-internal CompilationSession/Builder facade SHALL return `FAngelscriptPreprocessResult` as the concrete owner-visible result of preprocessing and declaration semantics for one frozen source configuration. The preprocessor itself SHALL remain a directive/token producer; declaration orchestration belongs to the compilation facade.

Fork-internal result and consumer leaves MAY remain under `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/` for source organization, but SHALL be declared directly inside `BEGIN_AS_NAMESPACE` with final names and no nested `frontend`, replacement `Frontend`/`V2` surface or compatibility aliases.

#### Scenario: A caller names the reconstructed preprocessing API

- **WHEN** code includes a reconstructed leaf from `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/`

    The header retains the existing AS namespace configuration; its directory does not impose another C++ scope. Include the leaf as `"frontend/<header>"` against the first-party SDK include root `Source/AngelscriptRuntime/angelscript`.

- **THEN** it refers to that leaf directly in the scope selected by `BEGIN_AS_NAMESPACE`

    `AS_NAMESPACE_QUALIFIER` names the canonical type from an external C++ scope, without a nested `frontend` qualifier.

- **BUT** no nested `frontend`, parallel `Frontend`/`V2` surface, namespace alias or using declaration preserves the retired API

    Existing directory paths and conceptual frontend terminology remain valid; exported C++ consumers are rebuilt against the canonical declarations.
