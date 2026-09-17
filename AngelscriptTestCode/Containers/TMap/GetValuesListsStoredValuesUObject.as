/**
 * @version v1
 * @summary GetValues copies every stored UObject handle into the destination array.
 * @topic Containers
 *
 * GetValuesListsStoredValuesUObject
 */
/**
 * @begin GetValuesListsStoredValuesUObject
 * @summary GetValues copies every stored UObject handle into the destination array.
 * @topic Containers
 */
UCLASS()
class UTMapGetValuesListsStoredValuesUObjectHost : UObject
{
}

bool GetValuesListsStoredValuesUObject()
{
	TMap<int, UObject> Map;
	UObject First = NewObject(GetTransientPackage(), UTMapGetValuesListsStoredValuesUObjectHost::StaticClass(), n"GetValues_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTMapGetValuesListsStoredValuesUObjectHost::StaticClass(), n"GetValues_Second", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}
	Map.Add(10, First);
	Map.Add(20, Second);
	TArray<UObject> Values;
	Map.GetValues(Values);
	return Values.Num() == 2 && Values.Contains(First) && Values.Contains(Second);
}
/** @end */
