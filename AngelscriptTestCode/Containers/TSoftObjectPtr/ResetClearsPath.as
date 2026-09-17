/**
 * @version v1
 * @summary Reset clears a set soft pointer back to null.
 * @topic Containers
 * ResetClearsPath
 */
/**
 * @begin ResetClearsPath
 * @summary Reset clears a set soft pointer back to null.
 * @topic Containers
 */
bool ResetClearsPath()
{
	UObject LiveCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		return false;
	}

	TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
	ObjectRef.Reset();
	bool bObjectReset = ObjectRef.IsNull() && ObjectRef.ToString().IsEmpty();
	ObjectRef.Reset();

	TSoftClassPtr<AActor> ClassRef = AActor::StaticClass();
	ClassRef.Reset();
	return bObjectReset && ObjectRef.IsNull() && ClassRef.IsNull() && ClassRef.ToString().IsEmpty();
}
/** @end */
