/**
 * @version v1
 * @summary A BlueprintGetter must be BlueprintPure, so this program is rejected. C++ compiles the module Tests.Compiler.PropertyCallbackValidation.GetterNeedsBlueprintPure and expects "needs to be marked as BlueprintPure." Do not.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A BlueprintGetter must be BlueprintPure, so this program is rejected. C++ compiles the module Tests.Compiler.PropertyCallbackValidation.GetterNeedsBlueprintPure and expects "needs to be marked as BlueprintPure." Do not.
 * @topic Negative
 */
UCLASS()
class UPropertyCallbackCarrier : UObject
{
	UPROPERTY(BlueprintGetter=GetTrackedValue)
	int TrackedValue;

	/**
	 * The isolated failing program: GetTrackedValue is not BlueprintPure.
	 *
	 * @Kind CompileReject
	 * @Covers Meta.GetterNeedsBlueprintPure
	 * @Inputs none
	 * @Return does not compile; "needs to be marked as BlueprintPure."
	 */
	UFUNCTION()
	int GetTrackedValue() const
	{
		return TrackedValue;
	}
}
/** @end */
