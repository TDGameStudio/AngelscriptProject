// Theme: Feature.Default. WorldStory multiple default statements.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Positive AssertCompiles
// ASSyntaxDS_AttrMultiple. Oracle: X==10 Y==20. Extra: zeros; copy independence. Keep X/Y.
// FixtureIsolated.

class AAttrMultiActor : AActor
{
	UPROPERTY()
	int X = 0;

	UPROPERTY()
	int Y = 0;

	default X = 10;
	default Y = 20;
}

bool Observe_AttrMulti_EmptyDefaultIsNull()
{
	AAttrMultiActor Actor;
	return Actor == nullptr;
}

int Observe_AttrMulti_DefaultX(AAttrMultiActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0307 setup: required AAttrMultiActor is null");
	}
	return Actor.X;
}

int Observe_AttrMulti_DefaultY(AAttrMultiActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0307 setup: required AAttrMultiActor is null");
	}
	return Actor.Y;
}

bool Observe_AttrMulti_ZeroBoundary(AAttrMultiActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0307 setup: required AAttrMultiActor is null");
	}
	Actor.X = 0;
	Actor.Y = 0;
	return Actor.X == 0 && Actor.Y == 0;
}

bool Observe_AttrMulti_CopyIndependent(AAttrMultiActor First, AAttrMultiActor Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0307 setup: required AAttrMultiActor pair is null");
	}
	First.X = 0;
	First.Y = 0;
	return Second.X == 10 && Second.Y == 20;
}
