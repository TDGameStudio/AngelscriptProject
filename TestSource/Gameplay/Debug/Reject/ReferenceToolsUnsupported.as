/**
 * OpenReferenceViewer and ObjRefs are editor reference tools rather than script
 * callables, so this program is rejected. C++ compiles it as the module
 * ASCoverageDebug_ReferenceToolsUnsupported and expects the diagnostic to name
 * OpenReferenceViewer.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.ReferenceToolsUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.ReferenceToolsUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: OpenReferenceViewer/ObjRefs are editor-only.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::DebuggerClientOnlyFeaturesFailToCompile
 * @Provenance Expected diagnostic: OpenReferenceViewer (editor reference tools are not AS callable APIs).
 * @Provenance CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop OpenReferenceViewer.
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
