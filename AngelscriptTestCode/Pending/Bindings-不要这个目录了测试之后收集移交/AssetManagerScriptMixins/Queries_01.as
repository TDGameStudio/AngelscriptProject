/**
 * @version v1
 * @summary Observe UAssetManager mixin lookups for already-scanned primary asset metadata and the resident primary asset object.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe UAssetManager mixin lookups for already-scanned primary asset metadata and the resident primary asset object.
 * @topic Baseline
 */
// FAssetData&out Data);
// UObject AssetManager.GetPrimaryAssetObject(const FPrimaryAssetId& Id);
// Inputs: UAssetManager::Get() as the live receiver, a default-invalid
// FPrimaryAssetId, and FPrimaryAssetId("MissingType:MissingName") as a
// negative lookup key.
// Expected observations: Missing and invalid ids return false from
// GetPrimaryAssetData and leave Data invalid. GetPrimaryAssetObject returns
// null when the asset is not resident.
// Boundary/ownership: Data is a writeback copy of scanned metadata. The
// returned UObject is borrowed; a null result does not create an object.
// A null manager is setup failure.

namespace TS_AssetManagerScriptMixins_Queries_01
{
	bool Observe_GetPrimaryAssetData_Nominal()
	{
		UAssetManager AssetManager = UAssetManager::Get();
		if (AssetManager is null)
		{
			throw("TS_AssetManagerScriptMixins_Queries_01 setup: required AssetManager is null");
		}

		FAssetData InvalidOut;
		FString InvalidOutBefore = InvalidOut.GetObjectPathString();
		FPrimaryAssetId InvalidId;
		bool bInvalidFound = AssetManager.GetPrimaryAssetData(InvalidId, InvalidOut);
		bool bInvalidLookupFails = !bInvalidFound && InvalidOut.GetObjectPathString().IsEmpty() && InvalidOutBefore.IsEmpty();

		FAssetData MissingOut;
		FName MissingOutBefore = MissingOut.AssetName;
		FPrimaryAssetId MissingId("MissingType:MissingName");
		bool bMissingFound = AssetManager.GetPrimaryAssetData(MissingId, MissingOut);
		bool bMissingLookupFails = !bMissingFound && MissingOut.AssetName == MissingOutBefore;

		return bInvalidLookupFails && bMissingLookupFails;
	}

	bool Observe_GetPrimaryAssetObject_Nominal()
	{
		UAssetManager AssetManager = UAssetManager::Get();
		if (AssetManager is null)
		{
			throw("TS_AssetManagerScriptMixins_Queries_01 setup: required AssetManager is null");
		}
		FPrimaryAssetId InvalidId;
		UObject InvalidObject = AssetManager.GetPrimaryAssetObject(InvalidId);

		FPrimaryAssetId MissingId("MissingType:MissingName");
		UObject MissingObject = AssetManager.GetPrimaryAssetObject(MissingId);

		return InvalidObject is null && MissingObject is null;
	}
}
/** @end */
