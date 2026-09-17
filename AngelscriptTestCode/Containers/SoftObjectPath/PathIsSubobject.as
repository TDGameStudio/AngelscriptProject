/**
 * @version v1
 * @summary A subobject path is a subobject; a live CDO path and an empty path are not.
 * @topic Containers
 *
 * PathIsSubobject
 */
/**
 * @begin PathIsSubobject
 * @summary A subobject path is a subobject; a live CDO path and an empty path are not.
 * @topic Containers
 */
bool PathIsSubobject()
{
	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("PathIsSubobject setup: required Actor CDO is null");
	}
	FSoftObjectPath ObjectPath(LiveCdo);
	FSoftObjectPath SubobjectPath("/Engine/Transient.Default__Actor:Root");
	FSoftObjectPath Empty;
	return !ObjectPath.IsSubobject() && SubobjectPath.IsSubobject() && !Empty.IsSubobject();
}
/** @end */
