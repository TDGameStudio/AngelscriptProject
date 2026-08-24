// Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
// in #if 0 (#as-engine-behavior: structural-validation-absent) so a const UPROPERTY
// currently compiles.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative
// UPropTN_ConstProp; lines 578-584;
// sha256=805d1636cce9a114c1392ac73cdb4658ff3ef11f0fc3cb353311a640af4006df.
// Oracle: ConstVal default is 5. Extra: 5 is the only initializer; no mutation API.
// FixtureIsolated.

class AUPropConstPropActor : AActor
{
	UPROPERTY()
	const int ConstVal = 5;
}

bool Observe_ConstVal_Nominal(AUPropConstPropActor Actor)
{
	return Actor.ConstVal == 5;
}

bool Observe_ConstVal_NotZeroBoundary(AUPropConstPropActor Actor)
{
	return Actor.ConstVal != 0;
}

int Observe_ConstVal_CopySnapshot(AUPropConstPropActor Actor)
{
	int Copy = Actor.ConstVal;
	Copy = 0;
	return Actor.ConstVal;
}
