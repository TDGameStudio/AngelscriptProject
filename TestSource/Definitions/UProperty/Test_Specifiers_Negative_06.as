// Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
// in #if 0 (#as-engine-behavior: structural-validation-absent) so duplicate
// EditAnywhere currently compiles.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative
// UPropSN_DuplicateSpec; lines 251-257;
// sha256=03052e8f650869a5831d2bdefe99088c1e6d313a8f21fb04cc23494eb5881506.
// Oracle: X default is 0. Extra: 0 empty/default; 1 boundary write then restore.
// FixtureIsolated.

class AUPropDupSpecActor : AActor
{
	UPROPERTY(EditAnywhere, EditAnywhere)
	int X = 0;
}

bool Observe_DupSpec_Nominal(AUPropDupSpecActor Actor)
{
	return Actor.X == 0;
}

bool Observe_DupSpec_EmptyDefault(AUPropDupSpecActor Actor)
{
	return Actor.X == 0;
}

bool Observe_DupSpec_BoundaryWrite(AUPropDupSpecActor Actor)
{
	int Saved = Actor.X;
	Actor.X = 1;
	bool bWrote = Actor.X == 1;
	Actor.X = Saved;
	return bWrote && Saved == 0;
}
