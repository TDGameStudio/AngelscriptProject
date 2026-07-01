## ADDED Requirements

### Requirement: Unit test registration sources honor compile macro

Every AngelscriptTest C++ source file that registers CQTest or Unreal automation tests SHALL be gated by `WITH_ANGELSCRIPT_UNITTESTS`.

#### Scenario: CQTest registration file is compiled with unit tests disabled

- **GIVEN** an `AngelscriptTest` `.cpp` file contains `TEST_CLASS_WITH_FLAGS` or `TEST_METHOD`
- **WHEN** `WITH_ANGELSCRIPT_UNITTESTS=0`
- **THEN** that file SHALL NOT register Angelscript automation tests

#### Scenario: CQTest registration file is compiled with unit tests enabled

- **GIVEN** an `AngelscriptTest` `.cpp` file contains `TEST_CLASS_WITH_FLAGS` or `TEST_METHOD`
- **WHEN** `WITH_ANGELSCRIPT_UNITTESTS=1`
- **THEN** the same automation tests SHALL remain registered

#### Scenario: Unreal automation registration file is compiled

- **GIVEN** an `AngelscriptTest` `.cpp` file contains `IMPLEMENT_SIMPLE_AUTOMATION_TEST`, `IMPLEMENT_COMPLEX_AUTOMATION_TEST`, `DEFINE_SPEC`, or `BEGIN_DEFINE_SPEC`
- **WHEN** the file is refactored
- **THEN** the registration code SHALL be gated by `WITH_ANGELSCRIPT_UNITTESTS`

### Requirement: Non-registration support files are classified

AngelscriptTest `.cpp` files without CQTest or Unreal automation registration macros SHALL be manually classified rather than mechanically wrapped without inspection.

#### Scenario: Support file has no registration macro

- **GIVEN** an `AngelscriptTest` `.cpp` file has no test registration macro
- **WHEN** the refactor is applied
- **THEN** the file SHALL either be documented as exempt or gated only if inspection proves it contains unit-test-only implementation

#### Scenario: Exempt support file remains compiled

- **GIVEN** a support `.cpp` file is required for module startup, helper types, generated AOT fixtures, or adjacent gated tests
- **WHEN** `WITH_ANGELSCRIPT_UNITTESTS=0`
- **THEN** the support file MAY remain compiled as long as it does not register automation tests

### Requirement: Macro naming remains consistent

The refactor SHALL use only `WITH_ANGELSCRIPT_UNITTESTS` for this unit-test gate.

#### Scenario: Old macro names are searched

- **WHEN** the implementation is scanned
- **THEN** new gate sites SHALL NOT use `WITH_ANGELSCRIPT_TESTS`
- **AND** config-driven behavior SHALL continue to use `bCompileAngelscriptUnitTests`

### Requirement: Dependent extension test modules inherit the gate policy

Optional Angelscript extension test modules that include `AngelscriptTest` helper headers or consume `AngelscriptTest` helper types SHALL receive and honor the same `WITH_ANGELSCRIPT_UNITTESTS` compile definition.

#### Scenario: Extension test module compiles with unit tests disabled

- **GIVEN** an extension test module depends on `AngelscriptTest` and includes shared helper headers
- **WHEN** `WITH_ANGELSCRIPT_UNITTESTS=0`
- **THEN** the module SHALL compile without `C4668` macro-undefined diagnostics
- **AND** its Angelscript helper-backed test registrations SHALL be omitted

#### Scenario: Extension test module compiles with unit tests enabled

- **GIVEN** an extension test module depends on `AngelscriptTest`
- **WHEN** `WITH_ANGELSCRIPT_UNITTESTS=1`
- **THEN** its existing Angelscript automation tests SHALL remain compiled and registered

### Requirement: Unit test documentation describes the gate

The unit-test rules documentation SHALL describe the `WITH_ANGELSCRIPT_UNITTESTS` convention for Angelscript C++ unit-test files.

#### Scenario: Contributor reads UnitTest rules

- **WHEN** a contributor reads `Documents/UnitTest/UnitTest.md`
- **THEN** the document explains that new or refactored `AngelscriptTest` unit-test registration `.cpp` files must be gated by `WITH_ANGELSCRIPT_UNITTESTS`
- **AND** it shows the preferred whole-file gate shape after includes
- **AND** it states that helper/generated/support files require explicit classification rather than blind wrapping

#### Scenario: Old macro spelling

- **WHEN** `Documents/UnitTest/UnitTest.md` is updated
- **THEN** it SHALL NOT recommend `WITH_ANGELSCRIPT_TESTS`

### Requirement: Build behavior remains valid in both modes

The AngelscriptTest module SHALL compile when unit tests are enabled and when unit tests are disabled.

#### Scenario: Unit tests disabled

- **GIVEN** `bCompileAngelscriptUnitTests=false`
- **WHEN** the project editor target is built
- **THEN** the build succeeds without registering Angelscript unit tests

#### Scenario: Unit tests enabled

- **GIVEN** `bCompileAngelscriptUnitTests=true`
- **WHEN** Angelscript automation tests are run
- **THEN** representative Angelscript unit test prefixes remain discoverable and executable
