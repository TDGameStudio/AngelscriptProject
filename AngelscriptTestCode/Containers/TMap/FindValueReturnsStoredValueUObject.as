/**
 * @version v1
 * @summary Find copies the stored UObject handle and returns true for a present int key.
 * @topic Containers
 *
 * FindValueReturnsStoredValueUObject
 */
/**
 * @begin FindValueReturnsStoredValueUObject
 * @summary Find copies the stored UObject handle and returns true for a present int key.
 * @topic Containers
 */
UCLASS()
class UTMapFindValueReturnsStoredValueUObjectHost : UObject
{
}

bool FindValueReturnsStoredValueUObject()
{
	TMap<int, UObject> Map;
	UObject First = NewObject(GetTransientPackage(), UTMapFindValueReturnsStoredValueUObjectHost::StaticClass(), n"FindValue_First", true);
	if (First == nullptr)
	{
		return false;
	}
	Map.Add(10, First);
	UObject Found = nullptr;
	bool bFound = Map.Find(10, Found);
	return bFound && Found == First;
}
/** @end */
