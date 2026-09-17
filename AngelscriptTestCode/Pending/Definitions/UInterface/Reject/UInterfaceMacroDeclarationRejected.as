/**
 * @version v1
 * @summary A UINTERFACE() script declaration is rejected. The empty specifier list is parsed as a call, so compilation stops on the opening parenthesis. This is the Macros coverage program for ICoverageMacrosUnsupportedUInterface.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UINTERFACE() script declaration is rejected. The empty specifier list is parsed as a call, so compilation stops on the opening parenthesis. This is the Macros coverage program for ICoverageMacrosUnsupportedUInterface.
 * @topic Negative
 */
UINTERFACE()
interface ICoverageMacrosUnsupportedUInterface
{
	/**
	 * A method declaration inside the unsupported UINTERFACE() script interface.
	 *
	 * @Covers UInterface.UInterfaceMacroDeclarationRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void Execute();
}
/** @end */
