/**
 * @version v1
 * @summary Two UFUNCTION parameters may not share a name. X is declared first as int and again as float, so the signature is illegal. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Two UFUNCTION parameters may not share a name. X is declared first as int and again as float, so the signature is illegal. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncPNDupNameActor : AActor
{
	/**
	 * Illegal UFUNCTION that reuses the parameter name X.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs int X, float X
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(int X, float X)
	{
	}
}
/** @end */
