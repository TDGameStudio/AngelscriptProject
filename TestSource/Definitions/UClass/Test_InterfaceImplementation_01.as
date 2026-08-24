// Theme: Definitions.UClass. NegativeDiagnostic: script-level interface declaration.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::InterfaceImplementation ExpectCompileBoundaryRejected.
// Expected diagnostic: "Virtual property syntax has been removed".
// Isolate this failing program. DiagnosticOnly.

interface IClassFeaturesScriptInterface
{
	void Interact();
}
