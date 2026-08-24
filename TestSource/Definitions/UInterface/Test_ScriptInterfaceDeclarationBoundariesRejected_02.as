// Theme: Definitions.UInterface. NegativeDiagnostic: UINTERFACE(BlueprintType).
// C++: AngelscriptCoverageMacrosTests.cpp::ScriptInterfaceDeclarationBoundariesRejected block 2.
// sha256=a3b5c4be8e979b18e3ad5c4fccf076dbb0db49a5a1eda5b2b0a59fcb33886a97; lines 201-207.
// CompileAndExpectFailure. Expected diagnostic: "Expected identifier" / "Instead found '('".
// Isolate this failing program. DiagnosticOnly.

UINTERFACE(BlueprintType)
interface ICoverageMacrosBlueprintTypeInterface
{
	void Execute();
}
