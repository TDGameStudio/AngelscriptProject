/**
 * @version v1
 * @summary A UFUNCTION parameter may not be named with a language keyword. class is reserved, so int class is not a legal parameter. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION parameter may not be named with a language keyword. class is reserved, so int class is not a legal parameter. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncPNKeywordActor : AActor
{
	/**
	 * Illegal UFUNCTION whose parameter name is the keyword class.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs int class
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(int class)
	{
	}
}
/** @end */
