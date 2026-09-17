/**
 * @version v1
 * @summary FindOrAdd returns the existing UObject handle and ignores a later default.
 * @topic Containers
 *
 * FindOrAddReturnsExistingUObject
 */
/**
 * @begin FindOrAddReturnsExistingUObject
 * @summary FindOrAdd returns the existing UObject handle and ignores a later default.
 * @topic Containers
 */
UCLASS()
class UTMapFindOrAddReturnsExistingUObjectHost : UObject
{
}

bool FindOrAddReturnsExistingUObject()
{
	TMap<int, UObject> Map;
	UObject First = NewObject(GetTransientPackage(), UTMapFindOrAddReturnsExistingUObjectHost::StaticClass(), n"FindOrAddExisting_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTMapFindOrAddReturnsExistingUObjectHost::StaticClass(), n"FindOrAddExisting_Second", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}
	UObject& WithDefault = Map.FindOrAdd(10, First);
	UObject& Existing = Map.FindOrAdd(10, Second);
	return WithDefault == First && Map[10] == First && Existing == First;
}
/** @end */
