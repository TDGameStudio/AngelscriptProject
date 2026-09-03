/**
 * A mixin method GetDamage. C++ currently wraps the compile in #if 0 because
 * mixin class syntax is unsupported. The observers cover GetDamage()==10,
 * writing Damage to 0, and instance independence.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.MixMethod
 * @Harness UClass
 * @Tag Feature.Mixin.MixMethod
 * @Provenance Theme: Feature.Mixin. Positive mixin method GetDamage.
 * @Provenance C++: AngelscriptSyntaxMixinTests.cpp::Positive block 4 AssertCompiles.
 * @Provenance Currently #if 0 (#as-engine-behavior: mixin class syntax unsupported).
 * @Provenance Oracle: GetDamage() == 10. Extra: default Damage 10; write 0; copy independence.
 * @Provenance DefaultSafe.
 */

mixin class UCombatMixin
{
	int Damage = 10;

	/**
	 * Returns the mixin's Damage.
	 *
	 * @Kind Mixin
	 * @Covers Mixin.MixMethod
	 * @Inputs none
	 * @Return Damage
	 */
	int GetDamage()
	{
		return Damage;
	}
}

class AMixCombatHost : AActor
{
	mixin UCombatMixin;

	/**
	 * Observe that GetDamage returns the default 10.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixMethod
	 * @Inputs this host before any write
	 * @Return GetDamage()
	 * @Boundary default Damage
	 */
	UFUNCTION()
	int DefaultGetDamage()
	{
		return GetDamage();
	}

	/**
	 * Observe that writing Damage to 0 makes GetDamage return 0.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixMethod
	 * @Inputs Damage = 0
	 * @Return GetDamage() after the write
	 * @Boundary zero Damage
	 */
	UFUNCTION()
	int ZeroDamageBoundary()
	{
		Damage = 0;
		return GetDamage();
	}

	/**
	 * Observe that writing this host leaves another host at GetDamage 10.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixMethod
	 * @Inputs this host and a second host
	 * @Param Second the other host, expected to stay at 10
	 * @Return true when this GetDamage is 0 and Second.GetDamage is 10
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool DamageWriteIsIndependent(AMixCombatHost Second)
	{
		if (Second is null)
		{
			throw("MixMethod setup: required Second is null");
		}
		Damage = 0;
		if (GetDamage() != 0)
		{
			return false;
		}
		return Second.GetDamage() == 10;
	}
}
