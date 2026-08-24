// Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
// in #if 0 (#as-engine-behavior: structural-validation-absent) so a multi-variable
// UPROPERTY currently compiles.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative
// UPropTN_MultiDecl; lines 532-538;
// sha256=042c51edfd8e5c9a86e0ea53b460d5a6d39ba402c0a5506c39ffbb1584361a26.
// Oracle: X and Y default to 0. Extra: 0 empty/default; Y write is independent of X.
// FixtureIsolated.

class AUPropMultiDeclActor : AActor
{
	UPROPERTY()
	int X, Y;
}

bool Observe_MultiDecl_Nominal(AUPropMultiDeclActor Actor)
{
	return Actor.X == 0 && Actor.Y == 0;
}

bool Observe_MultiDecl_EmptyDefault(AUPropMultiDeclActor Actor)
{
	return Actor.X == 0 && Actor.Y == 0;
}

bool Observe_MultiDecl_CopyIndependence(AUPropMultiDeclActor Actor)
{
	int SavedX = Actor.X;
	Actor.Y = 7;
	bool bIndependent = Actor.X == SavedX && Actor.Y == 7;
	Actor.Y = 0;
	return bIndependent && SavedX == 0;
}
