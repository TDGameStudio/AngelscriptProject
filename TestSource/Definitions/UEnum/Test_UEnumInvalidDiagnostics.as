// Theme: Definitions.UEnum. Isolated compile-fail: missing enumerator on UPROPERTY default.
// C++: AngelscriptCoverageUEnumTests.cpp::UEnumInvalidDiagnostics
// Expected diagnostic: "MissingOption"
// Isolate the failing program. DiagnosticOnly.

UENUM()
enum EInvalidAssignmentEnum
{
	OptionA,
	OptionB
}

UCLASS()
class ACoverageUEnumInvalidDiagnosticsActor : AActor
{
	UPROPERTY()
	EInvalidAssignmentEnum Value = EInvalidAssignmentEnum::MissingOption;
}
