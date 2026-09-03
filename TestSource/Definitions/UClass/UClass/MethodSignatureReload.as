/**
 * Method-signature dependency reload source. Echo still returns the same
 * Payload handle; AddedValue defaults to 2.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.MethodSignatureReload
 * @Harness UClass
 * @Tag Definitions.UClass.MethodSignatureReload
 * @Provenance Theme: Definitions.UClass. Reload version pair 02 (payload layout change). Positive method-signature dependency.
 * @Provenance C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::MethodSignatureDependencyRetargetsParametersAndReturnValue ReloadSource.
 * @Provenance Oracle: Echo still returns the same Payload handle; AddedValue defaults to 2.
 * @Provenance Retained: Payload/SignatureUser types, Echo, Value. Replaced: Payload.AddedValue = 2.
 * @Provenance Extra: Echo(nullptr) stays nullptr; mutating AddedValue on one payload does not write the other.
 * @Provenance FixtureIsolated. Object handles are runner-owned when non-null.
 */

UCLASS()
class UClassGeneratorPropagationPayload : UObject
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;

	/**
	 * Observe the AddedValue default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed payload
	 * @Return AddedValue
	 */
	UFUNCTION()
	int AddedValueDefault()
	{
		return AddedValue;
	}

	/**
	 * Observe that writing AddedValue leaves another at 2.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other payload expected to stay at 2
	 * @Inputs this.AddedValue set to 0
	 * @Return true when Second.AddedValue is 2
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UClassGeneratorPropagationPayload Second)
	{
		if (Second is null)
		{
			throw("MethodSignatureReload setup: required Second is null");
		}
		AddedValue = 0;
		return Second.AddedValue == 2;
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
	 * Observe Echo of a live payload: identity is preserved after reload.
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
	 * Observe Echo(nullptr) after reload.
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
