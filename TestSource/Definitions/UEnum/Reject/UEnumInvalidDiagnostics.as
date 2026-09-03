/**
 * A UPROPERTY default that names a missing enumerator is rejected. This file is
 * the illegal program itself; do not replace MissingOption with a real enumerator,
 * since the missing name is the point.
 *
 * @Theme Definitions.UEnum
 * @Subject UEnum.UEnumInvalidDiagnostics
 * @Harness CompileReject
 * @Tag Definitions.UEnum.UEnumInvalidDiagnostics
 * @Kind CompileReject
 * @Covers UEnum.UEnumInvalidDiagnostics
 * @Inputs EInvalidAssignmentEnum::MissingOption as a property default
 * @Return does not compile; diagnostic "MissingOption"
 * @Provenance Theme: Definitions.UEnum. Isolated compile-fail: missing enumerator on UPROPERTY default.
 * @Provenance C++: AngelscriptCoverageUEnumTests.cpp::UEnumInvalidDiagnostics
 * @Provenance Expected diagnostic: "MissingOption"
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

UENUM()
enum EInvalidAssignmentEnum
{
	OptionA,
	OptionB
}

/**
 * An actor whose property default names an enumerator that does not exist.
 *
 * @Covers UEnum.UEnumInvalidDiagnostics
 * @Inputs none
 * @Return does not compile
 */
UCLASS()
class ACoverageUEnumInvalidDiagnosticsActor : AActor
{
	UPROPERTY()
	EInvalidAssignmentEnum Value = EInvalidAssignmentEnum::MissingOption;
}
