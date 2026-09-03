/**
 * HotReload version pair After: the payload adds AddedValue. After a full
 * reload, Payload and Owner exist, Signal is kept, and the Payload parameter
 * retargets the reloaded class.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateSignatureDependencyConsumer
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateSignatureDependencyConsumer
 * @Provenance Theme: Feature.Delegates. HotReload version pair After (payload adds AddedValue).
 * @Provenance C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::DelegateSignatureDependencyRetargetsParameterType
 * @Provenance sha256 from theme-refs TS-FEAT-0248; lines 601-620.
 * @Provenance Oracle after full reload: Payload and Owner classes exist; Signal kept; Payload param
 * @Provenance retargets the reloaded class. Retained: Value and Signal. Replaced: layout now includes
 * @Provenance AddedValue==2. Extra: zeros; two locals independent. DefaultSafe.
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
