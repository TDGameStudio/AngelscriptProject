/**
 * @version v1
 * @summary Get returns the live object, and nullptr when empty or only pending.
 * @topic Containers
 * GetReturnsResolvedObject
 */
/**
 * @begin GetReturnsResolvedObject
 * @summary Get returns the live object, and nullptr when empty or only pending.
 * @topic Containers
 */
bool GetReturnsResolvedObject()
{
	TSoftObjectPtr<UObject> Empty;
	UObject LiveCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		return false;
	}

	TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
	TSoftObjectPtr<UObject> Missing(FSoftObjectPath("/Game/DoesNotExist.DoesNotExist"));
	return Empty.Get() == nullptr && ObjectRef.Get() == LiveCdo && Missing.Get() == nullptr;
}
/** @end */
