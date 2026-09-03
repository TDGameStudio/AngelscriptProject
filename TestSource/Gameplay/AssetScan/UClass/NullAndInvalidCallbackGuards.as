/**
 * Two scan-receiver classes: one exposes OnScanComplete, the other exposes a different
 * function that is not the scan callback. C++ compiles both then exercises valid versus
 * missing callback names, so the UCLASS, UFUNCTION and UPROPERTY names are part of the
 * contract and are kept verbatim. The observers cover the empty CallbackCount default.
 *
 * @Theme Gameplay.AssetScan
 * @Subject AssetScan.NullAndInvalidCallbackGuards
 * @Harness UClass
 * @Tag Gameplay.AssetScan.NullAndInvalidCallbackGuards
 * @Provenance Theme: Gameplay.AssetScan. C++ compiles both receiver classes then exercises
 * @Provenance valid vs missing callback names. CSV NegativeDiagnostic is the C++ guard path,
 * @Provenance not a compile-fail of these declarations.
 * @Provenance C++: AngelscriptAssetManagerFunctionLibraryTests.cpp::NullAndInvalidCallbackGuards
 * @Provenance Oracle: CallbackCount stays 0 until OnScanComplete; DifferentFunction is not
 * @Provenance the scan callback. Extra: default CallbackCount is 0. FixtureIsolated.
 */

UCLASS()
class UAssetManagerValidScanReceiver : UObject
{
	UPROPERTY()
	int CallbackCount;

	/**
	 * Increment CallbackCount as the valid scan callback.
	 *
	 * @Kind Action
	 * @Covers Assets.NullAndInvalidCallbackGuards
	 * @Inputs none
	 * @Return CallbackCount increased by one
	 */
	UFUNCTION()
	void OnScanComplete()
	{
		CallbackCount += 1;
	}

	/**
	 * Observe that an untouched valid receiver starts at zero.
	 *
	 * @Kind Observe
	 * @Covers Assets.NullAndInvalidCallbackGuards
	 * @Inputs none
	 * @Return true when CallbackCount is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return CallbackCount == 0;
	}

	/**
	 * Observe that calling OnScanComplete increments the count.
	 *
	 * @Kind Observe
	 * @Covers Assets.NullAndInvalidCallbackGuards
	 * @Inputs none
	 * @Return true when CallbackCount is 1
	 */
	UFUNCTION()
	bool OnScanCompleteIncrements()
	{
		OnScanComplete();
		return CallbackCount == 1;
	}
}

UCLASS()
class UAssetManagerMissingScanReceiver : UObject
{
	UPROPERTY()
	int CallbackCount;

	/**
	 * Increment CallbackCount from a function that is not the scan callback.
	 *
	 * @Kind Action
	 * @Covers Assets.NullAndInvalidCallbackGuards
	 * @Inputs none
	 * @Return CallbackCount increased by one
	 */
	UFUNCTION()
	void DifferentFunction()
	{
		CallbackCount += 1;
	}

	/**
	 * Observe that an untouched missing-callback receiver starts at zero.
	 *
	 * @Kind Observe
	 * @Covers Assets.NullAndInvalidCallbackGuards
	 * @Inputs none
	 * @Return true when CallbackCount is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return CallbackCount == 0;
	}

	/**
	 * Observe that calling DifferentFunction directly still increments the count.
	 *
	 * @Kind Observe
	 * @Covers Assets.NullAndInvalidCallbackGuards
	 * @Inputs none
	 * @Return true when CallbackCount is 1
	 */
	UFUNCTION()
	bool DifferentFunctionDirectCall()
	{
		DifferentFunction();
		return CallbackCount == 1;
	}
}
