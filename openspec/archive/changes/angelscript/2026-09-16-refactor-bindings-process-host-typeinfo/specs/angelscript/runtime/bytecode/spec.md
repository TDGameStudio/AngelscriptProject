## MODIFIED Requirements

### Requirement: Source definition placement preserves published dependencies and private ownership

The SDK SHALL compile without an Engine and register private source TypeInfo and runtime bytecode only against the receiving Engine's admitted dependencies, retaining shared host graphs without transferring their ownership.

#### Scenario: Adopt compiled source using a prebuilt native type

- **GIVEN** a frozen HostProcess Pair graph supplied through Options.Dependencies
- **WHEN** source using Pair is compiled and registered on an Engine that injected that graph
- **THEN** the new script types/functions and runtime bytecode belong to that Engine, while Pair remains the same shared null-Engine object
- **BUT** an uninjected Engine cannot register or execute that source merely by possessing the frozen dependency pointer

#### Scenario: Retire private bytecode without retiring host definitions

- **GIVEN** A and B each register private script functions against one injected host Pair graph
- **WHEN** A's private bytecode and definitions retire
- **THEN** B's script execution and the shared Pair function/native leases remain valid
