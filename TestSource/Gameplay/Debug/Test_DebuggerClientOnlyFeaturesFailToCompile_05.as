// Theme: Gameplay.Debug. Isolated compile-fail: OpenReferenceViewer/ObjRefs are editor-only.
// C++: AngelscriptCoverageDebugTests.cpp::DebuggerClientOnlyFeaturesFailToCompile
// Expected diagnostic: OpenReferenceViewer (editor reference tools are not AS callable APIs).
// CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop OpenReferenceViewer.

void TryReferenceTools(UObject Object)
{
	OpenReferenceViewer(Object);
	ObjRefs(Object);
}
