/**
 * @version v1
 * @summary An empty FSoftObjectPath is null; a live CDO path is not null.
 * @topic Containers
 *
 * PathIsNull
 */
/**
 * @begin PathIsNull
 * @summary An empty FSoftObjectPath is null; a live CDO path is not null.
 * @topic Containers
 */
bool PathIsNull()
{
	FSoftObjectPath Empty;
	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("PathIsNull setup: required Actor CDO is null");
	}
	FSoftObjectPath ObjectPath(LiveCdo);
	return Empty.IsNull() && !ObjectPath.IsNull();
}
/** @end */
