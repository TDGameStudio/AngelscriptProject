/**
 * @version v1
 * @summary Remove deletes a present int key from a UObject map and returns false for a missing key.
 * @topic Containers
 *
 * RemoveKeyDropsPairUObject
 */
/**
 * @begin RemoveKeyDropsPairUObject
 * @summary Remove deletes a present int key from a UObject map and returns false for a missing key.
 * @topic Containers
 */
UCLASS()
class UTMapRemoveKeyDropsPairUObjectHost : UObject
{
}

bool RemoveKeyDropsPairUObject()
{
	TMap<int, UObject> Map;
	UObject First = NewObject(GetTransientPackage(), UTMapRemoveKeyDropsPairUObjectHost::StaticClass(), n"RemoveKey_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTMapRemoveKeyDropsPairUObjectHost::StaticClass(), n"RemoveKey_Second", true);
	if (First == nullptr || Second == nullptr)
	{
		return false;
	}
	Map.Add(10, First);
	Map.Add(20, Second);
	bool bRemoved = Map.Remove(10);
	bool bMissing = Map.Remove(99);
	return bRemoved && !bMissing && Map.Num() == 1 && Map.Contains(20) && !Map.Contains(10);
}
/** @end */
