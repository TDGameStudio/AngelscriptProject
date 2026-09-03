/**
 * A granted ability spec for which CanActivateAbilitySpec reports true. The
 * observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.CanActivateSpecValid
 * @Harness UClass
 * @Tag Optional.GAS.CanActivateAbilitySpecReturnsTrueForValidSpec
 * @Provenance Theme: Optional.GAS. WorldStory CanActivateAbilitySpec is true for a granted spec.
 * @Provenance C++: AngelscriptGASAbilityActivationTests.cpp::CanActivateAbilitySpecReturnsTrueForValidSpec
 * @Provenance Keep UTestValidSpecAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestValidSpecAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.CanActivateSpecValid
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
	 * @Covers GAS.CanActivateSpecValid
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
