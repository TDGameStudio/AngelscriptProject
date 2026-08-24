// Theme: Definitions.UProperty. Isolated compile-fail: TMap with a non-existent key type.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
// UPropTN_TMapBadKey; lines 590-596;
// sha256=1adabe8ebaa39a7281cc925053c4607668aed222c7b3b25b33f1fcce9bcd6425.
// Expected diagnostic: TMap with non-existent key type should fail.
// DiagnosticOnly. Isolated failing program.

class AUPropMapBadKeyActor : AActor
{
	UPROPERTY()
	TMap<FNonExistent, int> BadMap;
}
