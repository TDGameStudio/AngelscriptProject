## MODIFIED Requirements

### Requirement: Bind descriptor calls return a chainable node view

New `FAngelscriptBind` descriptor entry points SHALL return an `FAngelscriptBindNode` that identifies the descriptor node just created, not an AngelScript function/property ID. The node view SHALL retain the root reference plus owner kind/identity needed to resume the corresponding type/global/enum fluent surface without pointing at a temporary view object, so subsequent declarations remain fluent without a required `EndMember()` call.

Per-engine function/property IDs SHALL be stored only in `FAngelscriptBindingNodeResult` after explicit application.

#### Scenario: Method descriptor returns a valid node view

- **WHEN** a provider adds a method node
- **THEN** the returned node view SHALL identify that method through a draft-local node key plus owner-generation token
- **AND** options applied through the view SHALL update that method descriptor before any engine registration.

#### Scenario: Frozen method receives a stable NodeId

- **WHEN** Registry registration parses, normalizes, validates, and freezes a valid method descriptor
- **THEN** the immutable node SHALL receive its stable semantic NodeId
- **AND** the NodeId SHALL be available through catalog/apply results rather than retroactively turning the consumed draft view into a live handle.

#### Scenario: Applied method result exposes the AS ID

- **WHEN** the applier registers the method successfully
- **THEN** its node result SHALL expose the non-negative function ID returned by that engine
- **AND** the pre-application node view SHALL not be mutated into an engine-owned ID handle.

#### Scenario: Property descriptor returns a valid node view

- **WHEN** a provider adds a global or object property
- **THEN** the returned node view SHALL identify that property descriptor
- **AND** a successful apply result SHALL carry the target engine's property ID or registration result separately.

#### Scenario: Discarded node view remains valid usage

- **WHEN** a provider ignores a returned node view
- **THEN** registering the root `FAngelscriptBind` and applying its internal package SHALL still register that descriptor.

### Requirement: Chainable trait setters mutate the just-bound function

`FAngelscriptBindNode` SHALL expose fluent methods covering editor-only, deprecation, property-accessor, no-discard, world-context, callable, generated-accessor, implicit-constructor, compile-out, force-constant-arguments, output-type selection, script-function/script-object forwarding, pure-constant property, documentation, and native-form behavior. Each method SHALL write only the view's descriptor and return a chainable view.

The applier SHALL translate descriptor values to the same applicable `asCScriptFunction`, `asCGlobalProperty`, documentation, and StaticJIT/native semantics after registration.

#### Scenario: Single chained trait

- **WHEN** a provider writes `.Method(...).EditorOnly()`
- **THEN** only that method descriptor SHALL contain the editor-only trait
- **AND** its applied function SHALL have `asTRAIT_EDITOR_ONLY` under the existing configuration rules.

#### Scenario: Multiple chained traits

- **WHEN** a provider writes `.Method(...).EditorOnly().Deprecated("Use NewBar")`
- **THEN** that node SHALL contain both values
- **AND** its applied function SHALL have the equivalent editor-only and deprecated behavior and message.

#### Scenario: Chaining advances to another node

- **WHEN** a provider writes `.Method(A).NoDiscard().Method(B).EditorOnly()`
- **THEN** A SHALL receive only no-discard and B SHALL receive only editor-only
- **AND** registration or configuration of another package SHALL not change either association.

#### Scenario: Property pure-constant chain

- **WHEN** a provider adds a const global property and applies `.PureConstant<int32>(42)`
- **THEN** only that property descriptor SHALL carry the constant value
- **AND** its applied `asCGlobalProperty` SHALL expose equivalent pure-constant behavior.

### Requirement: Fluent views cannot outlive or mutate a consumed Bind

`TAngelscriptBindType<T>`, `FAngelscriptBindGlobals`, `FAngelscriptBindEnum`, and `FAngelscriptBindNode` SHALL be non-owning views into one `FAngelscriptBind`. Moving the root or consuming it through `FAngelscriptBindingRegistry::Register(FAngelscriptBind&&)` SHALL invalidate all views previously obtained from that root.

