/**
 * @version v1
 * @summary IsPending is true only for a path that has not resolved.
 * @topic Containers
 * IsPendingWhenUnloaded
 */
/**
 * @begin IsPendingWhenUnloaded
 * @summary IsPending is true only for a path that has not resolved.
 * @topic Containers
 */
bool IsPendingWhenUnloaded()
{
	TSoftObjectPtr<UObject> Empty;
	UObject LiveCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		return false;
	}

	TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
	TSoftObjectPtr<UObject> Missing(FSoftObjectPath("/Game/DoesNotExist.DoesNotExist"));
	return !Empty.IsPending() && !ObjectRef.IsPending() && Missing.IsPending();
}
/** @end */
