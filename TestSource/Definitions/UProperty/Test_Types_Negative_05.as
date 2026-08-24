// Theme: Definitions.UProperty. Isolated compile-fail: TArray of a non-existent element type.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
// UPropTN_TArrayBadElem; lines 509-515;
// sha256=f7b758a1efee8bd4cea5c5c933cc930f4d52b7fd20898ad3145cb8ce31f2f45c.
// Expected diagnostic: TArray with non-existent element type should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropArrBadActor : AActor
{
	UPROPERTY()
	TArray<FNonExistent> Items;
}
