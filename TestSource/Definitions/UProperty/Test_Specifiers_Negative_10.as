// Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
// in #if 0 (#as-engine-behavior: structural-validation-absent) so lowercase
// editanywhere currently compiles.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative
// UPropSN_CaseSensitive; lines 298-304;
// sha256=04ed128f739c3e8778bbdc2856630299e3074344e028c68a02332b82c3731617.
// Oracle: X default is 0. Extra: 0 empty/default; 1 boundary write then restore.
// FixtureIsolated.

class AUPropCaseActor : AActor
{
	UPROPERTY(editanywhere)
	int X = 0;
}

bool Observe_Case_Nominal(AUPropCaseActor Actor)
{
	return Actor.X == 0;
}

bool Observe_Case_EmptyDefault(AUPropCaseActor Actor)
{
	return Actor.X == 0;
}

bool Observe_Case_BoundaryWrite(AUPropCaseActor Actor)
{
	int Saved = Actor.X;
	Actor.X = 1;
	bool bWrote = Actor.X == 1;
	Actor.X = Saved;
	return bWrote && Saved == 0;
}
