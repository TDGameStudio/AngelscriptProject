/**
 * Method-signature dependency initial source. Echo returns the same Payload
 * handle; Payload.Value defaults to 1.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.MethodSignatureInitial
 * @Harness UClass
 * @Tag Definitions.UClass.MethodSignatureInitial
 * @Provenance Theme: Definitions.UClass. Reload version pair 01 (initial). Positive method-signature dependency.
 * @Provenance C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::MethodSignatureDependencyRetargetsParametersAndReturnValue InitialSource.
 * @Provenance Oracle: Echo returns the same Payload handle; Payload.Value defaults to 1.
 * @Provenance Retained after reload: Payload/SignatureUser types and Echo. Replaced in 02: Payload.AddedValue.
 * @Provenance Extra: Echo(nullptr) stays nullptr; mutating the echoed payload does not write a second payload.
 * @Provenance FixtureIsolated. Object handles are runner-owned when non-null.
 */

UCLASS()
class UClassGeneratorPropagationPayload : UObject
{
	UPROPERTY()
	int Value = 1;

	/**
	 * Observe the Payload.Value default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed payload
	 * @Return Value
	 */
	UFUNCTION()
	int ValueDefault()
	{
		return Value;
	}

	/**
	 * Observe that writing this payload leaves another at 1.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other payload expected to stay at 1
	 * @Inputs this.Value set to 0
	 * @Return true when Second.Value is 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UClassGeneratorPropagationPayload Second)
	{
		if (Second is null)
		{
			throw("MethodSignatureInitial setup: required Second is null");
		}
		Value = 0;
		return Second.Value == 1;
	}
}

UCLASS()
class UClassGeneratorPropagationSignatureUser : UObject
{
	/**
	 * Observe Echo: it returns the same Payload handle.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Payload Handle echoed back
	 * @Inputs Payload
	 * @Return Payload
	 */
	UFUNCTION()
	UClassGeneratorPropagationPayload Echo(UClassGeneratorPropagationPayload Payload)
	{
		return Payload;
	}

	/**
	 * Observe Echo of a live payload: identity is preserved.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Payload Handle to echo
	 * @Inputs Echo(Payload)
	 * @Return the echoed handle
	 */
	UFUNCTION()
	UClassGeneratorPropagationPayload EchoIdentity(UClassGeneratorPropagationPayload Payload)
	{
		return Echo(Payload);
	}

	/**
	 * Observe Echo(nullptr).
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs Echo(nullptr)
	 * @Return nullptr
	 * @Boundary null payload
	 */
	UFUNCTION()
	UClassGeneratorPropagationPayload EchoNullDefault()
	{
		return Echo(nullptr);
	}
}
