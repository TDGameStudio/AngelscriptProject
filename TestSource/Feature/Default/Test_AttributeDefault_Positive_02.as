// Theme: Feature.Default. WorldStory default statement overrides an int initializer.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Positive AssertCompiles
// ASSyntaxDS_AttrInt. Oracle: Health==100 after default Health = 100.
// Extra: empty handle is null; Health 0 boundary; copy independence. Keep Health.
// FixtureIsolated.

class AAttrIntActor : AActor
{
	UPROPERTY()
	int Health = 0;

	default Health = 100;
}

bool Observe_AttrInt_EmptyDefaultIsNull()
{
	AAttrIntActor Actor;
	return Actor == nullptr;
}

int Observe_AttrInt_DefaultHundred(AAttrIntActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0304 setup: required AAttrIntActor is null");
	}
	return Actor.Health;
}

int Observe_AttrInt_ZeroBoundary(AAttrIntActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0304 setup: required AAttrIntActor is null");
	}
	Actor.Health = 0;
	return Actor.Health;
}

bool Observe_AttrInt_CopyIndependent(AAttrIntActor First, AAttrIntActor Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0304 setup: required AAttrIntActor pair is null");
	}
	First.Health = 0;
	return Second.Health == 100;
}
