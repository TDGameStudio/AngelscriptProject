## Purpose

Define the intentionally small UE-owned AngelScript language and host-library surface, separating script authoring features from runtime safety and native binding machinery.

## ADDED Requirements

### Requirement: Removed script facilities cannot be enabled

The language SHALL reject source module-sharing modifiers, funcdef declarations, anonymous functions, script exception handling, script coroutines, user-defined templates and virtual properties without a compatibility option that restores them.

#### Scenario: Author a removed language construct
- **WHEN** active source contains a removed construct in its grammatical position
  > Inputs: shared/external declarations; funcdef; function(...) or capture-list anonymous functions; try/catch/throw; coroutine/yield forms; user class/function template declarations or specialization; virtual-property blocks or property decorators.
- **THEN** compilation reports the removed feature at its authored source range and provides no publishable output for that failed compilation
- **AND** recovery preserves the ability to diagnose subsequent declarations

#### Scenario: Preserve unrelated identifiers and inactive source
- **WHEN** source uses an ordinary get/set method name, an unrelated host modifier, or removed-looking text inside an inactive conditional branch
- **THEN** the compiler applies ordinary identifier/host rules and conditional token selection rather than a global spelling blacklist
  > Boundaries: external_implicit_this, native shared locks and ordinary GetValue()/SetValue() calls are not source module-sharing or virtual-property facilities.

### Requirement: Type parameterization is supplied by the host

The language SHALL permit registered host parameterized types and established typed intrinsics without allowing scripts to declare or specialize templates.

#### Scenario: Use registered nested container types
- **GIVEN** the host supplies parameterized type declarations and their argument contracts
- **WHEN** source names a registered TArray<T>-style or TMap<K,V>-style type, including supported nesting
- **THEN** semantic analysis resolves its structured type arguments and validates the provider, arity and argument requirements
- **BUT** acceptance does not create arbitrary C++ template instances or unregistered host APIs

#### Scenario: Use an established typed intrinsic
- **WHEN** source uses an established Cast<T>-style intrinsic or explicitly registered typed host operation
- **THEN** the existing operation-specific type and execution rules remain authoritative
- **BUT** scripts cannot define general function templates through that call syntax

### Requirement: Runtime safety and host execution control survive language reduction

The SDK SHALL retain runtime fault reporting, unwind and resource cleanup, GC and host Context control independently of the absence of script exceptions and coroutines.

#### Scenario: Script execution encounters a runtime fault
- **WHEN** division by zero, a native callback failure or a stack limit terminates execution
- **THEN** the runtime reports the failure and performs required initialized-object and handle cleanup
- **AND** the Context follows its existing recovery and reprepare contract
- **BUT** scripts cannot catch or rethrow the failure through removed syntax

#### Scenario: Host suspends and resumes execution
- **WHEN** a registered host callback or debugger uses supported Context suspend/resume/abort operations
- **THEN** Context state, roots and cleanup retain their existing valid lifecycle behavior
- **BUT** this does not expose a script coroutine scheduler or yield library

### Requirement: Upstream add-ons are absent from the maintained distribution

The plugin SHALL not ship or register the removed upstream scriptarray, scriptdictionary, scriptmath and scriptstdstring add-on packages or retain their dedicated build and runtime consumption chain.

#### Scenario: Inspect host library exposure
- **WHEN** the maintained plugin and retained standalone manifests are inspected after cleanup
- **THEN** removed add-on packages, exclusive targets, registration entries and dependent library claims are absent
- **BUT** the remaining Standalone project is not thereby guaranteed to build against the reconstructed SDK

#### Scenario: Host supplies a UE library type
- **WHEN** UE registers its own array, map, string or math binding
- **THEN** that binding remains governed by its host contract rather than the removed upstream add-on package
