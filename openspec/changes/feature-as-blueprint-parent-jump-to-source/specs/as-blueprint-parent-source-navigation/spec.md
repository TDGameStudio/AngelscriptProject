# Spec — as-blueprint-parent-source-navigation

## ADDED Requirements

### Requirement: Blueprint Editors Can Navigate To Angelscript Parent Source

When a Blueprint's parent class is an Angelscript script class, `UASClass` or `UASStruct`, the Blueprint editor SHALL provide a usable "open parent source" action. Triggering the action SHALL open the corresponding `.as` file in the configured external editor, VS Code, and navigate to the class definition line.

#### Scenario: User Opens AS Parent Source

- **WHEN** the user triggers the "open parent source" action in a Blueprint editor whose parent is an Angelscript class
- **THEN** the system resolves the `.as` source file path and line number for that parent class and opens the location in VS Code through `code --goto "<path>:<line>"`

#### Scenario: C++ Parent Classes Keep Existing Behavior

- **WHEN** the user triggers the "open parent source" action in a Blueprint editor whose parent is a native C++ class
- **THEN** the system keeps the engine's existing IDE navigation behavior and is not affected by this capability

#### Scenario: Unresolved Parent Source Does Not Mislead

- **WHEN** the Blueprint parent class is an Angelscript class but its source file path or line number cannot be resolved
- **THEN** the system does not open a location and visibly reports the failure through logging or notification rather than failing silently or opening the wrong location

### Requirement: Action Visibility Is Bound To Parent Class Type

The visibility and availability of the "Open Angelscript Parent Source" action SHALL depend on whether the current Blueprint parent class is an Angelscript class, avoiding redundant entries for non-script parent classes.

#### Scenario: AS Parent Shows Entry

- **WHEN** the current Blueprint's `ParentClass` is a `UASClass`/`UASStruct`
- **THEN** the "Open Angelscript Parent Source" action is visible and available

#### Scenario: Non-AS Parent Hides Entry

- **WHEN** the current Blueprint's `ParentClass` is not an Angelscript class
- **THEN** the entry provided by this capability is hidden, and C++ parent classes continue using the engine-provided button

### Requirement: Navigation Logic Is Testable Without Launching External Processes

Source navigation resolution SHALL provide a test seam so automation tests can assert "AS parent class -> correct path:line" without actually launching VS Code.

#### Scenario: Test Asserts Resolved Location

- **WHEN** a test triggers navigation for an AS parent class through the open-location override interface
- **THEN** the test can capture and assert the resolved source file path and line number without launching an external editor process
