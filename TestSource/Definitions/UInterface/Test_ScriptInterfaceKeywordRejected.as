// Theme: Definitions.UInterface. NegativeDiagnostic: script interface keyword.
// C++: AngelscriptCoverageUInterfaceTests.cpp::ScriptInterfaceKeywordRejected
// ExpectUInterfaceBoundaryRejected.
// sha256=bd948e9f6f405d56d275463d9cbf6e55c3594f427cd163d995c367d7be7b8683; lines 92-97.
// Expected diagnostic: "Virtual property syntax has been removed".
// Isolate this failing program. DiagnosticOnly.

interface ICoverageUnsupportedInterface
{
	void Execute();
}
