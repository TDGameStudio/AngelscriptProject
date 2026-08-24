// Theme: Feature.Default. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile in #if 0
// (#as-engine-behavior: structural-validation-absent) so duplicate default assignments compile.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative ASSyntaxDS_AttrDuplicate.
// Oracle: last default wins, X==10. Extra: empty handle is null; copy independence. Keep X.
// FixtureIsolated.

class AAttrDupActor : AActor
{
	UPROPERTY()
	int X = 0;

	default X = 5;
	default X = 10;
}

bool Observe_AttrDup_EmptyDefaultIsNull()
{
	AAttrDupActor Actor;
	return Actor == nullptr;
}

int Observe_AttrDup_LastDefaultWins(AAttrDupActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0314 setup: required AAttrDupActor is null");
	}
	return Actor.X;
}

bool Observe_AttrDup_CopyIndependent(AAttrDupActor First, AAttrDupActor Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0314 setup: required AAttrDupActor pair is null");
	}
	First.X = 0;
	return Second.X == 10;
}
