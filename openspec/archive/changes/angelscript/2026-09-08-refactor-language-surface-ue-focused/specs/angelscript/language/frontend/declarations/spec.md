## ADDED Requirements

### Requirement: Declaration membership is supplied by the compilation request

The declaration frontend SHALL obtain source membership and external provider definitions from the compilation request and SHALL reject source shared/external module-sharing policy and funcdef declarations.

#### Scenario: Resolve declarations across supplied files
- **GIVEN** two source files in one Session and a frozen externally supplied definition image
- **WHEN** declarations reference names in the other file or supplied provider
- **THEN** the normal declaration barrier and semantic lookup resolve them without shared/external modifiers or source funcdef registration
- **BUT** this contract does not discover files or schedule missing providers automatically

#### Scenario: Reject declaration-level compatibility syntax
- **WHEN** active source authors shared/external declaration modifiers, funcdef, a virtual property or a property decorator
- **THEN** the frontend reports an explicit removed-feature diagnostic and withholds publishable resolved declarations for the failed compilation

### Requirement: Ordinary methods do not synthesize virtual properties

The frontend SHALL treat get/set-shaped function names as ordinary functions and SHALL not infer an implicit property from them.

#### Scenario: Call explicit accessor-shaped methods
- **WHEN** a class declares and calls GetValue(), SetValue(int), get_Value() or set_Value(int) as ordinary methods
- **THEN** normal function resolution applies
- **BUT** those functions alone do not create a field named Value or permit property assignment syntax
