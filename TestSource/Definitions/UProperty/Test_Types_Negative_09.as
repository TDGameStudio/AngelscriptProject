// Theme: Definitions.UProperty. Isolated compile-fail: nested TArray of a bogus inner type.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
// UPropTN_NestedBad; lines 555-561;
// sha256=a9382639ead914f3cc4d4b4a865c39856a4a349ea7863863cf691fadba30bfa9.
// Expected diagnostic: Nested TArray with bad inner type should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropNestedBadActor : AActor
{
	UPROPERTY()
	TArray<TArray<FBogus>> Nested;
}
