/**
 * A script attribute set exposing Power as a valid FGameplayAttribute. The
 * observers cover the empty tag and empty container vectors that C++ also reads.
 *
 * @Theme Optional.GAS
 * @Subject GAS.AttributeFromScriptSetIsValid
 * @Harness UClass
 * @Tag Optional.GAS.FGameplayAttributeFromScriptSetIsValid
 * @Provenance Theme: Optional.GAS. WorldStory script attribute set Power is a valid FGameplayAttribute.
 * @Provenance C++: AngelscriptGASFGameplayAttributeBindingsTests.cpp::FGameplayAttributeFromScriptSetIsValid
 * @Provenance Keep UPROPERTY Power. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestFGAValidAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Power;

	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.AttributeFromScriptSetIsValid
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
	 * @Covers GAS.AttributeFromScriptSetIsValid
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
