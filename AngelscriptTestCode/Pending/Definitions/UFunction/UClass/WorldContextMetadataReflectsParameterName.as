/**
 * @version v1
 * @summary WorldContext metadata names the UObject parameter. ReadWithWorldContext returns Value regardless of the context handle. Value 0 returns 0, and a null context does not change the returned Value.
 * @topic Definitions
 */
/**
 * @version root
 * @summary WorldContext metadata names the UObject parameter. ReadWithWorldContext returns Value regardless of the context handle. Value 0 returns 0, and a null context does not change the returned Value.
 * @topic Baseline
 */
UCLASS()
class ACoverageUFunctionWorldContextActor : AActor
{
	/**
	 * Pass Value through while naming WorldContextObject in metadata.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param WorldContextObject World context named by metadata
	 * @Param Value Value returned unchanged
	 * @Inputs WorldContextObject and Value
	 * @Return Value
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|WorldContext", meta=(WorldContext="WorldContextObject"))
	int ReadWithWorldContext(UObject WorldContextObject, int Value)
	{
		return Value;
	}

	/**
	 * Observe that a live context with Value 7 returns 7.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param WorldContextObject Live world context
	 * @Inputs ReadWithWorldContext(WorldContextObject, 7)
	 * @Return 7
	 */
	UFUNCTION()
	int WorldContextPassThrough(UObject WorldContextObject)
	{
		return ReadWithWorldContext(WorldContextObject, 7);
	}

	/**
	 * Observe the zero boundary with a null context.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ReadWithWorldContext(nullptr, 0)
	 * @Return 0
	 * @Boundary zero value and null context
	 */
	UFUNCTION()
	int WorldContextZeroBoundary()
	{
		return ReadWithWorldContext(nullptr, 0);
	}

	/**
	 * Observe that a null context does not change the returned Value.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ReadWithWorldContext(nullptr, 11)
	 * @Return true when the result is 11
	 * @Boundary null context
	 */
	UFUNCTION()
	bool NullContextDoesNotChangeReturn()
	{
		return ReadWithWorldContext(nullptr, 11) == 11;
	}
}
/** @end */
