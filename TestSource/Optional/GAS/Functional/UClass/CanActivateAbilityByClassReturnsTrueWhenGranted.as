/**
 * An ability granted through GiveAbility, after which CanActivateAbilityByClass
 * reports true. The observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.CanActivateByClassGranted
 * @Harness UClass
 * @Tag Optional.GAS.CanActivateAbilityByClassReturnsTrueWhenGranted
 * @Provenance Theme: Optional.GAS. WorldStory CanActivateAbilityByClass is true after GiveAbility.
 * @Provenance C++: AngelscriptGASAbilityActivationTests.cpp::CanActivateAbilityByClassReturnsTrueWhenGranted
 * @Provenance Keep UTestGrantedAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestGrantedAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.CanActivateByClassGranted
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
	 * @Covers GAS.CanActivateByClassGranted
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
