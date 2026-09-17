/**
 * @version v1
 * @summary Observe FAssetBundleEntry construction from a bundle name.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FAssetBundleEntry construction from a bundle name.
 * @topic Baseline
 */
// default-constructed FAssetBundleEntry as the empty state.
// Expected observations: Named construction stores BundleName n"Bundle".
// NAME_None and default construction produce an entry whose name is none.
// Boundary/ownership: Construction copies the interned FName. The entry does
// not own assets until paths are added on FAssetBundleData.

namespace TS_AssetBundleData_Behavior_01
{
	bool Observe_Entry_Nominal()
	{
		FAssetBundleEntry Entry(n"Bundle");
		FAssetBundleEntry NoneEntry(NAME_None);
		FAssetBundleEntry DefaultEntry;
		return Entry.BundleName == n"Bundle" &&
			Entry.AssetPaths.Num() == 0 &&
			NoneEntry.BundleName == NAME_None &&
			DefaultEntry.BundleName == NAME_None;
	}
}
/** @end */
