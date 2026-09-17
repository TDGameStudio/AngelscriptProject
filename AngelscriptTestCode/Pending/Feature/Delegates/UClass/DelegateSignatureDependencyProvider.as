/**
 * @version v1
 * @summary HotReload version pair Before: the payload has Value only. The initial compile keeps Signal; the payload parameter targets this class. A later full reload adds AddedValue on the consumer version.
 * @topic Feature
 */
/**
 * @version root
 * @summary HotReload version pair Before: the payload has Value only. The initial compile keeps Signal; the payload parameter targets this class. A later full reload adds AddedValue on the consumer version.
 * @topic Baseline
 */
UCLASS()
class UClassGeneratorPropagationSignalPayload : UObject
{
	UPROPERTY()
	int Value = 1;

	/**
	 * Observe the default payload Value.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Reload
	 * @Inputs this
	 * @Return 1
	 * @Boundary default Value
	 */
	UFUNCTION()
	int DefaultValue()
	{
		return Value;
	}

	/**
	 * Observe assigning zero to Value.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Reload
	 * @Inputs Value = 0
	 * @Return 0
	 * @Boundary zero assignment
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		Value = 0;
		return Value;
	}
}

/**
 * A unicast whose parameter is the provider payload class.
 *
 * @Covers Delegates.Reload
 * @Inputs Payload
 * @Return nothing when executed
 */
delegate void FClassGeneratorPropagationSignal(UClassGeneratorPropagationSignalPayload Payload);

UCLASS()
class UClassGeneratorPropagationSignalOwner : UObject
{
	UPROPERTY()
	FClassGeneratorPropagationSignal Signal;

	/**
	 * Observe that Signal starts unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Reload
	 * @Inputs this
	 * @Return true when Signal is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool DefaultUnbound()
	{
		return !Signal.IsBound();
	}
}
/** @end */
