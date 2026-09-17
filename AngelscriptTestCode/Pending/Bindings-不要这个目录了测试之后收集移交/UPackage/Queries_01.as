/**
 * @version v1
 * @summary Observe UPackage.IsDirty for a runner-owned package after MarkPackageDirty.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe UPackage.IsDirty for a runner-owned package after MarkPackageDirty.
 * @topic Baseline
 */
// MarkPackageDirty sets the dirty flag.
// Expected observations: After MarkPackageDirty, IsDirty is true and a
// repeated IsDirty matches that state.
// Boundary/ownership: IsDirty does not mutate the package. The package handle
// is borrowed from the engine. SetupOwner=Runner.

namespace TS_UPackage_Queries_01
{
	bool Observe_IsDirty_Nominal(UPackage Package, UObject Marker)
	{
		if (Package is null)
		{
			throw("TS_UPackage_Queries_01 setup: required Package is null");
		}
		if (Marker is null)
		{
			throw("TS_UPackage_Queries_01 setup: required Marker is null");
		}
		Marker.MarkPackageDirty();
		bool bAfterDirty = Package.IsDirty();
		bool bRepeat = Package.IsDirty();
		return bAfterDirty && bRepeat == bAfterDirty;
	}
}
/** @end */
