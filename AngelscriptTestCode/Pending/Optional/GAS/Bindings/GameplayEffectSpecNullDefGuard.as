/**
 * @version v1
 * @summary A null gameplay effect definition guard: C++ compiles this file and then expects a runtime script exception from the trigger, while the observers only read the empty vectors and never enter the throwing path.
 * @topic Optional
 */
/**
 * @version root
 * @summary A null gameplay effect definition guard: C++ compiles this file and then expects a runtime script exception from the trigger, while the observers only read the empty vectors and never enter the throwing path.
 * @topic Baseline
 */
namespace GASTest
{
	/**
	 * Builds an effect spec from an empty effect class, which throws.
	 *
	 * @Covers GAS.EffectSpecNullDefGuard
	 * @Inputs an empty effect class and a default context
	 * @Return nothing; throws "GameplayEffect was null."
	 */
	void TriggerNullEffectSpec()
	{
		TSubclassOf<UGameplayEffect> EmptyEffectClass;
		UGameplayEffect NullEffect = EmptyEffectClass.GetDefaultObject();
		FGameplayEffectContextHandle Context;
		FGameplayEffectSpec Spec(NullEffect, Context, 1.0f);
	}

	/**
	 * Observe that an empty effect class yields a null default object.
	 *
	 * @Kind Observe
	 * @Covers GAS.EffectSpecNullDefGuard
	 * @Inputs an empty effect class
	 * @Return 1 when the default object is null
	 * @Boundary empty class
	 */
	UFUNCTION()
	int EmptyEffectClassIsNull()
	{
		TSubclassOf<UGameplayEffect> EmptyEffectClass;
		UGameplayEffect NullEffect = EmptyEffectClass.GetDefaultObject();
		return (NullEffect == null) ? 1 : 0;
	}

	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.EffectSpecNullDefGuard
	 * @Inputs a default-constructed tag
	 * @Return 1
	 * @Boundary empty tag
	 */
	UFUNCTION()
	int NullDefGuardEmptyTag()
	{
		FGameplayTag EmptyTag;
		return EmptyTag.IsValid() ? 0 : 1;
	}
}
/** @end */
