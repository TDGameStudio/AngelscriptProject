// Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
// in #if 0 (#as-engine-behavior: structural-validation-absent) so BlueprintReadOnly
// plus BlueprintReadWrite currently compiles.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative
// UPropSN_ConflictRORW; lines 206-212;
// sha256=2b097e9a2cd83ba797869c32ba8e25c4281fcd5da7e78f114944e108f95babfd.
// Oracle: X default is 0. Extra: 0 empty/default; 1 boundary write then restore.
// FixtureIsolated.

class AUPropConflictRWActor : AActor
{
	UPROPERTY(BlueprintReadOnly, BlueprintReadWrite)
	int X = 0;
}

bool Observe_ConflictRW_Nominal(AUPropConflictRWActor Actor)
{
	return Actor.X == 0;
}

bool Observe_ConflictRW_EmptyDefault(AUPropConflictRWActor Actor)
{
	return Actor.X == 0;
}

bool Observe_ConflictRW_BoundaryWrite(AUPropConflictRWActor Actor)
{
	int Saved = Actor.X;
	Actor.X = 1;
	bool bWrote = Actor.X == 1;
	Actor.X = Saved;
	return bWrote && Saved == 0;
}
