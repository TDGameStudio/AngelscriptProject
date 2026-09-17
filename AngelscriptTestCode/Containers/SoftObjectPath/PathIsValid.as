/**
 * @version v1
 * @summary An empty FSoftObjectPath is not valid; a live CDO path is valid.
 * @topic Containers
 *
 * PathIsValid
 */
/**
 * @begin PathIsValid
 * @summary An empty FSoftObjectPath is not valid; a live CDO path is valid.
 * @topic Containers
 */
bool PathIsValid()
{
	FSoftObjectPath Empty;
	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("PathIsValid setup: required Actor CDO is null");
	}
	FSoftObjectPath ObjectPath(LiveCdo);
	return !Empty.IsValid() && ObjectPath.IsValid();
}
/** @end */
