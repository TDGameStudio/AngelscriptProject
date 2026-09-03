/**
 * An attribute set whose Energy reads back its default current value. The
 * observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.GetAttributeCurrentValueDefault
 * @Harness UClass
 * @Tag Optional.GAS.GetAttributeCurrentValueReturnsDefault
 * @Provenance Theme: Optional.GAS. WorldStory GetAttributeCurrentValue on fresh Energy is 0.
 * @Provenance C++: AngelscriptGASAbilitySystemComponentTests.cpp::GetAttributeCurrentValueReturnsDefault
 * @Provenance Keep UPROPERTY Energy. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UASCGetValAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Energy;

	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.GetAttributeCurrentValueDefault
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
	 * @Covers GAS.GetAttributeCurrentValueDefault
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
