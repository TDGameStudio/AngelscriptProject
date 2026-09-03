/**
 * Literal asset property initialization: an int and an FString written in the
 * asset block are visible through the generated getter. C++ executes GetAssetValue
 * and CheckAssetName, so those names are part of the contract and are kept
 * verbatim. The observers cover the empty defaults and the independence of two
 * carriers.
 *
 * @Theme Feature.Asset
 * @Subject Asset.AssetDeclarationBasics
 * @Harness UClass
 * @Tag Feature.Asset.AssetDeclarationBasics
 * @Provenance Theme: Feature.Asset. Value oracle for literal asset property initialization.
 * @Provenance C++: AngelscriptCoverageLiteralAssetTests.cpp::AssetDeclarationBasics ExpectGlobalInt.
 * @Provenance CSV NegativeDiagnostic is the LogUObjectBase expected error; the script compiles and runs.
 * @Provenance Oracle: GetAssetValue()==42; CheckAssetName()==1.
 * @Provenance Extra: empty carrier Value==0 / Name empty; copy independence.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UBasicAssetCarrier : UObject
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	FString Name;

	/**
	 * Read the materialized asset's Value through the generated getter.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetDeclarationBasics
	 * @Inputs the generated GetMyBasicAsset getter
	 * @Return 42 when the asset is present, otherwise -1
	 */
	UFUNCTION()
	int GetAssetValue()
	{
		UBasicAssetCarrier Asset = GetMyBasicAsset();
		if (Asset == nullptr)
		{
			return -1;
		}
		return Asset.Value;
	}

	/**
	 * Read the materialized asset's Name through the generated getter.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetDeclarationBasics
	 * @Inputs the generated GetMyBasicAsset getter
	 * @Return 1 when the name is TestAsset, otherwise 0
	 */
	UFUNCTION()
	int CheckAssetName()
	{
		UBasicAssetCarrier Asset = GetMyBasicAsset();
		if (Asset == nullptr)
		{
			return 0;
		}
		if (Asset.Name != "TestAsset")
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a fresh carrier keeps the integer class default.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetDeclarationBasics
	 * @Inputs a freshly constructed carrier
	 * @Return the class default Value, which is 0
	 * @Boundary class default
	 */
	UFUNCTION()
	int EmptyCarrierDefault()
	{
		return Value;
	}

	/**
	 * Observe that a fresh carrier keeps the empty name default.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetDeclarationBasics
	 * @Inputs a freshly constructed carrier
	 * @Return the class default Name, which is empty
	 * @Boundary class default
	 */
	UFUNCTION()
	FString EmptyNameDefault()
	{
		return Name;
	}

	/**
	 * Observe that writing another carrier leaves this instance at its defaults.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetDeclarationBasics
	 * @Inputs this carrier plus a second carrier
	 * @Return true when this still holds the defaults and the copy holds the written values
	 * @Param Copy the other carrier, mutated independently
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UBasicAssetCarrier Copy)
	{
		if (Copy is null)
		{
			throw("AssetDeclarationBasics setup: required Copy is null");
		}
		Copy.Value = 7;
		Copy.Name = "Mutated";

		if (Value != 0)
		{
			return false;
		}
		if (!Name.IsEmpty())
		{
			return false;
		}
		if (Copy.Value != 7)
		{
			return false;
		}
		return Copy.Name == "Mutated";
	}
}

asset MyBasicAsset of UBasicAssetCarrier
{
	Value = 42;
	Name = "TestAsset";
}
