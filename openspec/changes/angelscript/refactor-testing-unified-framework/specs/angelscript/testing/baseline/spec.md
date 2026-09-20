# Replacement baseline extension

## MODIFIED Requirements

### Requirement: Replacement tests use their final public identity

#### Scenario: Data rows extend the replacement identity explicitly
- **WHEN** a replacement data case exposes independently executable rows
- **THEN** each row registers at `<PublicCasePath>.Rows.<RowId>` with PublicCasePath beneath `Angelscript.UnitTest`

    > Example: `Angelscript.UnitTest.NativeEngine.Lexer.IntegerLiteral.Rows.HexBoundary`.
- **AND** existing ordinary CQTest public names remain unchanged
- **BUT** the common catalog does not register a second execution copy of an ordinary CQTest method

### Requirement: NativeEngine tests own an isolated CQTest foundation

#### Scenario: The data adapter reuses public assertions without legacy bootstrap
- **WHEN** a replacement typed data fixture uses CQTest assertions
- **THEN** its assertion object is bound to the current Automation item through the public CQTest assertion API
- **AND** each selected row owns its mutable fixture independently
- **BUT** this does not enable legacy force includes, engine pools or private CQTest registration machinery

#### Scenario: Source infrastructure operates with the runtime dormant
- **GIVEN** the default reconstruction compile gates
- **WHEN** source normalization, version materialization or data discovery runs
- **THEN** the infrastructure does not obtain an ambient legacy AS engine
- **AND** new registrations remain outside ignored Legacy subtrees
