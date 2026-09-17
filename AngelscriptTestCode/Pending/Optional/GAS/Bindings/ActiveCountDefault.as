/**
 * @version v1
 * @summary The default ability spec's ActiveCount is zero, and a second default spec is zero as well. The dynamic ability tags start empty.
 * @topic Optional
 */
/**
 * @version root
 * @summary The default ability spec's ActiveCount is zero, and a second default spec is zero as well. The dynamic ability tags start empty.
 * @topic Baseline
 */
namespace GASTest
{
	/**
	 * Reads the active count of a default ability spec.
	 *
	 * @Covers GAS.ActiveCountDefault
	 * @Inputs a default-constructed spec
	 * @Return the ActiveCount, 0 by default
	 */
	int ActiveCountOfDefaultSpec()
	{
		FGameplayAbilitySpec Spec;
		return int(Spec.ActiveCount);
	}

	/**
	 * Observe the active count of a default spec.
	 *
	 * @Kind Observe
	 * @Covers GAS.ActiveCountDefault
	 * @Inputs a default-constructed spec
	 * @Return 0
	 * @Boundary default value
	 */
	UFUNCTION()
	int ActiveCountNominal()
	{
		return ActiveCountOfDefaultSpec();
	}

	/**
	 * Observe that a second default spec is also zero.
	 *
	 * @Kind Observe
	 * @Covers GAS.ActiveCountDefault
	 * @Inputs two default-constructed specs
	 * @Return 0
	 * @Boundary second instance
	 */
	UFUNCTION()
	int ActiveCountSecondDefault()
	{
		FGameplayAbilitySpec First;
		FGameplayAbilitySpec Second;
		return int(First.ActiveCount) + int(Second.ActiveCount);
	}

	/**
	 * Observe that a default spec carries no dynamic ability tags.
	 *
	 * @Kind Observe
	 * @Covers GAS.ActiveCountDefault
	 * @Inputs a default-constructed spec
	 * @Return 0
	 * @Boundary empty tags
	 */
	UFUNCTION()
	int ActiveCountEmptyTags()
	{
		FGameplayAbilitySpec Spec;
		return Spec.DynamicAbilityTags.Num();
	}
}
/** @end */
