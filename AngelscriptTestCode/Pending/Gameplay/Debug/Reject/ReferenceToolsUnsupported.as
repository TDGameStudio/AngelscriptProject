/**
 * @version v1
 * @summary OpenReferenceViewer and ObjRefs are editor reference tools rather than script callables, so this program is rejected. C++ compiles it as the module ASCoverageDebug_ReferenceToolsUnsupported and expects the diagnostic to.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary OpenReferenceViewer and ObjRefs are editor reference tools rather than script callables, so this program is rejected. C++ compiles it as the module ASCoverageDebug_ReferenceToolsUnsupported and expects the diagnostic to.
 * @topic Negative
 */
/**
 * The isolated failing program: the editor reference tools have no script-facing
 * signatures.
 *
 * @Kind CompileReject
 * @Covers Debug.ReferenceToolsUnsupported
 * @Inputs an object to inspect
 * @Return does not compile; the reference viewer and obj refs commands are editor tooling
 * @Param Object the object to inspect
 */
void TryReferenceTools(UObject Object)
{
	OpenReferenceViewer(Object);
	ObjRefs(Object);
}
/** @end */
