/**
 * @version v1
 * @summary ToString is empty when null and matches the live CDO path string when set.
 * @topic Containers
 * ToStringWritesPath
 */
/**
 * @begin ToStringWritesPath
 * @summary ToString is empty when null and matches the live CDO path string when set.
 * @topic Containers
 */
bool ToStringWritesPath()
{
	TSoftObjectPtr<UObject> Empty;
	UObject LiveCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		return false;
	}

	FSoftObjectPath Expected(LiveCdo);
	TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
	return Empty.ToString().IsEmpty() && ObjectRef.ToString() == Expected.ToString();
}
/** @end */
