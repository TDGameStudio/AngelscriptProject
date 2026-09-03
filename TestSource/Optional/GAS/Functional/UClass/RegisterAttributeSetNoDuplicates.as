/**
 * An attribute set exposing Stamina, which a second RegisterAttributeSet call must
 * not duplicate. The observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.RegisterAttributeSetNoDuplicates
 * @Harness UClass
 * @Tag Optional.GAS.RegisterAttributeSetNoDuplicates
 * @Provenance Theme: Optional.GAS. WorldStory second RegisterAttributeSet returns the same instance.
 * @Provenance C++: AngelscriptGASAbilitySystemComponentTests.cpp::RegisterAttributeSetNoDuplicates
 * @Provenance Keep UPROPERTY Stamina. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UASCNoDupAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Stamina;

	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterAttributeSetNoDuplicates
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
	 * @Covers GAS.RegisterAttributeSetNoDuplicates
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
