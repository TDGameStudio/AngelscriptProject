/**
 * WorldContext, DefaultToSelf, HidePin, and AdvancedDisplay pin metadata.
 * CoveragePinMetaFunction returns RequiredValue + OptionalValue. A null
 * WorldContext is empty, OptionalValue 0 is the empty optional, and a
 * nullptr actor is the empty handle.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.UFunctionWorldContextAndPinMeta
 * @Harness UClass
 * @Tag Definitions.UFunction.UFunctionWorldContextAndPinMeta
 * @Provenance Theme: Definitions.UFunction. WorldStory WorldContext/DefaultToSelf/HidePin/AdvancedDisplay pin meta.
 * @Provenance C++: AngelscriptCoverageMetaSpecifierTests.cpp::UFunctionWorldContextAndPinMeta
 * @Provenance Oracle: CoveragePinMetaFunction returns RequiredValue + OptionalValue; pin metadata is C++ reflection-side.
 * @Provenance Extra: null WorldContext empty; OptionalValue 0; nullptr actor is the empty handle.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class ACoverageMetaPinMetaActor : AActor
{
	/**
	 * Instance method carrying WorldContext and pin metadata.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param WorldContextObject World context named by metadata
	 * @Param RequiredValue Required addend
	 * @Param OptionalValue AdvancedDisplay addend
	 * @Inputs WorldContextObject, RequiredValue, OptionalValue
	 * @Return RequiredValue + OptionalValue
	 */
	UFUNCTION(BlueprintCallable, meta = (
		WorldContext = "WorldContextObject",
		DefaultToSelf = "WorldContextObject",
		HidePin = "WorldContextObject",
		AdvancedDisplay = "OptionalValue"))
	int CoveragePinMetaFunction(UObject WorldContextObject, int RequiredValue, int OptionalValue)
	{
		return RequiredValue + OptionalValue;
	}

	/**
	 * Observe CoveragePinMetaFunction(nullptr, 5, 7).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs CoveragePinMetaFunction(nullptr, 5, 7)
	 * @Return true when the result is 12
	 */
	UFUNCTION()
	bool PinMetaFivePlusSeven()
	{
		return CoveragePinMetaFunction(nullptr, 5, 7) == 12;
	}

	/**
	 * Observe the zero empty sum.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs CoveragePinMetaFunction(nullptr, 0, 0)
	 * @Return true when the result is 0
	 * @Boundary zero values
	 */
	UFUNCTION()
	bool PinMetaZeroEmpty()
	{
		return CoveragePinMetaFunction(nullptr, 0, 0) == 0;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ACoverageMetaPinMetaActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageMetaPinMetaActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that locals passed into CoveragePinMetaFunction are not written.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs CoveragePinMetaFunction(nullptr, 5, 7) with locals 5 and 7
	 * @Return true when the locals stay 5 and 7 and the sum is 12
	 */
	UFUNCTION()
	bool PinMetaCopyIndependence()
	{
		int Required = 5;
		int Optional = 7;
		int Sum = CoveragePinMetaFunction(nullptr, Required, Optional);
		if (Required != 5)
		{
			return false;
		}
		if (Optional != 7)
		{
			return false;
		}
		return Sum == 12;
	}
}
