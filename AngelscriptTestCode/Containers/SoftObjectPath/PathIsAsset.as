/**
 * @version v1
 * @summary A live CDO path is an asset; a subobject path and an empty path are not.
 * @topic Containers
 *
 * PathIsAsset
 */
/**
 * @begin PathIsAsset
 * @summary A live CDO path is an asset; a subobject path and an empty path are not.
 * @topic Containers
 */
bool PathIsAsset()
{
	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("PathIsAsset setup: required Actor CDO is null");
	}
	FSoftObjectPath ObjectPath(LiveCdo);
	FSoftObjectPath SubobjectPath("/Engine/Transient.Default__Actor:Root");
	FSoftObjectPath Empty;
	return ObjectPath.IsAsset() && !SubobjectPath.IsAsset() && !Empty.IsAsset();
}
/** @end */
