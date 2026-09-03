/**
 * A script attribute set exposing Vitality for the base-value setter. The
 * observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.TrySetAttributeBaseValue
 * @Harness UClass
 * @Tag Optional.GAS.TrySetAttributeBaseValueReturnsTrueOnSuccess
 * @Provenance Theme: Optional.GAS. WorldStory TrySetAttributeBaseValue on Vitality.
 * @Provenance C++: AngelscriptGASFGameplayAttributeBindingsTests.cpp::TrySetAttributeBaseValueReturnsTrueOnSuccess
 * @Provenance Keep UPROPERTY Vitality. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestSetBaseAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Vitality;

	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.TrySetAttributeBaseValue
	 * @Inputs a default-constructed tag
	 * @Return 1
	 * @Boundary empty tag
	 */
	UFUNCTION()
	int EmptyTagIsInvalid()
	{
		FGameplayTag EmptyTag;
		return EmptyTag.IsValid() ? 0 : 1;
	}

	/**
	 * Observe that a default container reports empty.
	 *
	 * @Kind Observe
	 * @Covers GAS.TrySetAttributeBaseValue
	 * @Inputs a default-constructed container
	 * @Return 1
	 * @Boundary empty container
	 */
	UFUNCTION()
	int EmptyContainerIsEmpty()
	{
		FGameplayTagContainer EmptyContainer;
		return EmptyContainer.IsEmpty() ? 1 : 0;
	}
}
