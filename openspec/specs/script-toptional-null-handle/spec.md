# script-toptional-null-handle Specification

## Purpose
TBD - created by archiving change fix-as-toptional-null-handle. Update Purpose after archive.
## Requirements
### Requirement: Optional accepts null object handles from script expressions
`TOptional<T>` SHALL accept a nullable object handle returned by an AngelScript function when `T` is a UObject-derived script class.

#### Scenario: Construct from returned null handle
- **WHEN** AngelScript constructs `TOptional<T>` from a function that returns `nullptr` for `T`
- **THEN** the operation completes without crashing and the optional is set with a null stored handle

#### Scenario: Set from returned null handle
- **WHEN** AngelScript calls `Set` on `TOptional<T>` with a function that returns `nullptr` for `T`
- **THEN** the operation completes without crashing and the optional is set with a null stored handle

#### Scenario: Assign from returned null handle
- **WHEN** AngelScript assigns a function-returned `nullptr` handle to `TOptional<T>`
- **THEN** the operation completes without crashing and the optional is set with a null stored handle

### Requirement: Optional accepts null object handles from native reference bindings
`TOptional<T>` SHALL accept a null UObject handle from a native binding that is declared to AngelScript as returning `T&`, when the native C++ implementation returns a nullable pointer and produces `nullptr`.

#### Scenario: Construct from native null reference
- **WHEN** AngelScript constructs `TOptional<UObject>` from a native function declared as `UObject&` that returns a null pointer
- **THEN** the operation completes without crashing and the optional is set with a null stored handle

#### Scenario: Set from native null reference
- **WHEN** AngelScript calls `Set` on `TOptional<UObject>` with a native function declared as `UObject&` that returns a null pointer
- **THEN** the operation completes without crashing and the optional is set with a null stored handle

#### Scenario: Assign from native null reference
- **WHEN** AngelScript assigns a native function declared as `UObject&` that returns a null pointer to `TOptional<UObject>`
- **THEN** the operation completes without crashing and the optional is set with a null stored handle

