// Theme: Feature.Mixin. WorldStory: mixin applied to an actor subclass.
// C++: AngelscriptSyntaxMixinTests.cpp::Positive block 2 AssertCompiles.
// Currently #if 0 (#as-engine-behavior: mixin class syntax unsupported).
// Oracle: AMixApplyActor Health CDO is 100.
// Extra: local construct Health 100; mutating one instance leaves the other 100.
// FixtureIsolated. Keep Health.

mixin class UHealthMixinApply
{
	UPROPERTY()
	int Health = 100;
}

class AMixApplyActor : AActor
{
	mixin UHealthMixinApply;
}

int Observe_MixApply_DefaultHealth(AMixApplyActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Positive_02 setup: required Actor is null");
	}
	return Actor.Health;
}

int Observe_MixApply_ZeroBoundary(AMixApplyActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Positive_02 setup: required Actor is null");
	}
	Actor.Health = 0;
	return Actor.Health;
}

bool Observe_MixApply_CopyIndependence(AMixApplyActor First, AMixApplyActor Second)
{
	if (First is null)
	{
		throw("Test_Positive_02 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Positive_02 setup: required Second is null");
	}
	First.Health = 0;
	return First.Health == 0 && Second.Health == 100;
}
