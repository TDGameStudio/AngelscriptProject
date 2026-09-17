/**
 * @version v1
 * @summary Add of the same int key twice keeps Num and stores the last UObject handle.
 * @topic Containers
 *
 * AddOverwriteReplacesValueUObject
 */
/**
 * @begin AddOverwriteReplacesValueUObject
 * @summary Add of the same int key twice keeps Num and stores the last UObject handle.
 * @topic Containers
 */
UCLASS()
class UTMapAddOverwriteReplacesValueUObjectHost : UObject
{
}

bool AddOverwriteReplacesValueUObject()
{
	TMap<int, UObject> Map;
	UObject First = NewObject(GetTransientPackage(), UTMapAddOverwriteReplacesValueUObjectHost::StaticClass(), n"AddOverwrite_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTMapAddOverwriteReplacesValueUObjectHost::StaticClass(), n"AddOverwrite_Second", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}
	Map.Add(10, First);
	if (Map.Num() != 1 || Map[10] != First)
	{
		return false;
	}

	Map.Add(10, Second);
	return Map.Num() == 1 && Map.Contains(10) && Map[10] == Second;
}
/** @end */
