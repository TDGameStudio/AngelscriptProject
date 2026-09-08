## ADDED Requirements

### Requirement: Function bodies exclude anonymous functions and script control services

The body frontend SHALL reject every anonymous-function expression and script exception/coroutine form while retaining ordinary named calls, control flow and semantic cleanup obligations.

#### Scenario: Reject immediate and escaping anonymous functions
- **WHEN** source authors a noncapturing immediate function expression, stores an anonymous function, or authors an explicit capture-list function
- **THEN** analysis reports AnonymousFunction as a removed capability and produces no valid Lambda semantic product
  > Boundaries: Changing capture shape, omitting captures or immediately calling the expression cannot bypass rejection.

#### Scenario: Preserve named calls and runtime unwind facts
- **WHEN** supported source calls a named function or member and includes scoped objects with ordinary return/break/continue paths
- **THEN** the typed call and lifetime facts remain available to the existing emitter and VM
- **BUT** source cannot add try/catch/throw, coroutine declarations or yield behavior
