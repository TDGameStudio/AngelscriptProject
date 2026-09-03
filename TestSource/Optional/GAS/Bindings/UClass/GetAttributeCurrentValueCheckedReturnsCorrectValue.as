/**
 * A script attribute set exposing Wisdom for the current-value checked accessor.
 * The observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.AttributeCurrentValueChecked
 * @Harness UClass
 * @Tag Optional.GAS.GetAttributeCurrentValueCheckedReturnsCorrectValue
 * @Provenance Theme: Optional.GAS. WorldStory TryGetAttributeCurrentValue on Wisdom.
 * @Provenance C++: AngelscriptGASFGameplayAttributeBindingsTests.cpp::GetAttributeCurrentValueCheckedReturnsCorrectValue
 * @Provenance Keep UPROPERTY Wisdom. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestGetCurrentAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Wisdom;

	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.AttributeCurrentValueChecked
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
	 * @Covers GAS.AttributeCurrentValueChecked
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
