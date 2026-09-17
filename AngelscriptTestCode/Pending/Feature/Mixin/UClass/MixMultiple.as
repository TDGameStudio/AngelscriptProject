/**
 * @version v1
 * @summary Two mixins on one actor. C++ currently wraps the compile in #if 0 because mixin class syntax is unsupported. The observers cover default Health 100, default Speed 5.0, writing both to zero, and instance independence.
 * @topic Feature
 */
/**
 * @version root
 * @summary Two mixins on one actor. C++ currently wraps the compile in #if 0 because mixin class syntax is unsupported. The observers cover default Health 100, default Speed 5.0, writing both to zero, and instance independence.
 * @topic Baseline
 */
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

	/**
	 * Observe that Health starts at 100.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixMultiple
	 * @Inputs this actor before any write
	 * @Return Health
	 * @Boundary default Health
	 */
	UFUNCTION()
	int DefaultHealth()
	{
		return Health;
	}

	/**
	 * Observe that Speed starts at 5.0.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixMultiple
	 * @Inputs this actor before any write
	 * @Return Speed
	 * @Boundary default Speed
	 */
	UFUNCTION()
	float DefaultSpeed()
	{
		return Speed;
	}

	/**
	 * Observe that writing Health and Speed to zero reads Health back as 0.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixMultiple
	 * @Inputs Health = 0 and Speed = 0.0
	 * @Return Health after the write
	 * @Boundary zero Health and Speed
	 */
	UFUNCTION()
	int ZeroHealthAndSpeedBoundary()
	{
		Health = 0;
		Speed = 0.0f;
		return Health;
	}

	/**
	 * Observe that writing this actor leaves another actor at Health 100 and Speed 5.0.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixMultiple
	 * @Inputs this actor and a second actor
	 * @Param Second the other actor, expected to stay at defaults
	 * @Return true when this Health is 0, Second.Health is 100 and Second.Speed is 5.0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool HealthAndSpeedWriteIsIndependent(AMixMultiActor Second)
	{
		if (Second is null)
		{
			throw("MixMultiple setup: required Second is null");
		}
		Health = 0;
		Speed = 0.0f;
		if (Health != 0)
		{
			return false;
		}
		if (Second.Health != 100)
		{
			return false;
		}
		return Second.Speed == 5.0f;
	}
}
/** @end */
