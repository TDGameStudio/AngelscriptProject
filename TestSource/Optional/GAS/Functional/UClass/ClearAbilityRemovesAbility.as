/**
 * An ability removed through ClearAbility, after which HasAbility reports false.
 * The trailing AddExpectedError in C++ belongs to a sibling null-class test rather
 * than this class. The observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.ClearAbilityRemoves
 * @Harness UClass
 * @Tag Optional.GAS.ClearAbilityRemovesAbility
 * @Provenance Theme: Optional.GAS. WorldStory ClearAbility then HasAbility is false.
 * @Provenance C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::ClearAbilityRemovesAbility
 * @Provenance Trailing C++ AddExpectedError is a sibling null-class test, not this class.
 * @Provenance Keep UTestClearAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestClearAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.ClearAbilityRemoves
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
	 * @Covers GAS.ClearAbilityRemoves
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
