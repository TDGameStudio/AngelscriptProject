/**
 * @version v1
 * @summary An explicit preprocessor context selects which of two class definitions is live: with CONTEXT_ENABLED set, only the first carrier is detected, and the one in the #else branch never exists. The observers check the live.
 * @topic Language
 */
/**
 * @version root
 * @summary An explicit preprocessor context selects which of two class definitions is live: with CONTEXT_ENABLED set, only the first carrier is detected, and the one in the #else branch never exists. The observers check the live.
 * @topic Baseline
 */
#if CONTEXT_ENABLED
UCLASS()
class UExplicitContextCarrier : UObject
{
	/**
	 * A no-op method on the live carrier.
	 *
	 * @Covers Preprocessor.Conditionals
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void ImplicitFunction()
	{
	}

	UPROPERTY()
	int ImplicitProperty;

	/**
	 * Observe that the property defaults to zero.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs a freshly constructed carrier
	 * @Return true when ImplicitProperty is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ImplicitPropertyDefaultsToZero()
	{
		return ImplicitProperty == 0;
	}

	/**
	 * Observe that calling the function leaves the property untouched.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs ImplicitFunction() then ImplicitProperty
	 * @Return true when the property is still 0
	 * @Boundary no mutation
	 */
	UFUNCTION()
	bool ImplicitFunctionDoesNotMutateProperty()
	{
		ImplicitFunction();
		return ImplicitProperty == 0;
	}
}
#else
UCLASS()
class UWrongContextCarrier : UObject
{
	UPROPERTY()
	int WrongProperty;
}
#endif
/** @end */
