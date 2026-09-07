## ADDED Requirements

### Requirement: Removed anonymous-function products cannot enter semantic artifacts

The maintained AST and definition projection SHALL expose no constructible Lambda-only node or origin product and SHALL reject incompatible persisted anonymous-function representations.

#### Scenario: Decode a retired anonymous-function representation
- **WHEN** a consumer receives a prior incompatible AST format or a reserved retired Lambda kind
- **THEN** decoding or verification rejects it before publishing a valid semantic graph
- **BUT** a retired numeric kind is not reinterpreted as a different supported node

#### Scenario: Preserve ordinary typed AST operations
- **WHEN** a supported named-function AST is projected, serialized, decoded and verified
- **THEN** declaration identity, type information, source ranges and lifetime facts retain their supported behavior
