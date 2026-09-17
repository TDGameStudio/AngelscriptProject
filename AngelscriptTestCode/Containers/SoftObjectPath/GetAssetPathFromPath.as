/**
 * @version v1
 * @summary Empty paths have null asset paths; live object and class paths have valid asset paths.
 * @topic Containers
 *
 * GetAssetPathFromPath
 */
/**
 * @begin GetAssetPathFromPath
 * @summary Empty paths have null asset paths; live object and class paths have valid asset paths.
 * @topic Containers
 */
bool GetAssetPathFromPath()
{
	FSoftObjectPath Empty;
	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("GetAssetPathFromPath setup: required Actor CDO is null");
	}
	FSoftObjectPath ObjectPath(LiveCdo);
	FSoftClassPath EmptyClass;
	FSoftClassPath ClassPath(AActor::StaticClass());
	return Empty.GetAssetPath().IsNull() && ObjectPath.GetAssetPath().IsValid() && EmptyClass.GetAssetPath().IsNull() && ClassPath.GetAssetPath().IsValid();
}
/** @end */
