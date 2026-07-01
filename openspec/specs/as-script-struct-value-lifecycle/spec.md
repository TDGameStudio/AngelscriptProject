# as-script-struct-value-lifecycle Specification

## Purpose
TBD - created by archiving change fix-script-struct-delegate-argument-crash. Update Purpose after archive.
## Requirements
### Requirement: AS script struct values initialize before script construction
The runtime SHALL construct the `asCScriptObject` shell for an AS-defined `USTRUCT` value before executing that struct's AS constructor when Unreal owns the destination storage.

#### Scenario: Delegate argument buffer constructs an AS struct parameter
- **WHEN** delegate/event argument marshalling constructs storage for an AS-defined `USTRUCT` parameter
- **THEN** the storage is a valid script object before any AS constructor or script-object method executes

#### Scenario: Unreal value lifecycle owns AS struct storage
- **WHEN** `UScriptStruct::InitializeStruct`, `CopyScriptStruct`, and `DestroyStruct` are used for an AS-defined `USTRUCT`
- **THEN** construction, copy, and destruction operate on initialized script-object storage without null object-type lookup or access violation

### Requirement: AS script struct delegate invocation is executable
The runtime SHALL allow delegates whose signatures include AS-defined `USTRUCT` parameters to be bound and executed from script.

#### Scenario: Delegate receives an AS struct value
- **WHEN** script binds a `UFUNCTION` handler to a delegate taking an AS-defined `USTRUCT` argument and executes the delegate
- **THEN** the handler receives the struct fields and returns the expected result without crashing

#### Scenario: Reloaded delegate receives an AS struct value
- **WHEN** a delegate taking an AS-defined `USTRUCT` argument is reloaded after the struct layout changes
- **THEN** the reloaded delegate can execute against the new struct layout without crashing

