/**
 * @version v1
 * @summary Bracket access reads and writes an existing int key in a TMap of UObject values.
 * @topic Containers
 *
 * IndexAccessUObject
 */
/**
 * @begin IndexAccessUObject
 * @summary Bracket access reads and writes an existing int key in a TMap of UObject values.
 * @topic Containers
 */
UCLASS()
class UTMapIndexObject : UObject
{
}

bool IndexAccessUObject()
{
	TMap<int, UObject> Map;
	UObject First = NewObject(GetTransientPackage(), UTMapIndexObject::StaticClass(), n"TMapIndex_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTMapIndexObject::StaticClass(), n"TMapIndex_Second", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}
	Map.Add(10, First);
	if (Map[10] != First)
	{
		return false;
	}
	Map[10] = Second;
	return Map[10] == Second && Map.Num() == 1;
}
/** @end */
