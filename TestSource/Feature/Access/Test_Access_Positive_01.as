// Theme: Feature.Access. WorldStory: public members are the default on a script actor.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Positive block 1 AssertCompiles.
// Oracle: PublicVar default 0; PublicFunc is callable without changing PublicVar.
// Extra: empty/default 0; copy independence of two instances.
// FixtureIsolated.

class AActorPubDefault : AActor
{
	int PublicVar = 0;

	void PublicFunc()
	{
	}
}

int Observe_PublicDefaultZero(AActorPubDefault Actor)
{
	if (Actor is null)
	{
		throw("Test_Access_Positive_01 setup: required Actor is null");
	}
	return Actor.PublicVar;
}

int Observe_PublicFuncLeavesDefault(AActorPubDefault Actor)
{
	if (Actor is null)
	{
		throw("Test_Access_Positive_01 setup: required Actor is null");
	}
	Actor.PublicFunc();
	return Actor.PublicVar;
}

bool Observe_PublicCopyIndependence(AActorPubDefault Original, AActorPubDefault Copy)
{
	if (Original is null)
	{
		throw("Test_Access_Positive_01 setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_Access_Positive_01 setup: required Copy is null");
	}
	Copy.PublicVar = 9;
	return Original.PublicVar == 0 && Copy.PublicVar == 9;
}
