/**
 * An ability granted and activated in one call, which must return a valid handle.
 * The trailing AddExpectedError in C++ belongs to a sibling null-class test rather
 * than this class. The observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.GiveAbilityAndActivateOnce
 * @Harness UClass
 * @Tag Optional.GAS.GiveAbilityAndActivateOnceReturnsValidHandle
 * @Provenance Theme: Optional.GAS. WorldStory GiveAbilityAndActivateOnce returns a valid handle.
 * @Provenance C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::GiveAbilityAndActivateOnceReturnsValidHandle
 * @Provenance Trailing C++ AddExpectedError is a sibling null-class test, not this class.
 * @Provenance Keep UTestActivateOnceAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestActivateOnceAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.GiveAbilityAndActivateOnce
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
	 * @Covers GAS.GiveAbilityAndActivateOnce
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
