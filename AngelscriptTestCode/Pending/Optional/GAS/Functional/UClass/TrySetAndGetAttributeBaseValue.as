/**
 * @version v1
 * @summary An attribute set exposing Power, whose base value round-trips through TrySetAttributeBaseValue and TryGetAttributeBaseValue. The trailing AddExpectedError in C++ belongs to a sibling null-class test rather than this.
 * @topic Optional
 */
/**
 * @version root
 * @summary An attribute set exposing Power, whose base value round-trips through TrySetAttributeBaseValue and TryGetAttributeBaseValue. The trailing AddExpectedError in C++ belongs to a sibling null-class test rather than this.
 * @topic Baseline
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
/** @end */
