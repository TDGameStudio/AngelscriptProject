// Theme: Feature.Mixin. WorldStory: two mixins on one actor.
// C++: AngelscriptSyntaxMixinTests.cpp::Positive block 3 AssertCompiles.
// Currently #if 0 (#as-engine-behavior: mixin class syntax unsupported).
// Oracle: AMixMultiActor Health==100 and Speed==5.0f.
// Extra: zeros; mutating one instance leaves the other at defaults.
// FixtureIsolated.

mixin class UHealthMixinMulti
{
	int Health = 100;
}

mixin class UMoveMixin
{
	float Speed = 5.0f;
}

class AMixMultiActor : AActor
{
	mixin UHealthMixinMulti;
	mixin UMoveMixin;
}

int Observe_MixMulti_DefaultHealth(AMixMultiActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Positive_03 setup: required Actor is null");
	}
	return Actor.Health;
}

float Observe_MixMulti_DefaultSpeed(AMixMultiActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Positive_03 setup: required Actor is null");
	}
	return Actor.Speed;
}

int Observe_MixMulti_ZeroBoundary(AMixMultiActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Positive_03 setup: required Actor is null");
	}
	Actor.Health = 0;
	Actor.Speed = 0.0f;
	return Actor.Health;
}

bool Observe_MixMulti_CopyIndependence(AMixMultiActor First, AMixMultiActor Second)
{
	if (First is null)
	{
		throw("Test_Positive_03 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Positive_03 setup: required Second is null");
	}
	First.Health = 0;
	First.Speed = 0.0f;
	return First.Health == 0 && Second.Health == 100 && Second.Speed == 5.0f;
}
