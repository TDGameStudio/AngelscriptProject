/**
 * @version v1
 * @summary A BlueprintSetter argument type must match the property, so this program is rejected. C++ compiles the module Tests.Compiler.PropertyCallbackValidation.SetterTypeMismatch and expects the setter to take float while the.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A BlueprintSetter argument type must match the property, so this program is rejected. C++ compiles the module Tests.Compiler.PropertyCallbackValidation.SetterTypeMismatch and expects the setter to take float while the.
 * @topic Negative
 */
UCLASS()
class UPropertyCallbackCarrier : UObject
{
	UPROPERTY(BlueprintSetter=SetTrackedValue)
	int TrackedValue;

	/**
	 * The isolated failing program: SetTrackedValue takes float for an int property.
	 *
	 * @Kind CompileReject
	 * @Covers Meta.SetterTypeMismatch
	 * @Inputs a float Value
	 * @Return does not compile; setter takes 'float' but the written value is 'int'
	 * @Param Value the mismatched setter argument
	 */
	UFUNCTION()
	void SetTrackedValue(float Value)
	{
	}
}
/** @end */
