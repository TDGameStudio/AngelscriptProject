/**
 * @version v1
 * @summary A UINTERFACE() script declaration is rejected by the UInterface coverage matrix. The empty specifier list is parsed as a call. This is the program for ICoverageUnsupportedUInterface. Do not rewrite it as a class.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UINTERFACE() script declaration is rejected by the UInterface coverage matrix. The empty specifier list is parsed as a call. This is the program for ICoverageUnsupportedUInterface. Do not rewrite it as a class.
 * @topic Negative
 */
UINTERFACE()
interface ICoverageUnsupportedUInterface
{
	/**
	 * A method declaration inside the unsupported UINTERFACE() script interface.
	 *
	 * @Covers UInterface.UInterfaceMacroDeclarationRejectedR01967
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void Execute();
}
/** @end */
