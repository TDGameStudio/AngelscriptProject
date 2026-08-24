// Theme: Definitions.UProperty. Isolated compile-fail: TSubclassOf of a non-UObject type.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
// UPropTN_SubclassNonObj; lines 520-526;
// sha256=eb7e32475987057a0fd93a770775d3f4d4bd2bea92e1dd2f61b95f3ac39d522f.
// Expected diagnostic: TSubclassOf with non-UObject type should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropSubNonObjActor : AActor
{
	UPROPERTY()
	TSubclassOf<int> BadClass;
}
