// Theme: Definitions.UProperty. Isolated compile-fail: function type as a UPROPERTY.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
// UPropTN_FuncType; lines 544-550;
// sha256=7fb453874d6b7bcef26fcd6d353a087375aca6e058214f8c8f8fcc1066e9610a.
// Expected diagnostic: Function type as UPROPERTY should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropFuncTypeActor : AActor
{
	UPROPERTY()
	void() Callback;
}
