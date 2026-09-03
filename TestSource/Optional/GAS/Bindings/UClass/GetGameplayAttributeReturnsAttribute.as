/**
 * A script attribute set exposing Luck so the mixin GetGameplayAttribute can
 * resolve it. The observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.MixinGetGameplayAttribute
 * @Harness UClass
 * @Tag Optional.GAS.GetGameplayAttributeReturnsAttribute
 * @Provenance Theme: Optional.GAS. WorldStory script attribute set Luck for mixin GetGameplayAttribute.
 * @Provenance C++: AngelscriptGASAttributeChangedDataMixinTests.cpp::GetGameplayAttributeReturnsAttribute
 * @Provenance C++ CompileScriptModule UTestMixinAttrSet, GetGameplayAttribute("Luck") IsValid.
 * @Provenance Extra: empty tag/container helpers. Keep UPROPERTY Luck.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestMixinAttrSet : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Luck;

	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.MixinGetGameplayAttribute
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
	 * @Covers GAS.MixinGetGameplayAttribute
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
