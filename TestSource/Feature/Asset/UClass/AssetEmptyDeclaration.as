/**
 * An empty literal asset block still materializes an instance that uses the
 * class defaults. C++ executes GetEmptyAssetDefaultValue and expects 123, so
 * that name is part of the contract and is kept verbatim. The observers cover
 * the class default on a fresh carrier and the independence of two carriers.
 *
 * @Theme Feature.Asset
 * @Subject Asset.AssetEmptyDeclaration
 * @Harness UClass
 * @Tag Feature.Asset.AssetEmptyDeclaration
 * @Provenance Theme: Feature.Asset. Value oracle for an empty literal asset block.
 * @Provenance C++: AngelscriptCoverageLiteralAssetTests.cpp::AssetEmptyDeclaration ExpectGlobalInt 123.
 * @Provenance CSV NegativeDiagnostic is the LogUObjectBase expected error; the script compiles and runs.
 * @Provenance Oracle: GetEmptyAssetDefaultValue()==123.
 * @Provenance Extra: empty carrier still 123; null getter path returns -1.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UEmptyAssetCarrier : UObject
{
	UPROPERTY()
	int DefaultValue = 123;

	/**
	 * Read the materialized empty asset's DefaultValue through the generated getter.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetEmptyDeclaration
	 * @Inputs the generated GetMyEmptyAsset getter
	 * @Return 123 when the asset is present, otherwise -1
	 */
	UFUNCTION()
	int GetEmptyAssetDefaultValue()
	{
		UEmptyAssetCarrier Asset = GetMyEmptyAsset();
		if (Asset == nullptr)
		{
			return -1;
		}
		return Asset.DefaultValue;
	}

	/**
	 * Observe that a fresh carrier keeps the class default of 123.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetEmptyDeclaration
	 * @Inputs a freshly constructed carrier
	 * @Return the class default DefaultValue, which is 123
	 * @Boundary class default
	 */
	UFUNCTION()
	int ClassDefault()
	{
		return DefaultValue;
	}

	/**
	 * Observe that writing another carrier leaves this instance at 123.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetEmptyDeclaration
	 * @Inputs this carrier plus a second carrier
	 * @Return true when this still holds 123 and the copy holds 0
	 * @Param Copy the other carrier, mutated independently
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UEmptyAssetCarrier Copy)
	{
		if (Copy is null)
		{
			throw("AssetEmptyDeclaration setup: required Copy is null");
		}
		Copy.DefaultValue = 0;

		if (DefaultValue != 123)
		{
			return false;
		}
		return Copy.DefaultValue == 0;
	}
}

asset MyEmptyAsset of UEmptyAssetCarrier
{
}
