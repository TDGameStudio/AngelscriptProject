/**
 * @version v1
 * @summary Tokens may not appear between UFUNCTION() and the method it annotates. The garbage identifier is illegal. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Tokens may not appear between UFUNCTION() and the method it annotates. The garbage identifier is illegal. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncGarbageActor : AActor
{
	/**
	 * Illegal UFUNCTION with a garbage token between the annotation and the method.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION() garbage void Foo()
	 * @Return does not compile
	 */
	UFUNCTION() garbage void Foo() { }
}
/** @end */
