/**
 * @version v1
 * @summary Empty paths have empty asset names; live object and class paths have nonempty asset names.
 * @topic Containers
 *
 * GetAssetNameFromPath
 */
/**
 * @begin GetAssetNameFromPath
 * @summary Empty paths have empty asset names; live object and class paths have nonempty asset names.
 * @topic Containers
 */
bool GetAssetNameFromPath()
{
	FSoftObjectPath Empty;
	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("GetAssetNameFromPath setup: required Actor CDO is null");
	}
	FSoftObjectPath ObjectPath(LiveCdo);
	FSoftClassPath EmptyClass;
	FSoftClassPath ClassPath(AActor::StaticClass());
	return Empty.GetAssetName().IsEmpty() && ObjectPath.GetAssetName().Len() > 0 && EmptyClass.GetAssetName().IsEmpty() && ClassPath.GetAssetName().Len() > 0;
}
/** @end */
