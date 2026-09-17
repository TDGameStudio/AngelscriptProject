/**
 * @version v1
 * @summary GetKeys copies every int key from a UObject map into the destination array.
 * @topic Containers
 *
 * GetKeysListsPresentKeysUObject
 */
/**
 * @begin GetKeysListsPresentKeysUObject
 * @summary GetKeys copies every int key from a UObject map into the destination array.
 * @topic Containers
 */
UCLASS()
class UTMapGetKeysListsPresentKeysUObjectHost : UObject
{
}

bool GetKeysListsPresentKeysUObject()
{
	TMap<int, UObject> Map;
	UObject First = NewObject(GetTransientPackage(), UTMapGetKeysListsPresentKeysUObjectHost::StaticClass(), n"GetKeys_First", true);
	if (First == nullptr)
	{
		return false;
	}
	Map.Add(10, First);
	Map.Add(20, First);
	TArray<int> Keys;
	Map.GetKeys(Keys);
	return Keys.Num() == 2 && Keys.Contains(10) && Keys.Contains(20);
}
/** @end */
