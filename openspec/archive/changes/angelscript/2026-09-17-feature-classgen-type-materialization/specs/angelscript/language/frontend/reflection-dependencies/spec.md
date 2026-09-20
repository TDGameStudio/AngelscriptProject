## MODIFIED Requirements

### Requirement: Reflection descriptors have one semantic producer and one definition

#### Scenario: Resolved class descriptors record authored inheritance

- **GIVEN** one publishable source set with a UCLASS base, a UCLASS child, and an interface implementer

    | Record | Source |
    | --- | --- |
    | Actor | `UCLASS() class Actor {};` |
    | Pawn | `UCLASS() class Pawn : Actor {};` |
    | ITickable | `interface ITickable {};` |
    | Ticking | `UCLASS() class Ticking : ITickable {};` |

- **WHEN** the descriptor consumer projects that source set

    Projection uses the same typed `GetResolvedBases()` facts Sema already accepted.
    The first non-interface object base becomes `SuperClass`. Interface bases become `ImplementedInterfaces`.

- **THEN** `Pawn.SuperClass` is `Actor` and `Ticking.ImplementedInterfaces` contains `ITickable`

    `Actor.SuperClass` is empty when no object base was authored.
    `Ticking.SuperClass` is empty when every resolved base is an interface.

- **AND** every runtime-only field remains null

    `CodeSuperClass`, `Class`, `Struct`, and `ScriptType` stay null.
    Lifecycle remains `Resolved`.

- **BUT** a `Resolved` descriptor is not advertised as `Materialized`

    Native `UClass*` lookup for `CodeSuperClass` is a later host step after Engine registration.
