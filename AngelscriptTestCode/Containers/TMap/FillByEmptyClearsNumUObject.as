/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNumUObject
 */
/**
 * @begin FillByEmptyClearsNumUObject
 * @summary An &out TMap<int, UObject> is filled then Empty clears Num.
 * @topic Containers
 */
UCLASS()
class UTMapFillByEmptyClearsNumUObjectHost : UObject
{
}

void FillByEmptyClearsNumUObject(TMap<int, UObject>&out Result)
{
	Result.Add(10, NewObject(GetTransientPackage(), UTMapFillByEmptyClearsNumUObjectHost::StaticClass(), n"EmptyClears_Fill_0", true));
	Result.Add(20, NewObject(GetTransientPackage(), UTMapFillByEmptyClearsNumUObjectHost::StaticClass(), n"EmptyClears_Fill_1", true));
	Result.Add(30, NewObject(GetTransientPackage(), UTMapFillByEmptyClearsNumUObjectHost::StaticClass(), n"EmptyClears_Fill_2", true));
	Result.Empty();
}
/** @end */
