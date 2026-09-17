/**
 * @version v1
 * @summary A script-level interface declaration is rejected. This fork does not support AngelScript interface types.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A script-level interface declaration is rejected. This fork does not support AngelScript interface types.
 * @topic Negative
 */
interface IClassFeaturesScriptInterface
{
	/**
	 * Script interface method that must not compile in this fork.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.Interface
	 * @Inputs Interact declared on a script interface
	 * @Return does not compile
	 */
	void Interact();
}
/** @end */
