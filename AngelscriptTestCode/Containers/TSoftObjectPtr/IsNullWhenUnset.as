/**
 * @version v1
 * @summary IsNull is true only when no path is set, not for a live or pending pointer.
 * @topic Containers
 * IsNullWhenUnset
 */
/**
 * @begin IsNullWhenUnset
 * @summary IsNull is true only when no path is set, not for a live or pending pointer.
 * @topic Containers
 */
bool IsNullWhenUnset()
{
	TSoftObjectPtr<UObject> Empty;
	UObject LiveCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		return false;
	}

	TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
	TSoftObjectPtr<UObject> Missing(FSoftObjectPath("/Game/DoesNotExist.DoesNotExist"));
	return Empty.IsNull() && !ObjectRef.IsNull() && !Missing.IsNull();
}
/** @end */
