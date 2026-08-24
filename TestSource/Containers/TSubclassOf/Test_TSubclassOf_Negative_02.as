// Theme: Containers.TSubclassOf. Isolated compile-fail: TSubclassOf of a missing type.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSubclassOf_Negative AssertFailsToCompile
// ASSyntaxSPSubclassBadType. Expected diagnostic: "TSubclassOf of non-existent type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TSubclassOf<NonExistentClass> Class;
}
