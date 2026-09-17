/**
 * @version v1
 * @summary The default FGameplayAbilitySpec Level is 1 on UE 5.7, and a second default spec is the same. The dynamic ability tags start empty.
 * @topic Optional
 */
/**
 * @version root
 * @summary The default FGameplayAbilitySpec Level is 1 on UE 5.7, and a second default spec is the same. The dynamic ability tags start empty.
 * @topic Baseline
 */
namespace GASTest
{
	/**
	 * Reads the level of a default ability spec.
	 *
	 * @Covers GAS.AbilitySpecDefault
	 * @Inputs a default-constructed spec
	 * @Return the Level, 1 by default
	 */
	int AbilitySpecDefaultLevel()
	{
		FGameplayAbilitySpec Spec;
		return Spec.Level;
	}

	/**
	 * Observe the level of a default spec.
	 *
	 * @Kind Observe
	 * @Covers GAS.AbilitySpecDefault
	 * @Inputs a default-constructed spec
	 * @Return 1
	 * @Boundary default value
	 */
	UFUNCTION()
	int AbilitySpecLevelNominal()
	{
		return AbilitySpecDefaultLevel();
	}

	/**
	 * Observe that a second default spec carries the same level.
	 *
	 * @Kind Observe
	 * @Covers GAS.AbilitySpecDefault
	 * @Inputs two default-constructed specs
	 * @Return 1 when both report 1
	 * @Boundary second instance
	 */
	UFUNCTION()
	int AbilitySpecLevelSecondDefault()
	{
		FGameplayAbilitySpec First;
		FGameplayAbilitySpec Second;

		if (First.Level != 1)
		{
			return 0;
		}
		if (Second.Level != 1)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a default spec carries no dynamic ability tags.
	 *
	 * @Kind Observe
	 * @Covers GAS.AbilitySpecDefault
	 * @Inputs a default-constructed spec
	 * @Return 0
	 * @Boundary empty tags
	 */
	UFUNCTION()
	int AbilitySpecLevelEmptyTags()
	{
		FGameplayAbilitySpec Spec;
		return Spec.DynamicAbilityTags.Num();
	}
}
/** @end */
