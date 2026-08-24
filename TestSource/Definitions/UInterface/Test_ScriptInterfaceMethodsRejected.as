// Theme: Definitions.UInterface. NegativeDiagnostic: pure, default, and UFUNCTION interface methods.
// C++: AngelscriptCoverageUInterfaceTests.cpp::ScriptInterfaceMethodsRejected
// ExpectUInterfaceBoundaryRejected.
// sha256=ae02123de36aebbd3b7b4ea4dc8c2c1565fd4319a4ce364d7b68061db2c316f9; lines 214-226.
// Expected diagnostic: "Virtual property syntax has been removed".
// Isolate this failing program. DiagnosticOnly.

interface ICoverageUnsupportedMethodInterface
{
	void PureMethod();

	void DefaultMethod()
	{
	}

	UFUNCTION()
	void ReflectedMethod();
}
