// Theme: Definitions.UInterface. NegativeDiagnostic: UINTERFACE() script declaration.
// C++: AngelscriptCoverageMacrosTests.cpp::UInterfaceMacroDeclarationRejected CompileAndExpectFailure.
// sha256=11f2b14c7d12b81c4409105334bfc2365c8e34347d62ee0cb29e796d857e13c2; lines 126-132.
// Expected diagnostic: "Expected identifier" / "Instead found '('".
// Isolate this failing program. DiagnosticOnly.

UINTERFACE()
interface ICoverageMacrosUnsupportedUInterface
{
	void Execute();
}
