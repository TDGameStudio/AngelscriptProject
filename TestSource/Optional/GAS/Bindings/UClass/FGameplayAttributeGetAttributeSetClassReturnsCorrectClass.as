/**
 * A script attribute set whose GetAttributeSetClass resolves back to the scripting
 * set. The observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.AttributeSetClassMatches
 * @Harness UClass
 * @Tag Optional.GAS.FGameplayAttributeGetAttributeSetClassReturnsCorrectClass
 * @Provenance Theme: Optional.GAS. WorldStory GetAttributeSetClass matches the script set.
 * @Provenance C++: AngelscriptGASFGameplayAttributeBindingsTests.cpp::FGameplayAttributeGetAttributeSetClassReturnsCorrectClass
 * @Provenance Keep UPROPERTY Agility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestFGAClassAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Agility;

	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.AttributeSetClassMatches
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
	 * @Covers GAS.AttributeSetClassMatches
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
