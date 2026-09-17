/**
 * @version v1
 * @summary UINTERFACE(BlueprintType) on a script interface is rejected in the Macros coverage block. The specifier list is parsed as a call. Do not drop BlueprintType or rewrite the interface as a class.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UINTERFACE(BlueprintType) on a script interface is rejected in the Macros coverage block. The specifier list is parsed as a call. Do not drop BlueprintType or rewrite the interface as a class.
 * @topic Negative
 */
UINTERFACE(BlueprintType)
interface ICoverageMacrosBlueprintTypeInterface
{
	/**
	 * A method declaration inside the unsupported BlueprintType interface.
	 *
	 * @Covers UInterface.MacrosUInterfaceBlueprintTypeRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void Execute();
}
/** @end */
