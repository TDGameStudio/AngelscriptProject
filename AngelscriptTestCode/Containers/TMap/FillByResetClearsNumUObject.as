/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled then Reset clears Num.
 * @topic Containers
 *
 * FillByResetClearsNumUObject
 */
/**
 * @begin FillByResetClearsNumUObject
 * @summary An &out TMap<int, UObject> is filled then Reset clears Num.
 * @topic Containers
 */
UCLASS()
class UTMapFillByResetClearsNumUObjectHost : UObject
{
}

void FillByResetClearsNumUObject(TMap<int, UObject>&out Result)
{
	Result.Add(10, NewObject(GetTransientPackage(), UTMapFillByResetClearsNumUObjectHost::StaticClass(), n"ResetClears_Fill_0", true));
	Result.Add(20, NewObject(GetTransientPackage(), UTMapFillByResetClearsNumUObjectHost::StaticClass(), n"ResetClears_Fill_1", true));
	Result.Add(30, NewObject(GetTransientPackage(), UTMapFillByResetClearsNumUObjectHost::StaticClass(), n"ResetClears_Fill_2", true));
	Result.Reset();
}
/** @end */
