// Theme: Feature.Access. WorldStory: a derived class may write a protected base field.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Positive block 5 AssertCompiles.
// Oracle: BaseVal default 10; UseBase sets it to 20 from ADerivedActor.
// Extra: empty/default 10; copy independence. Keep ADerivedActor.UseBase as in C++.
// FixtureIsolated.

class ABaseActor : AActor
{
	protected int BaseVal = 10;
}

class ADerivedActor : ABaseActor
{
	void UseBase()
	{
		BaseVal = 20;
	}
}

class ADerivedActorReader : ADerivedActor
{
	int ReadBase()
	{
		return BaseVal;
	}
}

int Observe_DerivedProtected_EmptyDefault(ADerivedActorReader Actor)
{
	if (Actor is null)
	{
		throw("Test_Access_Positive_05 setup: required Actor is null");
	}
	return Actor.ReadBase();
}

int Observe_DerivedProtected_UseBase(ADerivedActorReader Actor)
{
	if (Actor is null)
	{
		throw("Test_Access_Positive_05 setup: required Actor is null");
	}
	Actor.UseBase();
	return Actor.ReadBase();
}

bool Observe_DerivedProtected_CopyIndependence(ADerivedActorReader Original, ADerivedActorReader Copy)
{
	if (Original is null)
	{
		throw("Test_Access_Positive_05 setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_Access_Positive_05 setup: required Copy is null");
	}
	Copy.UseBase();
	return Original.ReadBase() == 10 && Copy.ReadBase() == 20;
}
