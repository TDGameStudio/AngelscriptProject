## ADDED Requirements

### Requirement: Owned Container Template Operations Released With Type Information

The runtime MUST own every heap-allocated container operations object stored for an AngelScript template instance through a dedicated non-default type-info user-data slot, and it MUST delete that object exactly once when that type information is destroyed. This contract covers `FArrayOperations`, `FMapOperations`, `FSetOperations`, and `FOptionalOperations`. Borrowed data in the default user-data slot MUST remain unaffected.

#### Scenario: Successful template operations are released

- **WHEN** valid TArray, TMap, TSet, and TOptional template instances allocate and cache their operation objects and the owning module or engine is destroyed
- **THEN** all four operation objects are deleted exactly once and release their retained type usages

#### Scenario: Failed validation operations are released

- **WHEN** a template callback allocates an operation object and later rejects the subtype or computed layout
- **THEN** the rejected operation object remains owned by its type information and is deleted exactly once during teardown

#### Scenario: Repeated validation reuses one owned object

- **WHEN** the same template instance is validated repeatedly before teardown
- **THEN** validation returns the cached operation object and does not allocate or register multiple owned objects

#### Scenario: Borrowed default user data is not deleted

- **WHEN** type information also carries a borrowed UClass, UStruct, UEnum, or other non-owned pointer in its default user-data slot
- **THEN** container cleanup reads and clears only its dedicated slot and never deletes or replaces the borrowed pointer
