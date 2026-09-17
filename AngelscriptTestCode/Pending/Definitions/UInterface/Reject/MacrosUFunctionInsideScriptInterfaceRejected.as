/**
 * @version v1
 * @summary A UFUNCTION inside a script interface is rejected in the Macros coverage block. The interface keyword itself is unsupported. Do not rewrite the interface as a class or drop the UFUNCTION.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION inside a script interface is rejected in the Macros coverage block. The interface keyword itself is unsupported. Do not rewrite the interface as a class or drop the UFUNCTION.
 * @topic Negative
 */
interface ICoverageMacrosInterfaceFunction
{
	/**
	 * A reflected method whose UFUNCTION annotation sits inside a script interface.
	 *
	 * @Covers UInterface.MacrosUFunctionInsideScriptInterfaceRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	UFUNCTION(BlueprintCallable)
	void Execute();
}
/** @end */
