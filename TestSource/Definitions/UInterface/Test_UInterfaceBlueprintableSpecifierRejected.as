// Theme: Definitions.UInterface. NegativeDiagnostic: UINTERFACE(Blueprintable).
// C++: AngelscriptCoverageUInterfaceTests.cpp::UInterfaceBlueprintableSpecifierRejected
// ExpectUInterfaceBoundaryRejected.
// sha256=ab6cbe6409ffdd02bf0a3b462071ee515ea02346298172156c5c84084a5f4217; lines 167-173.
// Expected diagnostic: "Expected identifier" / "Instead found '('".
// Isolate this failing program. DiagnosticOnly.

UINTERFACE(Blueprintable)
interface ICoverageUnsupportedBlueprintableInterface
{
	void Execute();
}
