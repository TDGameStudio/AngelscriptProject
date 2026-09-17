/**
 * @version v1
 * @summary UFUNCTION names must be unique on a class. Overloading Duplicate with a second parameter list is illegal. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UFUNCTION names must be unique on a class. Overloading Duplicate with a second parameter list is illegal. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionDuplicateNameActor : AActor
{
	/**
	 * First Duplicate UFUNCTION with no parameters.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs void Duplicate()
	 * @Return does not compile together with the overload
	 */
	UFUNCTION()
	void Duplicate()
	{
	}

	/**
	 * Illegal second Duplicate UFUNCTION with an int parameter.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs void Duplicate(int Value)
	 * @Return does not compile
	 */
	UFUNCTION()
	void Duplicate(int Value)
	{
	}
}
/** @end */
