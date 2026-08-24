// Theme: Feature.Default. Isolated compile-fail: default on a missing property.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative AssertFailsToCompile
// ASSyntaxDS_AttrNonExist. Expected diagnostic: "Default on non-existent property should fail".
// DiagnosticOnly. Do not declare NonExistentProp.

class AAttrNonExistActor : AActor
{
	default NonExistentProp = 42;
}
