// Theme: Feature.Default. Isolated compile-fail: default targeting a method.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative AssertFailsToCompile
// ASSyntaxDS_AttrOnMethod. Expected diagnostic: "Default on method should fail".
// DiagnosticOnly. Do not replace Foo with a property.

class AAttrOnMethodActor : AActor
{
	UFUNCTION()
	void Foo()
	{
	}

	default Foo = 0;
}
