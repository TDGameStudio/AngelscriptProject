/**
 * @version v1
 * @summary Three UFUNCTION parameters may not share a name. A is declared three times as int, so the signature is illegal. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Three UFUNCTION parameters may not share a name. A is declared three times as int, so the signature is illegal. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncPNTripleDupActor : AActor
{
	/**
	 * Illegal UFUNCTION that reuses the parameter name A three times.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs int A, int A, int A
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(int A, int A, int A)
	{
	}
}
/** @end */
