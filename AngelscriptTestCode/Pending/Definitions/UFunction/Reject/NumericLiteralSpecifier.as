/**
 * @version v1
 * @summary A UFUNCTION specifier must be an identifier, not a numeric literal. 999 is not a legal specifier. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION specifier must be an identifier, not a numeric literal. 999 is not a legal specifier. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncNumSpecActor : AActor
{
	/**
	 * Illegal UFUNCTION whose specifier is a numeric literal.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(999)
	 * @Return does not compile
	 */
	UFUNCTION(999)
	void Foo()
	{
	}
}
/** @end */
