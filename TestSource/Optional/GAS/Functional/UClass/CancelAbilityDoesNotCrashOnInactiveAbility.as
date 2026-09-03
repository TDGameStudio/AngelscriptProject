/**
 * Cancelling an inactive granted ability must not crash. The trailing
 * AddExpectedError in C++ belongs to a sibling null-class test rather than this
 * class, so this file stays a plain compile-and-run fixture.
 *
 * @Theme Optional.GAS
 * @Subject GAS.CancelInactiveAbility
 * @Harness UClass
 * @Tag Optional.GAS.CancelAbilityDoesNotCrashOnInactiveAbility
 * @Provenance Theme: Optional.GAS. WorldStory CancelAbility on an inactive granted ability.
 * @Provenance C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::CancelAbilityDoesNotCrashOnInactiveAbility
 * @Provenance Trailing C++ AddExpectedError is a sibling null-class test, not this class.
 * @Provenance Keep UTestCancelInactiveAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestCancelInactiveAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.CancelInactiveAbility
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
	 * @Covers GAS.CancelInactiveAbility
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
