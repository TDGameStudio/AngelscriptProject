// Theme: Language.ControlFlow.Jump. Isolated compile-fail from Return_Mixed.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Return_Mixed
// sha256=a560b3f756658b96a351ca1862a7ceda4c3a9d6c28f2a3d2e949d69b2ea64e80; lines 560-562.
// Oracle: compile fails — return value in a void function.
// CSV SourceShape is Positive; C++ AssertFailsToCompile is the TrailingOracle.
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	return 5;
}
