/**
 * @version v1
 * @summary UPackage host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic UPackage
 *
 * is-dirty
 */
/**
 * @begin is-dirty
 * @summary is borrowed from the engine.
 * @topic Unreal
 */
/**
 * @function ObserveIsDirtyNominal
 * @summary is borrowed from the engine.
 * @covers UPackage.is-dirty
 * @inputs UPackage values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsDirtyNominal(UPackage Package, UObject Marker)
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
/** @end */
