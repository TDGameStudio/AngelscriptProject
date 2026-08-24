// Theme: Definitions.UProperty. WorldStory: UPROPERTY TArray<int>.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Positive AssertCompiles
// UPropTP_TArray; lines 431-437;
// sha256=cb637f15f109ceafa6567de78ee9b61263a6dc8aaac539b61b9b3dba5cbf1a68.
// Oracle: Scores default Num is 0 on the spawned actor.
// Extra: empty array is the default; Add(7) then a copied TArray is independent.
// FixtureIsolated.

class AUPropArrActor : AActor
{
	UPROPERTY()
	TArray<int> Scores;
}

bool Observe_Scores_Nominal(AUPropArrActor Actor)
{
	return Actor.Scores.Num() == 0;
}

bool Observe_Scores_EmptyDefault(AUPropArrActor Actor)
{
	return Actor.Scores.Num() == 0;
}

bool Observe_Scores_CopyIndependence(AUPropArrActor Actor)
{
	Actor.Scores.Add(7);
	TArray<int> Copy = Actor.Scores;
	Copy[0] = 9;
	bool bIndependent = Actor.Scores[0] == 7 && Copy[0] == 9;
	Actor.Scores.Empty();
	return bIndependent;
}
