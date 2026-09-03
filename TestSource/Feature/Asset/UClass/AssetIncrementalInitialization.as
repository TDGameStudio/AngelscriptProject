/**
 * Incremental += assignments inside a literal asset block accumulate on the
 * class default. C++ executes GetIncrementalCounter and expects 60, so that
 * name is part of the contract and is kept verbatim. The observers cover the
 * empty default and the independence of two carriers.
 *
 * @Theme Feature.Asset
 * @Subject Asset.AssetIncrementalInitialization
 * @Harness UClass
 * @Tag Feature.Asset.AssetIncrementalInitialization
 * @Provenance Theme: Feature.Asset. Value oracle for incremental += in an asset block.
 * @Provenance C++: AngelscriptCoverageLiteralAssetTests.cpp::AssetIncrementalInitialization ExpectGlobalInt 60.
 * @Provenance CSV NegativeDiagnostic is the LogUObjectBase expected error; the script compiles and runs.
 * @Provenance Oracle: GetIncrementalCounter()==60.
 * @Provenance Extra: empty Counter==0; copy independence after mutating a carrier.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UIncrementalAssetCarrier : UObject
{
	UPROPERTY()
	int Counter = 0;

	/**
	 * Read the materialized asset's Counter through the generated getter.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetIncrementalInitialization
	 * @Inputs the generated GetMyIncrementalAsset getter
	 * @Return 60 when the asset is present, otherwise -1
	 */
	UFUNCTION()
	int GetIncrementalCounter()
	{
		UIncrementalAssetCarrier Asset = GetMyIncrementalAsset();
		if (Asset == nullptr)
		{
			return -1;
		}
		return Asset.Counter;
	}

	/**
	 * Observe that a fresh carrier keeps the class default of 0.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetIncrementalInitialization
	 * @Inputs a freshly constructed carrier
	 * @Return the class default Counter, which is 0
	 * @Boundary class default
	 */
	UFUNCTION()
	int EmptyDefault()
	{
		return Counter;
	}

	/**
	 * Observe that incrementing another carrier leaves this instance at 0.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetIncrementalInitialization
	 * @Inputs this carrier plus a second carrier
	 * @Return true when this still holds 0 and the copy holds 4
	 * @Param Copy the other carrier, mutated independently
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UIncrementalAssetCarrier Copy)
	{
		if (Copy is null)
		{
			throw("AssetIncrementalInitialization setup: required Copy is null");
		}
		Copy.Counter += 4;

		if (Counter != 0)
		{
			return false;
		}
		return Copy.Counter == 4;
	}
}

asset MyIncrementalAsset of UIncrementalAssetCarrier
{
	Counter += 10;
	Counter += 20;
	Counter += 30;
}
