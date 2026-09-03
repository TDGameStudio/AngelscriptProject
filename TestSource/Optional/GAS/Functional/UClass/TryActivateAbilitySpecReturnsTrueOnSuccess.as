/**
 * An ability whose TryActivateAbilitySpec reports true on a successful
 * activation. The observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.TryActivateAbilitySpecSuccess
 * @Harness UClass
 * @Tag Optional.GAS.TryActivateAbilitySpecReturnsTrueOnSuccess
 * @Provenance Theme: Optional.GAS. WorldStory TryActivateAbilitySpec returns true on success.
 * @Provenance C++: AngelscriptGASAbilityActivationTests.cpp::TryActivateAbilitySpecReturnsTrueOnSuccess
 * @Provenance Keep UTestActivateSuccessAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestActivateSuccessAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryActivateAbilitySpecSuccess
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
	 * @Covers GAS.TryActivateAbilitySpecSuccess
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
