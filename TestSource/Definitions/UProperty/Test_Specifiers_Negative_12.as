// Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
// in #if 0 (#as-engine-behavior: structural-validation-absent) so an unknown Meta key
// currently compiles.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative
// UPropSN_BadMetaKey; lines 321-327;
// sha256=95ebe6befde4a08cb7672c9a04b5682f2fa4a1410a48c94837df48e9fcee09c2.
// Oracle: X default is 0. Extra: 0 empty/default; 1 boundary write then restore.
// FixtureIsolated.

class AUPropBadMetaActor : AActor
{
	UPROPERTY(Meta = (NonExistentMetaKey = true))
	int X = 0;
}

bool Observe_BadMeta_Nominal(AUPropBadMetaActor Actor)
{
	return Actor.X == 0;
}

bool Observe_BadMeta_EmptyDefault(AUPropBadMetaActor Actor)
{
	return Actor.X == 0;
}

bool Observe_BadMeta_BoundaryWrite(AUPropBadMetaActor Actor)
{
	int Saved = Actor.X;
	Actor.X = 1;
	bool bWrote = Actor.X == 1;
	Actor.X = Saved;
	return bWrote && Saved == 0;
}
