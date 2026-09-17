/**
 * @version v1
 * @summary Path, object, and copy constructors preserve a live CDO identity.
 * @topic Containers
 * PathObjectCopyConstructors
 */
/**
 * @begin PathObjectCopyConstructors
 * @summary Path, object, and copy constructors preserve a live CDO identity.
 * @topic Containers
 */
bool PathObjectCopyConstructors()
{
	UObject LiveCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		return false;
	}

	FSoftObjectPath Path(LiveCdo);
	TSoftObjectPtr<UObject> FromPath(Path);
	TSoftObjectPtr<UObject> FromObject(LiveCdo);
	TSoftObjectPtr<UObject> Copied(FromObject);
	TSoftClassPtr<AActor> FromClass(AActor::StaticClass());
	return FromPath.Get() == LiveCdo
		&& FromPath.ToSoftObjectPath() == Path
		&& FromObject.Get() == LiveCdo
		&& Copied.Get() == LiveCdo
		&& Copied == FromObject
		&& FromClass.Get().Get() == AActor::StaticClass();
}
/** @end */
