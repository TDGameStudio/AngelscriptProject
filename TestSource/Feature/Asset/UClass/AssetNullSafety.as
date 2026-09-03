/**
 * A successfully compiled literal asset getter is never null and still exposes
 * the class default. C++ executes TestAssetNullCheck and expects 1, so that
 * name is part of the contract and is kept verbatim. The observers cover the
 * empty default, an explicit null handle, and the independence of two carriers.
 *
 * @Theme Feature.Asset
 * @Subject Asset.AssetNullSafety
 * @Harness UClass
 * @Tag Feature.Asset.AssetNullSafety
 * @Provenance Theme: Feature.Asset. Value oracle: a compiled asset getter is not null.
 * @Provenance C++: AngelscriptCoverageLiteralAssetTests.cpp::AssetNullSafety ExpectGlobalInt 1.
 * @Provenance CSV NegativeDiagnostic is the LogUObjectBase expected error; the script compiles and runs.
 * @Provenance Oracle: TestAssetNullCheck()==1 (non-null, Value==777).
 * @Provenance Extra: empty Value==777 class default; explicit null boundary.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UNullSafeAssetCarrier : UObject
{
	UPROPERTY()
	int Value = 777;

	/**
	 * Read the materialized asset and confirm the getter is non-null.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetNullSafety
	 * @Inputs the generated GetMyNullSafeAsset getter
	 * @Return 1 when the asset is non-null and Value is 777; otherwise 0
	 */
	UFUNCTION()
	int TestAssetNullCheck()
	{
		UNullSafeAssetCarrier Asset = GetMyNullSafeAsset();

		if (Asset == nullptr)
		{
			return 0;
		}

		if (Asset.Value != 777)
		{
			return 0;
		}

		return 1;
	}

	/**
	 * Observe that a fresh carrier keeps the class default of 777.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetNullSafety
	 * @Inputs a freshly constructed carrier
	 * @Return the class default Value, which is 777
	 * @Boundary class default
	 */
	UFUNCTION()
	int EmptyDefault()
	{
		return Value;
	}

	/**
	 * Observe that an explicit null handle compares equal to null.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetNullSafety
	 * @Inputs a null carrier handle
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullBoundary()
	{
		UNullSafeAssetCarrier Asset = nullptr;
		return Asset == nullptr;
	}

	/**
	 * Observe that writing another carrier leaves this instance at 777.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetNullSafety
	 * @Inputs this carrier plus a second carrier
	 * @Return true when this still holds 777 and the copy holds 0
	 * @Param Copy the other carrier, mutated independently
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UNullSafeAssetCarrier Copy)
	{
		if (Copy is null)
		{
			throw("AssetNullSafety setup: required Copy is null");
		}
		Copy.Value = 0;

		if (Value != 777)
		{
			return false;
		}
		return Copy.Value == 0;
	}
}

asset MyNullSafeAsset of UNullSafeAssetCarrier
{
}
