/**
 * An ability that has not been granted yet, so HasAbility reports false. The
 * observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.HasAbilityBeforeGive
 * @Harness UClass
 * @Tag Optional.GAS.HasAbilityReturnsFalseBeforeGive
 * @Provenance Theme: Optional.GAS. WorldStory HasAbility is false before GiveAbility.
 * @Provenance C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::HasAbilityReturnsFalseBeforeGive
 * @Provenance Keep UTestNoGiveAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestNoGiveAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.HasAbilityBeforeGive
	 * @Inputs a default-constructed tag
	 * @Return 1
	 * @Boundary empty tag
	 */
	UFUNCTION()
	int EmptyTag()
	{
		FGameplayTag EmptyTag;
		return EmptyTag.IsValid() ? 0 : 1;
	}

	/**
	 * Observe that a default container reports empty.
	 *
	 * @Kind Observe
	 * @Covers GAS.HasAbilityBeforeGive
	 * @Inputs a default-constructed container
	 * @Return 1
	 * @Boundary empty container
	 */
	UFUNCTION()
	int EmptyContainer()
	{
		FGameplayTagContainer EmptyContainer;
		return EmptyContainer.IsEmpty() ? 1 : 0;
	}
}
