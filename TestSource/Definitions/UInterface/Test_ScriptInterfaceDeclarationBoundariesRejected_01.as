// Theme: Definitions.UInterface. NegativeDiagnostic: script interface keyword.
// C++: AngelscriptCoverageMacrosTests.cpp::ScriptInterfaceDeclarationBoundariesRejected block 1.
// sha256=0370b876af2cdcc0204c20c6cb1f21e4b05b3cdb8e4f2f333cd1d2b9e76bf642; lines 184-189.
// CompileAndExpectFailure. Expected diagnostic: "Virtual property syntax has been removed".
// Isolate this failing program. DiagnosticOnly.

interface ICoverageMacrosScriptInterface
{
	void Execute();
}
