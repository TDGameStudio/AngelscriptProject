/**
 * HotReload version pair Before: the payload has Value only. The initial
 * compile keeps Signal; the payload parameter targets this class. A later
 * full reload adds AddedValue on the consumer version.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateSignatureDependencyProvider
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateSignatureDependencyProvider
 * @Provenance Theme: Feature.Delegates. HotReload version pair Before (payload Value only).
 * @Provenance C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::DelegateSignatureDependencyRetargetsParameterType
 * @Provenance sha256 from theme-refs TS-FEAT-0247; lines 583-599.
 * @Provenance Oracle: initial compile; Signal property exists; Payload param targets this class.
 * @Provenance Retained after reload: FClassGeneratorPropagationSignal and owner Signal.
 * @Provenance Replaced later: payload layout gains AddedValue (full reload). Extra: Value default 1;
 * @Provenance zero assignment; two payload locals independent. DefaultSafe.
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
