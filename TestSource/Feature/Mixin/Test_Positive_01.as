// Theme: Feature.Mixin. Positive mixin declaration with TakeDamage.
// C++: AngelscriptSyntaxMixinTests.cpp::Positive block 1 AssertCompiles.
// Currently #if 0 (#as-engine-behavior: mixin class syntax unsupported).
// Oracle: Health starts at 100; TakeDamage(30) leaves 70.
// Extra: TakeDamage(0) keeps 100; second host stays 100.
// DefaultSafe.

mixin class UHealthMixinBasic
{
	UPROPERTY()
	int Health = 100;

	void TakeDamage(int Amount)
	{
		Health -= Amount;
	}
}

class AMixBasicHost : AActor
{
	mixin UHealthMixinBasic;
}

int Observe_TakeDamage_Nominal(AMixBasicHost Actor)
{
	if (Actor is null)
	{
		throw("Test_Positive_01 setup: required Actor is null");
	}
	Actor.TakeDamage(30);
	return Actor.Health;
}

int Observe_TakeDamage_DefaultHealth(AMixBasicHost Actor)
{
	if (Actor is null)
	{
		throw("Test_Positive_01 setup: required Actor is null");
	}
	return Actor.Health;
}

int Observe_TakeDamage_ZeroBoundary(AMixBasicHost Actor)
{
	if (Actor is null)
	{
		throw("Test_Positive_01 setup: required Actor is null");
	}
	Actor.TakeDamage(0);
	return Actor.Health;
}

bool Observe_TakeDamage_CopyIndependence(AMixBasicHost First, AMixBasicHost Second)
{
	if (First is null)
	{
		throw("Test_Positive_01 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Positive_01 setup: required Second is null");
	}
	First.TakeDamage(30);
	return First.Health == 70 && Second.Health == 100;
}
