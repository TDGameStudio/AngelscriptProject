/**
 * @version v1
 * @summary EditorOnlyLoadSynchronous of a live UObject CDO returns that CDO; empty stays null.
 * @topic Containers
 * EditorOnlyLoadSynchronous
 */
/**
 * @begin EditorOnlyLoadSynchronous
 * @summary EditorOnlyLoadSynchronous of a live UObject CDO returns that CDO; empty stays null.
 * @topic Containers
 */
bool EditorOnlyLoadSynchronous()
{
	UObject LiveCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		return false;
	}

	TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
	UObject Loaded = ObjectRef.EditorOnlyLoadSynchronous();
	TSoftObjectPtr<UObject> Empty;
	UObject EmptyLoaded = Empty.EditorOnlyLoadSynchronous();
	return Loaded == LiveCdo && EmptyLoaded == nullptr;
}
/** @end */
