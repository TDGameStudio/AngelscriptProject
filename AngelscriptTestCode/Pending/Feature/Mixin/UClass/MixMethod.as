/**
 * @version v1
 * @summary A mixin method GetDamage. C++ currently wraps the compile in #if 0 because mixin class syntax is unsupported. The observers cover GetDamage()==10, writing Damage to 0, and instance independence.
 * @topic Feature
 */
/**
 * @version root
 * @summary A mixin method GetDamage. C++ currently wraps the compile in #if 0 because mixin class syntax is unsupported. The observers cover GetDamage()==10, writing Damage to 0, and instance independence.
 * @topic Baseline
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
/** @end */
