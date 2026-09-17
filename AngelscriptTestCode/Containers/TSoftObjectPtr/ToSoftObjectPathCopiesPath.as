/**
 * @version v1
 * @summary ToSoftObjectPath is null when empty and equals the live CDO path when set.
 * @topic Containers
 * ToSoftObjectPathCopiesPath
 */
/**
 * @begin ToSoftObjectPathCopiesPath
 * @summary ToSoftObjectPath is null when empty and equals the live CDO path when set.
 * @topic Containers
 */
bool ToSoftObjectPathCopiesPath()
{
	TSoftObjectPtr<UObject> Empty;
	UObject LiveCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		return false;
	}

	FSoftObjectPath Expected(LiveCdo);
	TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
	FSoftObjectPath ObjectPath = ObjectRef.ToSoftObjectPath();
	return Empty.ToSoftObjectPath().IsNull()
		&& ObjectPath == Expected
		&& ObjectPath.IsValid();
}
/** @end */
