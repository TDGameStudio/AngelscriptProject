/**
 * @version v1
 * @summary A mixin class declaring Health and TakeDamage, applied to an actor host. C++ currently wraps the compile in #if 0 because mixin class syntax is unsupported. The observers cover TakeDamage(30) leaving 70, default Health.
 * @topic Feature
 */
/**
 * @version root
 * @summary A mixin class declaring Health and TakeDamage, applied to an actor host. C++ currently wraps the compile in #if 0 because mixin class syntax is unsupported. The observers cover TakeDamage(30) leaving 70, default Health.
 * @topic Baseline
 */
mixin class UHealthMixinBasic
{
	UPROPERTY()
	int Health = 100;

	/**
	 * Subtracts Amount from Health.
	 *
	 * @Kind Mixin
	 * @Covers Mixin.MixBasicDecl
	 * @Inputs a damage amount
	 * @Param Amount subtracted from Health
	 * @Return void; Health decreases by Amount
	 */
	void TakeDamage(int Amount)
	{
		Health -= Amount;
	}
}

class AMixBasicHost : AActor
{
	mixin UHealthMixinBasic;

	/**
	 * Observe that TakeDamage(30) leaves Health at 70.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixBasicDecl
	 * @Inputs TakeDamage(30) on default Health 100
	 * @Return Health after the hit
	 */
	UFUNCTION()
	int TakeDamageLeavesSeventy()
	{
		TakeDamage(30);
		return Health;
	}

	/**
	 * Observe that Health starts at 100.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixBasicDecl
	 * @Inputs this host before TakeDamage
	 * @Return Health
	 * @Boundary default Health
	 */
	UFUNCTION()
	int DefaultHealth()
	{
		return Health;
	}

	/**
	 * Observe that TakeDamage(0) keeps Health at 100.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixBasicDecl
	 * @Inputs TakeDamage(0)
	 * @Return Health after a zero hit
	 * @Boundary zero damage
	 */
	UFUNCTION()
	int TakeDamageZeroKeepsHealth()
	{
		TakeDamage(0);
		return Health;
	}

	/**
	 * Observe that damaging this host leaves another host at 100.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixBasicDecl
	 * @Inputs this host and a second host
	 * @Param Second the other host, expected to stay at 100
	 * @Return true when this Health is 70 and Second.Health is 100
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TakeDamageIsIndependent(AMixBasicHost Second)
	{
		if (Second is null)
		{
			throw("MixBasicDecl setup: required Second is null");
		}
		TakeDamage(30);
		if (Health != 70)
		{
			return false;
		}
		return Second.Health == 100;
	}
}
/** @end */
