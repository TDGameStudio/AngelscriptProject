/**
 * @version v1
 * @summary A UFUNCTION cannot return a reference. ReturnStoredValueRef returns int& to a property, which is unsupported. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION cannot return a reference. ReturnStoredValueRef returns int& to a property, which is unsupported. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionReferenceReturnActor : AActor
{
	UPROPERTY()
	int StoredValue = 7;

	/**
	 * Illegal UFUNCTION that returns a reference to a member.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Return
	 * @Inputs int& ReturnStoredValueRef()
	 * @Return does not compile
	 */
	UFUNCTION()
	int& ReturnStoredValueRef()
	{
		return StoredValue;
	}
}
/** @end */
