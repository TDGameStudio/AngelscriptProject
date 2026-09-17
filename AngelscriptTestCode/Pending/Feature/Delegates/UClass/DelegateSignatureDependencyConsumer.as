/**
 * @version v1
 * @summary HotReload version pair After: the payload adds AddedValue. After a full reload, Payload and Owner exist, Signal is kept, and the Payload parameter retargets the reloaded class.
 * @topic Feature
 */
/**
 * @version root
 * @summary HotReload version pair After: the payload adds AddedValue. After a full reload, Payload and Owner exist, Signal is kept, and the Payload parameter retargets the reloaded class.
 * @topic Baseline
 */
UCLASS()
class UClassGeneratorPropagationSignalPayload : UObject
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;

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
	 * Observe the default AddedValue.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Reload
	 * @Inputs this
	 * @Return 2
	 * @Boundary default AddedValue
	 */
	UFUNCTION()
	int DefaultAddedValue()
	{
		return AddedValue;
	}

	/**
	 * Observe that zeroing this leaves Second at its defaults.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Reload
	 * @Param Second the other payload, runner-owned when non-null
	 * @Inputs Value and AddedValue set to 0 on this
	 * @Return true when this is zeros and Second stays 1 and 2
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ZeroAndIndependence(UClassGeneratorPropagationSignalPayload Second)
	{
		if (Second is null)
		{
			throw("DelegateSignatureDependencyConsumer setup: required Second is null");
		}
		Value = 0;
		AddedValue = 0;
		if (Value != 0)
		{
			return false;
		}
		if (AddedValue != 0)
		{
			return false;
		}
		if (Second.Value != 1)
		{
			return false;
		}
		return Second.AddedValue == 2;
	}
}

/**
 * A unicast whose parameter retargets the reloaded payload class.
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
}
/** @end */
