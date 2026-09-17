/**
 * @version v1
 * @summary AssetBundleData host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic AssetBundleData
 *
 * entry
 * add-bundle-asset
 * set-bundle-assets
 * find-entry
 */
/**
 * @begin entry
 * @summary not own assets until paths are added on FAssetBundleData.
 * @topic Unreal
 */
/**
 * @function ObserveEntryNominal
 * @summary not own assets until paths are added on FAssetBundleData.
 * @covers AssetBundleData.entry
 * @inputs AssetBundleData values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEntryNominal()
{
	FAssetBundleEntry Entry(n"Bundle");
	FAssetBundleEntry NoneEntry(NAME_None);
	FAssetBundleEntry DefaultEntry;
	return Entry.BundleName == n"Bundle" &&
		Entry.AssetPaths.Num() == 0 &&
		NoneEntry.BundleName == NAME_None &&
		DefaultEntry.BundleName == NAME_None;
}
/** @end */
/**
 * @begin add-bundle-asset
 * @summary source TArray.
 * @topic Unreal
 */
/**
 * @function ObserveAddBundleAssetNominal
 * @summary source TArray.
 * @covers AssetBundleData.add-bundle-asset
 * @inputs AssetBundleData values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddBundleAssetNominal()
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
/** @end */
/**
 * @begin set-bundle-assets
 * @summary source TArray.
 * @topic Unreal
 */
/**
 * @function ObserveSetBundleAssetsNominal
 * @summary source TArray.
 * @covers AssetBundleData.set-bundle-assets
 * @inputs AssetBundleData values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetBundleAssetsNominal()
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
/** @end */
/**
 * @begin find-entry
 * @summary change the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveFindEntryNominal
 * @summary change the receiver.
 * @covers AssetBundleData.find-entry
 * @inputs AssetBundleData values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFindEntryNominal()
{
	FAssetBundleData Empty;
	FAssetBundleEntry EmptyOut;
	FName EmptyOutBefore = EmptyOut.BundleName;
	bool bEmptyFound = Empty.FindEntry(n"Bundle", EmptyOut);
	bool bEmptyUnchanged = EmptyOut.BundleName == EmptyOutBefore;

	FAssetBundleData Data;
	FTopLevelAssetPath AssetPath(n"/Game/Test", n"Asset");
	Data.AddBundleAsset(n"Bundle", AssetPath);

	FAssetBundleEntry OutEntry;
	FName OutBefore = OutEntry.BundleName;
	bool bFound = Data.FindEntry(n"Bundle", OutEntry);
	bool bCopyWroteBundle = bFound && OutEntry.BundleName == n"Bundle";
	bool bOutChangedFromDefault = OutEntry.BundleName != OutBefore;

	FName CopiedName = OutEntry.BundleName;
	OutEntry.BundleName = n"Mutated";
	FAssetBundleEntry Second;
	bool bFoundAgain = Data.FindEntry(n"Bundle", Second);
	bool bCopyIndependent = bFoundAgain && Second.BundleName == n"Bundle" && CopiedName == n"Bundle";

	FAssetBundleEntry MissingOut;
	FName MissingBefore = MissingOut.BundleName;
	bool bMissingFound = Data.FindEntry(n"Missing", MissingOut);
	bool bMissingUnchanged = !bMissingFound && MissingOut.BundleName == MissingBefore;

	FAssetBundleEntry NoneOut;
	bool bNoneFound = Data.FindEntry(NAME_None, NoneOut);

	return !bEmptyFound &&
		bEmptyUnchanged &&
		bCopyWroteBundle &&
		bOutChangedFromDefault &&
		bCopyIndependent &&
		bMissingUnchanged &&
		!bNoneFound;
}
/** @end */
