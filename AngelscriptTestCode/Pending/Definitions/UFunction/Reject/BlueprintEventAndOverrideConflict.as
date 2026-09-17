/**
 * @version v1
 * @summary A UFUNCTION cannot be both BlueprintEvent and BlueprintOverride. Those specifiers are exclusive. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION cannot be both BlueprintEvent and BlueprintOverride. Those specifiers are exclusive. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionConflictActor : AActor
{
	/**
	 * Illegal UFUNCTION mixing BlueprintEvent and BlueprintOverride.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintEvent, BlueprintOverride)
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintEvent, BlueprintOverride)
	void Conflict()
	{
	}
}
/** @end */
