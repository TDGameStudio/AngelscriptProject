/**
 * @version v1
 * @summary Copy assignment copies the path; resetting the source leaves the dest unchanged.
 * @topic Containers
 * AssignCopyIndependent
 */
/**
 * @begin AssignCopyIndependent
 * @summary Copy assignment copies the path; resetting the source leaves the dest unchanged.
 * @topic Containers
 */
bool AssignCopyIndependent()
{
	FSoftObjectPath Path("/Game/AngelscriptTest/PackageA.AssetA");
	TSoftObjectPtr<UObject> Source;
	Source = Path;

	TSoftObjectPtr<UObject> Dest;
	Dest = Source;
	if (Dest != Source)
	{
		return false;
	}

	Source.Reset();
	return Dest.ToSoftObjectPath() == Path && Source.IsNull();
}
/** @end */
