/**
 * @version v1
 * @summary Empty paths have empty package names; live object and class paths have nonempty package names.
 * @topic Containers
 *
 * GetLongPackageNameFromPath
 */
/**
 * @begin GetLongPackageNameFromPath
 * @summary Empty paths have empty package names; live object and class paths have nonempty package names.
 * @topic Containers
 */
bool GetLongPackageNameFromPath()
{
	FSoftObjectPath Empty;
	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("GetLongPackageNameFromPath setup: required Actor CDO is null");
	}
	FSoftObjectPath ObjectPath(LiveCdo);
	FSoftClassPath EmptyClass;
	FSoftClassPath ClassPath(AActor::StaticClass());
	return Empty.GetLongPackageName().IsEmpty() && ObjectPath.GetLongPackageName().Len() > 0 && EmptyClass.GetLongPackageName().IsEmpty() && ClassPath.GetLongPackageName().Len() > 0;
}
/** @end */
