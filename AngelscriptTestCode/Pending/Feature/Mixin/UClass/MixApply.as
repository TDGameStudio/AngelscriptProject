/**
 * @version v1
 * @summary A mixin applied to an actor subclass. C++ currently wraps the compile in #if 0 because mixin class syntax is unsupported. The observers cover default Health 100, writing Health to 0, and instance independence.
 * @topic Feature
 */
/**
 * @version root
 * @summary A mixin applied to an actor subclass. C++ currently wraps the compile in #if 0 because mixin class syntax is unsupported. The observers cover default Health 100, writing Health to 0, and instance independence.
 * @topic Baseline
 */
mixin class UHealthMixinApply
{
	UPROPERTY()
	int Health = 100;
}

class AMixApplyActor : AActor
{
	mixin UHealthMixinApply;

	/**
	 * Observe that Health starts at 100.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixApply
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
	 * Observe that writing Health to 0 reads back 0.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixApply
	 * @Inputs Health = 0
	 * @Return Health after the write
	 * @Boundary zero Health
	 */
	UFUNCTION()
	int ZeroHealthBoundary()
	{
		Health = 0;
		return Health;
	}

	/**
	 * Observe that writing this actor leaves another actor at 100.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixApply
	 * @Inputs this actor and a second actor
	 * @Param Second the other actor, expected to stay at 100
	 * @Return true when this Health is 0 and Second.Health is 100
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool HealthWriteIsIndependent(AMixApplyActor Second)
	{
		if (Second is null)
		{
			throw("MixApply setup: required Second is null");
		}
		Health = 0;
		if (Health != 0)
		{
			return false;
		}
		return Second.Health == 100;
	}
}
/** @end */
