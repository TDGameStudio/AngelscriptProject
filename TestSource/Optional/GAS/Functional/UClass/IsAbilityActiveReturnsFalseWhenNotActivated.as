/**
 * An ability that was granted but never activated, so IsAbilityActive reports
 * false. The trailing AddExpectedError in C++ belongs to a sibling null-class test
 * rather than this class. The observers cover the empty tag and empty container
 * vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.IsAbilityActiveWhenInactive
 * @Harness UClass
 * @Tag Optional.GAS.IsAbilityActiveReturnsFalseWhenNotActivated
 * @Provenance Theme: Optional.GAS. WorldStory IsAbilityActive is false when given but not activated.
 * @Provenance C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::IsAbilityActiveReturnsFalseWhenNotActivated
 * @Provenance Trailing C++ AddExpectedError is a sibling null-class test, not this class.
 * @Provenance Keep UTestInactiveAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestInactiveAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.IsAbilityActiveWhenInactive
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
	 * @Covers GAS.IsAbilityActiveWhenInactive
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
