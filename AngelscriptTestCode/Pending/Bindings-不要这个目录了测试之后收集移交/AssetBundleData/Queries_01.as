/**
 * @version v1
 * @summary Observe FAssetBundleData.FindEntry copy-out for a matching bundle and a missing bundle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FAssetBundleData.FindEntry copy-out for a matching bundle and a missing bundle.
 * @topic Baseline
 */
// FAssetBundleEntry&out OutEntry) const;
// Inputs: Default-empty FAssetBundleData, bundle n"Bundle" seeded with
// FTopLevelAssetPath(n"/Game/Test", n"Asset"), lookup n"Bundle", missing
// n"Missing", and NAME_None.
// Expected observations: Empty data returns false and leaves OutEntry
// unchanged. A matching name returns true and writes an independent copy
// whose BundleName is n"Bundle". Missing and NAME_None lookups return false.
// Boundary/ownership: OutEntry receives a safe copy; mutating it does not
// change the receiver. FindEntry does not transfer ownership of bundle data.

namespace TS_AssetBundleData_Queries_01
{
	bool Observe_FindEntry_Nominal()
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
}
/** @end */
