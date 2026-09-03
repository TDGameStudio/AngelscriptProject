/**
 * Literal asset singleton identity: two getter calls return the same object, and
 * a write through one handle is visible through the other. C++ executes
 * TestSingletonIdentity and expects 1, so that name is part of the contract and
 * is kept verbatim. The observers cover the empty default and a fresh carrier
 * that is not the singleton.
 *
 * @Theme Feature.Asset
 * @Subject Asset.AssetSingletonBehavior
 * @Harness UClass
 * @Tag Feature.Asset.AssetSingletonBehavior
 * @Provenance Theme: Feature.Asset. Value oracle for literal asset singleton identity.
 * @Provenance C++: AngelscriptCoverageLiteralAssetTests.cpp::AssetSingletonBehavior ExpectGlobalInt 1.
 * @Provenance CSV NegativeDiagnostic is the LogUObjectBase expected error; the script compiles and runs.
 * @Provenance Oracle: TestSingletonIdentity()==1 (same pointer; AccessCount 1 then 99).
 * @Provenance Extra: empty AccessCount==0; false identity when comparing a fresh carrier.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class USingletonAssetCarrier : UObject
{
	UPROPERTY()
	int AccessCount = 0;

	/**
	 * Confirm that two getter calls alias the same materialized asset.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetSingletonBehavior
	 * @Inputs two GetMySingletonAsset calls
	 * @Return 1 when both handles alias and a write of 99 is visible on both; otherwise 0
	 */
	UFUNCTION()
	int TestSingletonIdentity()
	{
		USingletonAssetCarrier First = GetMySingletonAsset();
		USingletonAssetCarrier Second = GetMySingletonAsset();

		if (First != Second)
		{
			return 0;
		}

		if (First.AccessCount != 1)
		{
			return 0;
		}

		First.AccessCount = 99;
		if (Second.AccessCount != 99)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a fresh carrier keeps the class default of 0.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetSingletonBehavior
	 * @Inputs a freshly constructed carrier
	 * @Return the class default AccessCount, which is 0
	 * @Boundary class default
	 */
	UFUNCTION()
	int EmptyDefault()
	{
		return AccessCount;
	}

	/**
	 * Observe that this freshly constructed carrier is not the singleton asset.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetSingletonBehavior
	 * @Inputs this carrier and the generated getter
	 * @Return true when this instance is distinct from the materialized asset
	 * @Boundary fresh instance identity
	 */
	UFUNCTION()
	bool FreshNotSameInstance()
	{
		USingletonAssetCarrier Asset = GetMySingletonAsset();
		if (Asset == nullptr)
		{
			return false;
		}
		return this != Asset;
	}
}

asset MySingletonAsset of USingletonAssetCarrier
{
	AccessCount = 1;
}
