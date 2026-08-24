// Theme: Feature.Mixin. Positive mixin method GetDamage.
// C++: AngelscriptSyntaxMixinTests.cpp::Positive block 4 AssertCompiles.
// Currently #if 0 (#as-engine-behavior: mixin class syntax unsupported).
// Oracle: GetDamage() == 10. Extra: default Damage 10; write 0; copy independence.
// DefaultSafe.

mixin class UCombatMixin
{
	int Damage = 10;

	int GetDamage()
	{
		return Damage;
	}
}

class AMixCombatHost : AActor
{
	mixin UCombatMixin;
}

int Observe_GetDamage_Nominal(AMixCombatHost Actor)
{
	if (Actor is null)
	{
		throw("Test_Positive_04 setup: required Actor is null");
	}
	return Actor.GetDamage();
}

int Observe_GetDamage_ZeroBoundary(AMixCombatHost Actor)
{
	if (Actor is null)
	{
		throw("Test_Positive_04 setup: required Actor is null");
	}
	Actor.Damage = 0;
	return Actor.GetDamage();
}

bool Observe_GetDamage_CopyIndependence(AMixCombatHost First, AMixCombatHost Second)
{
	if (First is null)
	{
		throw("Test_Positive_04 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Positive_04 setup: required Second is null");
	}
	First.Damage = 0;
	return First.GetDamage() == 0 && Second.GetDamage() == 10;
}
