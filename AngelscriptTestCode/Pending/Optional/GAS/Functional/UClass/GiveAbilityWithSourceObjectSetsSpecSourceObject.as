/**
 * @version v1
 * @summary An ability granted with a source object, which must land on the spec. The trailing AddExpectedError in C++ belongs to a sibling null-class test rather than this class. The observers cover the empty tag and empty.
 * @topic Optional
 */
/**
 * @version root
 * @summary An ability granted with a source object, which must land on the spec. The trailing AddExpectedError in C++ belongs to a sibling null-class test rather than this class. The observers cover the empty tag and empty.
 * @topic Baseline
 */
UCLASS()
class UTestSrcObjAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.GiveAbilityWithSourceObject
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
	 * @Covers GAS.GiveAbilityWithSourceObject
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