Development builds SHALL diagnose use of a stale view through an owner/generation token or equivalent check. A view SHALL NOT keep a consumed draft mutable and SHALL NOT auto-register on destruction.

#### Scenario: Root Bind is moved

- **GIVEN** a node view obtained from Bind A
- **WHEN** Bind A is moved into Bind B
- **THEN** the old view SHALL be invalid
- **AND** attempting to mutate through it in a development build SHALL produce a deterministic diagnostic rather than modifying Bind B accidentally.

#### Scenario: Registry consumes the Bind

- **GIVEN** a node view obtained from a valid draft
- **WHEN** the root is passed to `Register(MoveTemp(Bind))`
- **THEN** the root and all its prior views SHALL no longer be mutable
- **AND** the registry SHALL own only the frozen internal package after successful registration.

### Requirement: Legacy free-function trait setters remain functional with deprecation

When `WITH_ANGELSCRIPT_LEGACY_BINDS=1`, the old PreviousBind trait setters SHALL remain callable through an isolated Legacy adapter and preserve their existing observable behavior for downstream callbacks. When the gate is `0`, those declarations, PreviousBind slots, and opaque callback support SHALL be absent from the new binding core.

New in-tree providers and new binding-core consumers SHALL NOT use the legacy setters. The new applier SHALL NOT write `FAngelscriptBindState::PreviouslyBoundFunction` for descriptor nodes.

#### Scenario: Legacy callback uses a previous-function setter

- **GIVEN** a default compatibility build
- **WHEN** an unmigrated downstream legacy callback registers a function and invokes a PreviousBind trait setter
- **THEN** the Legacy adapter SHALL apply the same observable function trait
- **AND** that state SHALL remain confined to the explicit legacy callback invocation for the selected engine.

#### Scenario: New package and legacy callback coexist

- **WHEN** one legacy callback and one non-colliding new package execute in a compatibility build
- **THEN** both SHALL apply their own metadata correctly
- **AND** the new node SHALL not read or overwrite Legacy PreviousBind state.

#### Scenario: Legacy-disabled build removes dependency

- **WHEN** the plugin builds with `WITH_ANGELSCRIPT_LEGACY_BINDS=0`
- **THEN** all new production bindings and metadata consumers SHALL compile without PreviousBind declarations or state.

## REMOVED Requirements

### Requirement: Trait-write semantics are byte-identical to baseline

**Reason**: Raw per-engine registration IDs and unrelated serialized artifacts are not a sound acceptance contract for trait attachment. Requiring them to be byte/number-identical would preserve static callback order as a permanent identity contract and prevent deterministic package ordering.

**Migration**: Preserve script-visible declarations, registration counts, trait behavior, native metadata, documentation, and execution results. Compare observable behavior and treat `Binds.Cache` as its separate reflected `Structs`/`Classes` regression surface rather than adding catalog identity to it.

## ADDED Requirements

### Requirement: Trait-write semantics preserve observable binding behavior

For the same enabled binding surface, the descriptor/applier path SHALL preserve script-visible type/function/property counts, declarations, trait values, documentation, native behavior, and compile outcomes. Raw per-engine AS IDs MAY change when deterministic package order differs from legacy callback order. `Binds.Cache` SHALL retain its separate reflection-binding meaning and SHALL NOT become the catalog identity store in this change.

#### Scenario: Type and function counts remain compatible

- **WHEN** the editor initializes with the fully migrated package set
- **THEN** object type, method, behavior, global function, and global property counts SHALL match the characterized enabled baseline except for separately approved binding changes.

#### Scenario: Reflection bind cache remains compatible

- **WHEN** provider migration exercises `Binds.Cache` creation and loading
- **THEN** its reflected `Structs`/`Classes` records SHALL remain loadable and behaviorally compatible
- **AND** the cache SHALL NOT require PackageId, NodeId, catalog fingerprint, or raw AS registration IDs.

#### Scenario: Trait state remains equivalent

- **WHEN** representative scripts compile and execute against migrated nodes
- **THEN** no-discard, editor-only, deprecation, accessors, compile-out, native form, pure constants, and forwarding traits SHALL have the same observable behavior as the characterized baseline.
