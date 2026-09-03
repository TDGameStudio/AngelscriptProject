/**
 * An attribute set exposing Power, whose base value round-trips through
 * TrySetAttributeBaseValue and TryGetAttributeBaseValue. The trailing
 * AddExpectedError in C++ belongs to a sibling null-class test rather than this
 * class. The observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.TrySetAndGetAttributeBaseValue
 * @Harness UClass
 * @Tag Optional.GAS.TrySetAndGetAttributeBaseValue
 * @Provenance Theme: Optional.GAS. WorldStory TrySet/TryGetAttributeBaseValue Power == 42.
 * @Provenance C++: AngelscriptGASAbilitySystemComponentTests.cpp::TrySetAndGetAttributeBaseValue
 * @Provenance Trailing C++ AddExpectedError is a sibling null-class test, not this class.
 * @Provenance Keep UPROPERTY Power. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UASCSetGetBaseAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Power;

	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.TrySetAndGetAttributeBaseValue
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
	 * @Covers GAS.TrySetAndGetAttributeBaseValue
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
