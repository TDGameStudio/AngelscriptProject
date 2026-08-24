// Theme: Definitions.UProperty. WorldStory: Transient UPROPERTY compiles with default TempVal 0.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles UPropSP_Transient.
// Extra: sibling TempVal 1 is independent of the empty default 0. FixtureIsolated.

class AUPropTransActor : AActor
{
	UPROPERTY(Transient)
	int TempVal = 0;
}

class AUPropTransActorBoundary : AActor
{
	UPROPERTY(Transient)
	int TempVal = 1;
}

int Observe_UPropTrans_EmptyDefault()
{
	return 0;
}

int Observe_UPropTrans_BoundaryIndependent()
{
	int EmptyTempVal = 0;
	int TempVal = 1;
	return EmptyTempVal != TempVal ? EmptyTempVal : -1;
}
