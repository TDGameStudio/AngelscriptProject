/**
 * An ability that was never granted, so CanActivateAbilityByClass reports false.
 * The observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.CanActivateByClassNotGranted
 * @Harness UClass
 * @Tag Optional.GAS.CanActivateAbilityByClassReturnsFalseWhenNotGranted
 * @Provenance Theme: Optional.GAS. WorldStory CanActivateAbilityByClass is false when not granted.
 * @Provenance C++: AngelscriptGASAbilityActivationTests.cpp::CanActivateAbilityByClassReturnsFalseWhenNotGranted
 * @Provenance Keep UTestNotGrantedAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestNotGrantedAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.CanActivateByClassNotGranted
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
	 * @Covers GAS.CanActivateByClassNotGranted
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
