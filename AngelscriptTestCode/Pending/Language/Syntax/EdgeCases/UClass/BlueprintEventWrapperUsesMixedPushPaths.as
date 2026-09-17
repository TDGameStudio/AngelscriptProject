/**
 * @version v1
 * @summary A BlueprintEvent taking a const FString reference alongside a TSubclassOf, so its wrapper must marshal two different push paths in one call. Only the class argument affects the result; the label is passed but unused.
 * @topic Language
 */
/**
 * @version root
 * @summary A BlueprintEvent taking a const FString reference alongside a TSubclassOf, so its wrapper must marshal two different push paths in one call. Only the class argument affects the result; the label is passed but unused.
 * @topic Baseline
 */
UCLASS()
class UCompilerBlueprintEventMixedPushCarrier : UObject
{
	/**
	 * A BlueprintEvent combining a string reference and a class argument.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a label and a class value
	 * @Return 42 when the class is AActor, otherwise 0
	 * @Param Label a string passed by const reference and left unused
	 * @Param TypeValue the class compared against AActor
	 */
	UFUNCTION(BlueprintEvent)
	int EvaluateMixedPush(const FString&in Label, TSubclassOf<AActor> TypeValue)
	{
		return TypeValue == AActor::StaticClass() ? 42 : 0;
	}

	/**
	 * Calls the mixed-push method with both argument kinds.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION()
	int Entry()
	{
		return EvaluateMixedPush("Alpha", AActor::StaticClass());
	}

	/**
	 * Observe that the mixed-push wrapper returns the matched value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 42
	 */
	UFUNCTION()
	bool MixedPushWrapperReturnsMatchedValue()
	{
		return Entry() == 42;
	}

	/**
	 * Observe the empty-class boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EvaluateMixedPush with an empty TSubclassOf
	 * @Return true when the result is 0
	 * @Boundary empty class
	 */
	UFUNCTION()
	bool MixedPushEmptyTypeBoundary()
	{
		TSubclassOf<AActor> Empty;
		return EvaluateMixedPush("Alpha", Empty) == 0;
	}

	/**
	 * Observe that an empty label does not change the class match.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EvaluateMixedPush with an empty label
	 * @Return true when the result is still 42
	 * @Boundary empty label
	 */
	UFUNCTION()
	bool MixedPushEmptyLabelStillMatches()
	{
		return EvaluateMixedPush("", AActor::StaticClass()) == 42;
	}
}
/** @end */
