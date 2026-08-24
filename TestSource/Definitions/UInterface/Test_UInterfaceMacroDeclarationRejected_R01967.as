// Theme: Definitions.UInterface. NegativeDiagnostic: UINTERFACE() script declaration.
// C++: AngelscriptCoverageUInterfaceTests.cpp::UInterfaceMacroDeclarationRejected
// ExpectUInterfaceBoundaryRejected.
// sha256=50f65232a7eb9d2df49941079a56efcdf946ed6d14f6e192f669b596a979a695; lines 116-122.
// Expected diagnostic: "Expected identifier" / "Instead found '('".
// Isolate this failing program. DiagnosticOnly.

UINTERFACE()
interface ICoverageUnsupportedUInterface
{
	void Execute();
}
