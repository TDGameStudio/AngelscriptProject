## RENAMED Requirements

- FROM: `### Requirement: The preprocessor facade returns one concrete semantic result`
- TO: `### Requirement: The compilation facade returns one concrete semantic result`

## MODIFIED Requirements

### Requirement: The compilation facade returns one concrete semantic result

The fork-internal CompilationSession/Builder facade SHALL return `FAngelscriptPreprocessResult` as the concrete owner-visible result of preprocessing and declaration semantics for one frozen source configuration. The preprocessor itself SHALL remain a directive/token producer; declaration orchestration belongs to the compilation facade.

Fork-internal result and consumer leaves MAY remain under `ThirdParty/angelscript/source/frontend/` for source organization, but SHALL be declared directly inside `BEGIN_AS_NAMESPACE` with final names and no nested `frontend`, replacement `Frontend`/`V2` surface or compatibility aliases.

#### Scenario: A source set completes declaration semantics
- **WHEN** a caller completes a source set's declaration semantics through CompilationSession/Builder
  > Inputs: Immutable source snapshots, one frozen frontend configuration, and the read-only semantic environment established by prerequisite frontend capabilities.
- **THEN** the caller receives one successful `FAngelscriptPreprocessResult`
  > Observables: The result contains the source/typed-AST lease, retained directive/preprocessing record, resolved module descriptors, declaration dependency graph, separate body invalidation graph, and structured diagnostics.

  | Result surface | Durable meaning |
  |---|---|
  | Source/AST lease | Keeps every descriptor range and stable source anchor queryable |
  | Directive/preprocessing record | Retains active-configuration routing, inactive ranges, and AST source backquery without becoming a second semantic graph |
  | `FAngelscript*Desc` collection | Concrete UE-facing descriptions for declarations selected by this configuration |
  | Declaration graph | Typed cross-module semantic dependencies and SCC information |
  | Body invalidation graph | Non-layout body references kept outside declaration scheduling |
- **AND** every reflection and dependency fact is derived from the same typed Parser/Sema declarations
  > Verification: NativeEngine Reflection and ModuleGraph tests compare result facts with the owning typed declarations and attributes.
- **BUT** the result does not contain a parallel generic reflection IR, an annotation property bag, or a source-reparsed DTO
  > Boundaries: The typed AST remains the semantic authority and the concrete descriptors are its UE-facing projection.

#### Scenario: A caller names the reconstructed preprocessing API
- **WHEN** code includes a reconstructed leaf from `ThirdParty/angelscript/source/frontend/`
  > Inputs: The header retains the existing AS namespace configuration; its directory does not impose another C++ scope.
- **THEN** it refers to that leaf directly in the scope selected by `BEGIN_AS_NAMESPACE`
  > Observables: `AS_NAMESPACE_QUALIFIER` names the canonical type from an external C++ scope, without a nested `frontend` qualifier.
- **BUT** no nested `frontend`, parallel `Frontend`/`V2` surface, namespace alias or using declaration preserves the retired API
  > Boundaries: Existing directory paths and conceptual frontend terminology remain valid; exported C++ consumers are rebuilt against the canonical declarations.

#### Scenario: Conditional source selects one active declaration surface
- **WHEN** the same source snapshots are processed under a particular frozen conditional configuration
  > Details: The prerequisite preprocessing capability retains inactive ranges and directive history but sends only active tokens to Parser/Sema.
- **THEN** descriptors and declaration dependency edges are emitted only for declarations in the selected active branch
  > Observables: A different configuration produces a separate result whose declarations can be compared through stable keys.
- **BUT** inactive declarations are not emitted as partially resolved descriptors or graph vertices
  > Boundaries: Inactive-source tooling remains available through the preprocessing record, not the reflection result.

#### Scenario: Declaration semantics fail
- **WHEN** Parser/Sema reports an unresolved type, invalid reflection attribute, conflicting declaration, or another declaration error
- **THEN** the result reports failure with structured source diagnostics and exposes no publishable resolved descriptor set
  > Observables: Callers cannot mistake partial candidates for a materialization input.
- **AND** no runtime or reflection object is created or mutated
  > Verification: Runtime pointer fields remain null and the live Engine and UE reflection registries are unchanged.

## ADDED Requirements

### Requirement: Host descriptions are declaration-stage products
The frontend SHALL expose collected declaration information and resolved signature/dependency descriptions independently of UE object materialization.

#### Scenario: Observe an early callable declaration
- **WHEN** delegate/event declaration collection completes before all signature types resolve
- **THEN** a host can inspect the name, declaration kind, authored range and unresolved signature locations
- **BUT** the result is not advertised as a resolved reflection signature

#### Scenario: Observe a resolved callable description
- **WHEN** signature types and dependencies resolve successfully
- **THEN** the descriptor consumer supplies the structured signature and single/multicast classification from the original declaration
- **AND** UE reflection pointers remain unmaterialized
  > Boundaries: Reflection shell creation, FProperty completion and public runtime visibility belong to explicit host operations, not preprocessing or AST construction.
