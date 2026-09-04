## MODIFIED Requirements

### Requirement: Legacy runtime is locked dormant during reconstruction

The system SHALL apply one non-configurable startup-wide reconstruction gate that keeps the preserved legacy AngelScript runtime disabled.

#### Scenario: Default startup remains dormant
- **GIVEN** the project is in the reconstruction baseline
  > Context: Legacy source remains present for reference, but presence does not grant startup authority.
- **WHEN** the host project starts and loads the AngelScript modules
  > Inputs: The checked-in reconstruction gate applies before legacy services can initialize.
- **THEN** the `UAngelscriptSubsystem` is created but owns no primary engine, publishes no ambient engine, and is not allowed to tick
  > Observables: Subsystem existence remains compatible with Unreal lifecycle discovery while runtime execution stays dormant.
- **AND** legacy runtime, editor, JIT-provider, script-test, coverage, crash-snapshot, directory-watcher, menu, debug-bridge, and optional GameplayTags extension side effects are not started
  > Observables: None of the preserved legacy service surfaces acquire registrations, workers, watchers, or active execution state.
- **BUT** the AngelScript project settings remain available in the editor
  > Boundaries: Settings visibility is retained configuration UI, not a reactivation path.

#### Scenario: Compatibility initializer cannot bypass dormancy
- **GIVEN** the hard reconstruction gate is active
  > Context: Compatibility APIs remain callable so preserved consumers can compile during reconstruction.
- **WHEN** a caller invokes `FAngelscriptRuntimeModule::InitializeAngelscript()` or requests subsystem engine initialization
  > Inputs: Direct compatibility calls and subsystem-mediated requests are governed by the same gate.
- **THEN** no AngelScript engine is created, adopted, or published
  > Observables: The primary-engine owner and ambient-engine surface both remain empty.

#### Scenario: Configuration cannot reactivate legacy startup
- **GIVEN** the hard reconstruction gate is active
  > Context: The baseline is deliberately source-controlled rather than a user-togglable runtime mode.
- **WHEN** project configuration is changed or a compatibility initializer is invoked
  > Inputs: Configuration values and legacy initialization requests have no precedence over the reconstruction gate.
- **THEN** the legacy runtime remains dormant
  > Observables: Startup behavior is unchanged across configuration variants.
- **AND** reactivation requires a later explicit implementation Change with its own verification
  > Boundaries: No undocumented flag or compatibility entry may reactivate the preserved system.

### Requirement: Dormant modules retain reversible shells

The system SHALL keep legacy runtime, editor, test, JIT carrier, and optional-plugin module shells loadable while cleaning up only the services each module actually started.

#### Scenario: Disabled module shutdown is side-effect safe
- **GIVEN** a module loaded under the hard reconstruction gate
  > Context: Its shell may exist even though its legacy services never entered a started state.
- **WHEN** Unreal shuts down that module
  > Inputs: Shutdown observes the module's actual startup ownership rather than assuming every legacy service was registered.
- **THEN** shutdown does not unregister, detach, or cancel legacy services that were never started
  > Observables: Teardown avoids invalid delegate removal, worker cancellation, or provider unregistration.
- **AND** the retained settings registration is removed normally
  > Verification: The module shell's one intentionally retained registration follows its ordinary balanced lifecycle.
