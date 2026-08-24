// Theme: Feature.Default. Isolated compile-fail: default statement inside a struct.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative AssertFailsToCompile
// ASSyntaxDS_AttrInStruct. Expected diagnostic: "Default statement in struct should fail".
// DiagnosticOnly. Do not move default onto a UCLASS.

struct FAttrStruct
{
	int X = 0;

	default X = 5;
}
