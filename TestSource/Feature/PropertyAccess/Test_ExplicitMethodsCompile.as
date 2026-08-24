// Theme: Feature.PropertyAccess. WorldStory explicit GetHealth/SetHealth methods.
// C++: AngelscriptSyntaxPropertyAccessorTests.cpp::ExplicitMethodsCompile AssertCompiles.
// Oracle: default GetHealth()==100; Test() writes 5.
// Extra: SetHealth(0); copy independence of two instances.
// FixtureIsolated.

class AActorPAExplicit : AActor
{
	private int _Health = 100;

	int GetHealth() const
	{
		return _Health;
	}

	void SetHealth(int Value)
	{
		_Health = Value;
	}

	void Test()
	{
		SetHealth(5);
		int Current = GetHealth();
	}
}

int Observe_PAExplicit_DefaultHealth(AActorPAExplicit Actor)
{
	if (Actor is null)
	{
		throw("Test_ExplicitMethodsCompile setup: required Actor is null");
	}
	return Actor.GetHealth();
}

int Observe_PAExplicit_TestWritesFive(AActorPAExplicit Actor)
{
	if (Actor is null)
	{
		throw("Test_ExplicitMethodsCompile setup: required Actor is null");
	}
	Actor.Test();
	return Actor.GetHealth();
}

int Observe_PAExplicit_ZeroBoundary(AActorPAExplicit Actor)
{
	if (Actor is null)
	{
		throw("Test_ExplicitMethodsCompile setup: required Actor is null");
	}
	Actor.SetHealth(0);
	return Actor.GetHealth();
}

bool Observe_PAExplicit_CopyIndependence(AActorPAExplicit First, AActorPAExplicit Second)
{
	if (First is null)
	{
		throw("Test_ExplicitMethodsCompile setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ExplicitMethodsCompile setup: required Second is null");
	}
	First.SetHealth(5);
	return First.GetHealth() == 5 && Second.GetHealth() == 100;
}
