/**
 * @version v1
 * @summary BlueprintOverride requires a parent BlueprintEvent of the same name. The child declares MissingOverride, but the base class has no such event. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary BlueprintOverride requires a parent BlueprintEvent of the same name. The child declares MissingOverride, but the base class has no such event. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionMissingOverrideBaseActor : AActor
{
}

UCLASS()
class ACoverageUFunctionMissingOverrideChildActor : ACoverageUFunctionMissingOverrideBaseActor
{
	/**
	 * Illegal BlueprintOverride with no parent event to override.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintOverride) void MissingOverride()
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void MissingOverride()
	{
	}
}
/** @end */
