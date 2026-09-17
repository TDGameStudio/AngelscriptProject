/**
 * @version v1
 * @summary A UPROPERTY default that names a missing enumerator is rejected. This file is the illegal program itself; do not replace MissingOption with a real enumerator, since the missing name is the point.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UPROPERTY default that names a missing enumerator is rejected. This file is the illegal program itself; do not replace MissingOption with a real enumerator, since the missing name is the point.
 * @topic Negative
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
/** @end */
