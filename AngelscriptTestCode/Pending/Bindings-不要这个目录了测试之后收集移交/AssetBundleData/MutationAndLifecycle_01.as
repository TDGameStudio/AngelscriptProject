/**
 * @version v1
 * @summary Observe AddBundleAsset append and SetBundleAssets replacement on FAssetBundleData.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe AddBundleAsset append and SetBundleAssets replacement on FAssetBundleData.
 * @topic Baseline
 */
// const FTopLevelAssetPath& AssetPath);
// void FAssetBundleData.SetBundleAssets(FName BundleName,
// const TArray<FTopLevelAssetPath>& Paths);
// Inputs: Seeded receiver, n"Bundle", FTopLevelAssetPath(n"/Game/Test", n"Asset")
// then n"Other", a repeated Add of the same path, replacement array of two
// paths, and an empty Paths array as cleanup.
// Expected observations: After Add, FindEntry(n"Bundle") is true. A second Add
// still finds the bundle. SetBundleAssets replaces the stored paths. Setting
// empty Paths leaves a named entry that can still be queried.
// Boundary/ownership: Paths are copied into bundle data. The caller keeps the
// source TArray. BundleName is an interned FName, not a retained string.

namespace TS_AssetBundleData_MutationAndLifecycle_01
{
	bool Observe_AddBundleAsset_Nominal()
	{
		FAssetBundleData Data;
		FTopLevelAssetPath AssetPath(n"/Game/Test", n"Asset");
		FAssetBundleEntry Before;
		bool bBeforeFound = Data.FindEntry(n"Bundle", Before);

		Data.AddBundleAsset(n"Bundle", AssetPath);
		FAssetBundleEntry AfterFirst;
		bool bAfterFirst = Data.FindEntry(n"Bundle", AfterFirst);

		Data.AddBundleAsset(n"Bundle", AssetPath);
		FAssetBundleEntry AfterRepeat;
		bool bAfterRepeat = Data.FindEntry(n"Bundle", AfterRepeat);

		FTopLevelAssetPath OtherPath(n"/Game/Test", n"Other");
		Data.AddBundleAsset(n"OtherBundle", OtherPath);
		FAssetBundleEntry OtherEntry;
		bool bOtherFound = Data.FindEntry(n"OtherBundle", OtherEntry);

		return !bBeforeFound &&
			bAfterFirst &&
			AfterFirst.BundleName == n"Bundle" &&
			AfterFirst.AssetPaths.Num() >= 1 &&
			bAfterRepeat &&
			AfterRepeat.BundleName == n"Bundle" &&
			bOtherFound &&
			OtherEntry.BundleName == n"OtherBundle";
	}

	bool Observe_SetBundleAssets_Nominal()
	{
		FAssetBundleData Data;
		FTopLevelAssetPath First(n"/Game/Test", n"A");
		Data.AddBundleAsset(n"Bundle", First);

		TArray<FTopLevelAssetPath> Paths;
		Paths.Add(FTopLevelAssetPath(n"/Game/Test", n"A"));
		Paths.Add(FTopLevelAssetPath(n"/Game/Test", n"B"));
		Data.SetBundleAssets(n"Bundle", Paths);

		FAssetBundleEntry Replaced;
		bool bReplacedFound = Data.FindEntry(n"Bundle", Replaced);
		int32 ReplacedCount = Replaced.AssetPaths.Num();

		TArray<FTopLevelAssetPath> EmptyPaths;
		Data.SetBundleAssets(n"Bundle", EmptyPaths);
		FAssetBundleEntry Cleared;
		bool bClearedFound = Data.FindEntry(n"Bundle", Cleared);
		int32 ClearedCount = Cleared.AssetPaths.Num();

		Data.SetBundleAssets(n"Bundle", EmptyPaths);
		FAssetBundleEntry Repeated;
		bool bRepeatedFound = Data.FindEntry(n"Bundle", Repeated);

		return bReplacedFound &&
			Replaced.BundleName == n"Bundle" &&
			ReplacedCount == 2 &&
			bClearedFound &&
			Cleared.BundleName == n"Bundle" &&
			ClearedCount == 0 &&
			bRepeatedFound &&
			Repeated.BundleName == n"Bundle";
	}
}
/** @end */
