/**
 * An attribute set exposing Health and MaxHealth, which RegisterAttributeSet must
 * instantiate. The observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.RegisterAttributeSetCreatesInstance
 * @Harness UClass
 * @Tag Optional.GAS.RegisterAttributeSetCreatesInstance
 * @Provenance Theme: Optional.GAS. WorldStory RegisterAttributeSet creates a Health/MaxHealth instance.
 * @Provenance C++: AngelscriptGASAbilitySystemComponentTests.cpp::RegisterAttributeSetCreatesInstance
 * @Provenance Keep UPROPERTY Health and MaxHealth. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UASCTestAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Health;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData MaxHealth;

	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterAttributeSetCreatesInstance
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
	 * @Covers GAS.RegisterAttributeSetCreatesInstance
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
