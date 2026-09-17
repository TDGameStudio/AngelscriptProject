/**
 * @version v1
 * @summary An unknown UFUNCTION specifier is rejected. InvalidSpecifier is not a legal function specifier, so the declaration cannot be generated. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary An unknown UFUNCTION specifier is rejected. InvalidSpecifier is not a legal function specifier, so the declaration cannot be generated. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncInvalidActor : AActor
{
	/**
	 * Illegal UFUNCTION using an unknown specifier.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(InvalidSpecifier)
	 * @Return does not compile
	 */
	UFUNCTION(InvalidSpecifier)
	void Foo()
	{
	}
}
/** @end */
