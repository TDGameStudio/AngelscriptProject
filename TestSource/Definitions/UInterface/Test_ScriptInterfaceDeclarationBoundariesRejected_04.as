// Theme: Definitions.UInterface. NegativeDiagnostic: UFUNCTION inside a script interface.
// C++: AngelscriptCoverageMacrosTests.cpp::ScriptInterfaceDeclarationBoundariesRejected block 4.
// sha256=3d0494da889624b22af14ced343ab32611721f284b35bb6b4c7e803ca1e1ef06; lines 239-245.
// CompileAndExpectFailure. Expected diagnostic: "Virtual property syntax has been removed".
// Isolate this failing program. DiagnosticOnly.

interface ICoverageMacrosInterfaceFunction
{
	UFUNCTION(BlueprintCallable)
	void Execute();
}
