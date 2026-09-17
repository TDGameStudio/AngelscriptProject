/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled so GetValues can list stored handles.
 * @topic Containers
 *
 * FillByGetValuesListsStoredValuesUObject
 */
/**
 * @begin FillByGetValuesListsStoredValuesUObject
 * @summary An &out TMap<int, UObject> is filled so GetValues can list stored handles.
 * @topic Containers
 */
UCLASS()
class UTMapFillByGetValuesListsStoredValuesUObjectHost : UObject
{
}

void FillByGetValuesListsStoredValuesUObject(TMap<int, UObject>&out Result)
{
	Result.Add(10, NewObject(GetTransientPackage(), UTMapFillByGetValuesListsStoredValuesUObjectHost::StaticClass(), n"GetValues_Fill_0", true));
	Result.Add(20, NewObject(GetTransientPackage(), UTMapFillByGetValuesListsStoredValuesUObjectHost::StaticClass(), n"GetValues_Fill_1", true));
	Result.Add(30, NewObject(GetTransientPackage(), UTMapFillByGetValuesListsStoredValuesUObjectHost::StaticClass(), n"GetValues_Fill_2", true));
}
/** @end */
