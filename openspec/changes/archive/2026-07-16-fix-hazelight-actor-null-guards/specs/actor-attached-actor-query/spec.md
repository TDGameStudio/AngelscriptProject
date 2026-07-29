## ADDED Requirements

### Requirement: Safe attached-actor queries by class

`GetAttachedActorsOfClass` SHALL return only attached actors matching the requested class when both the actor and class are valid, and SHALL return an empty array when either input is null.

#### Scenario: Valid actor and class filter attached actors

- **WHEN** a valid actor has attached children of more than one class and the script calls `GetAttachedActorsOfClass` with one valid class
- **THEN** the returned array contains only attached actors whose runtime type matches the requested class

#### Scenario: Null class returns an empty array

- **WHEN** a valid actor has attached children and the script passes an empty `TSubclassOf<AActor>` to `GetAttachedActorsOfClass`
- **THEN** the returned array is empty and no attached actor is returned as an unfiltered fallback

#### Scenario: Null actor returns an empty array

- **WHEN** the script calls `GetAttachedActorsOfClass` on a null `AActor` reference with a valid class
- **THEN** the returned array is empty and the call does not dereference the null actor
