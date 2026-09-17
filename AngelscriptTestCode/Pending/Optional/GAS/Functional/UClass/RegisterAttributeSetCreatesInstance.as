/**
 * @version v1
 * @summary An attribute set exposing Health and MaxHealth, which RegisterAttributeSet must instantiate. The observers cover the empty tag and empty container vectors.
 * @topic Optional
 */
/**
 * @version root
 * @summary An attribute set exposing Health and MaxHealth, which RegisterAttributeSet must instantiate. The observers cover the empty tag and empty container vectors.
 * @topic Baseline
 */
UCLASS()
class UASCTestAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Health;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData MaxHealth;

	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterAttributeSetCreatesInstance
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
	 * @Covers GAS.RegisterAttributeSetCreatesInstance
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
