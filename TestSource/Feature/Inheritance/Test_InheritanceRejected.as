// Theme: Feature.Inheritance. Isolated compile-fail: USTRUCT may not use inheritance syntax.
// C++: AngelscriptPreprocessorStructTests.cpp::InheritanceRejected
// Expected diagnostic: "Error parsing script struct FDerivedStruct. Structs may not inherit from anything."
// DiagnosticOnly. Do not drop ": FBaseStruct"; that would make the program compile.

USTRUCT()
struct FDerivedStruct : FBaseStruct
{
	UPROPERTY()
	int Value;
}
