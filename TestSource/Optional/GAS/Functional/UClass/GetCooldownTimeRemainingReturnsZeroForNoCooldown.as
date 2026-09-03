/**
 * An ability with no cooldown tags, so GetCooldownTimeRemaining reports zero. The
 * trailing AddExpectedError in C++ belongs to a sibling null-class test rather than
 * this class. The observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.GetCooldownTimeRemainingZero
 * @Harness UClass
 * @Tag Optional.GAS.GetCooldownTimeRemainingReturnsZeroForNoCooldown
 * @Provenance Theme: Optional.GAS. WorldStory GetCooldownTimeRemaining is 0 with no cooldown tags.
 * @Provenance C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::GetCooldownTimeRemainingReturnsZeroForNoCooldown
 * @Provenance Trailing C++ AddExpectedError is a sibling null-class test, not this class.
 * @Provenance Keep UTestNoCooldownAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestNoCooldownAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.GetCooldownTimeRemainingZero
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
	 * @Covers GAS.GetCooldownTimeRemainingZero
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
