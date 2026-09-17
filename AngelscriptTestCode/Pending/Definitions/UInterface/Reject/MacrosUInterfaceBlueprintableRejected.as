/**
 * @version v1
 * @summary UINTERFACE(Blueprintable) on a script interface is rejected in the Macros coverage block. The specifier list is parsed as a call. Do not drop Blueprintable or rewrite the interface as a class.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UINTERFACE(Blueprintable) on a script interface is rejected in the Macros coverage block. The specifier list is parsed as a call. Do not drop Blueprintable or rewrite the interface as a class.
 * @topic Negative
 */
UINTERFACE(Blueprintable)
interface ICoverageMacrosBlueprintableInterface
{
	/**
	 * A method declaration inside the unsupported Blueprintable interface.
	 *
	 * @Covers UInterface.MacrosUInterfaceBlueprintableRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void Execute();
}
/** @end */
