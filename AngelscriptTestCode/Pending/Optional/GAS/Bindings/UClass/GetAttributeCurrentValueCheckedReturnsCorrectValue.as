/**
 * @version v1
 * @summary A script attribute set exposing Wisdom for the current-value checked accessor. The observers cover the empty tag and empty container vectors.
 * @topic Optional
 */
/**
 * @version root
 * @summary A script attribute set exposing Wisdom for the current-value checked accessor. The observers cover the empty tag and empty container vectors.
 * @topic Baseline
 */
UCLASS()
class UTestGetCurrentAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Wisdom;

	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.AttributeCurrentValueChecked
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
	 * @Covers GAS.AttributeCurrentValueChecked
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
/** @end */
