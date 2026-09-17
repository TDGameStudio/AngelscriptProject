/**
 * @version v1
 * @summary Body-only soft-reload initial source. GetValue returns 1; a live Consumer Provider property is null. The reload file replaces the GetValue body with 2.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Body-only soft-reload initial source. GetValue returns 1; a live Consumer Provider property is null. The reload file replaces the GetValue body with 2.
 * @topic Baseline
 */
UCLASS()
class UClassGeneratorPropagationSoftProvider : UObject
{
	/**
	 * Observe GetValue: the initial body returns 1.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs none
	 * @Return 1
	 */
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}

	/**
	 * Observe that a nullptr provider handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs UClassGeneratorPropagationSoftProvider Provider = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UClassGeneratorPropagationSoftProvider Provider = nullptr;
		return Provider == nullptr;
	}

	/**
	 * Observe GetValue on this provider and a second live provider.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other live provider
	 * @Inputs two providers
	 * @Return GetValue() + Second.GetValue()
	 */
	UFUNCTION()
	int GetValueOnTwo(UClassGeneratorPropagationSoftProvider Second)
	{
		if (Second is null)
		{
			throw("BodyOnlyProviderInitial setup: required Second is null");
		}
		return GetValue() + Second.GetValue();
	}
}

UCLASS()
class UClassGeneratorPropagationSoftConsumer : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationSoftProvider Provider;

	/**
	 * Observe that a live consumer's Provider is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed consumer
	 * @Return true when Provider is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool ProviderDefaultIsNull()
	{
		return Provider == nullptr;
	}
}
/** @end */
