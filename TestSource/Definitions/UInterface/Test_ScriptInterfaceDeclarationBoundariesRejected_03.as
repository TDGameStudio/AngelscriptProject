// Theme: Definitions.UInterface. NegativeDiagnostic: UINTERFACE(Blueprintable).
// C++: AngelscriptCoverageMacrosTests.cpp::ScriptInterfaceDeclarationBoundariesRejected block 3.
// sha256=830be89a11a6a1f8aa0281a6fee292f37ed3a460a8b676c57afde6eb091fa528; lines 220-226.
// CompileAndExpectFailure. Expected diagnostic: "Expected identifier" / "Instead found '('".
// Isolate this failing program. DiagnosticOnly.

UINTERFACE(Blueprintable)
interface ICoverageMacrosBlueprintableInterface
{
	void Execute();
}
