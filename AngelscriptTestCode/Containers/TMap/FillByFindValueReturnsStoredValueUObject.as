/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled so Find can copy stored handles.
 * @topic Containers
 *
 * FillByFindValueReturnsStoredValueUObject
 */
/**
 * @begin FillByFindValueReturnsStoredValueUObject
 * @summary An &out TMap<int, UObject> is filled so Find can copy stored handles.
 * @topic Containers
 */
UCLASS()
class UTMapFillByFindValueReturnsStoredValueUObjectHost : UObject
{
}

void FillByFindValueReturnsStoredValueUObject(TMap<int, UObject>&out Result)
{
	Result.Add(10, NewObject(GetTransientPackage(), UTMapFillByFindValueReturnsStoredValueUObjectHost::StaticClass(), n"FindValue_Fill_0", true));
	Result.Add(20, NewObject(GetTransientPackage(), UTMapFillByFindValueReturnsStoredValueUObjectHost::StaticClass(), n"FindValue_Fill_1", true));
	Result.Add(30, NewObject(GetTransientPackage(), UTMapFillByFindValueReturnsStoredValueUObjectHost::StaticClass(), n"FindValue_Fill_2", true));
}
/** @end */
