/**
 * @version v1
 * @summary Add inserts distinct int keys and stores each UObject handle.
 * @topic Containers
 *
 * AddPairInsertsKeyValueUObject
 */
/**
 * @begin AddPairInsertsKeyValueUObject
 * @summary Add inserts distinct int keys and stores each UObject handle.
 * @topic Containers
 */
UCLASS()
class UTMapAddPairInsertsKeyValueUObjectHost : UObject
{
}

bool AddPairInsertsKeyValueUObject()
{
	TMap<int, UObject> Map;
	UObject First = NewObject(GetTransientPackage(), UTMapAddPairInsertsKeyValueUObjectHost::StaticClass(), n"AddPair_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTMapAddPairInsertsKeyValueUObjectHost::StaticClass(), n"AddPair_Second", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}
	Map.Add(10, First);
	Map.Add(20, Second);
	return Map.Num() == 2 && Map[10] == First && Map[20] == Second && Map.Contains(20);
}
/** @end */
