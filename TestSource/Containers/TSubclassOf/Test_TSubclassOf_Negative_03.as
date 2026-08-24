// Theme: Containers.TSubclassOf. Isolated compile-fail: TSubclassOf of a primitive.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSubclassOf_Negative AssertFailsToCompile
// ASSyntaxSPSubclassPrimitive. Expected diagnostic: "TSubclassOf of primitive should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TSubclassOf<int> Class;
}
