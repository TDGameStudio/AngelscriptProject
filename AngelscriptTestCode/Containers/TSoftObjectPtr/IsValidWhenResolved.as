/**
 * @version v1
 * @summary IsValid is true only for a resolved live object, not empty or pending paths.
 * @topic Containers
 * IsValidWhenResolved
 */
/**
 * @begin IsValidWhenResolved
 * @summary IsValid is true only for a resolved live object, not empty or pending paths.
 * @topic Containers
 */
bool IsValidWhenResolved()
{
	TSoftObjectPtr<UObject> Empty;
	UObject LiveCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		return false;
	}

	TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
	TSoftObjectPtr<UObject> Missing(FSoftObjectPath("/Game/DoesNotExist.DoesNotExist"));
	return !Empty.IsValid() && ObjectRef.IsValid() && !Missing.IsValid();
}
/** @end */
