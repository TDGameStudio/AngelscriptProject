/**
 * @version v1
 * @summary An ability that was granted but never activated, so IsAbilityActive reports false. The trailing AddExpectedError in C++ belongs to a sibling null-class test rather than this class. The observers cover the empty tag and.
 * @topic Optional
 */
/**
 * @version root
 * @summary An ability that was granted but never activated, so IsAbilityActive reports false. The trailing AddExpectedError in C++ belongs to a sibling null-class test rather than this class. The observers cover the empty tag and.
 * @topic Baseline
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
/** @end */
