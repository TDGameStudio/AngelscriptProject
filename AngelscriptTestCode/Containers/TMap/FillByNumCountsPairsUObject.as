/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled so Num becomes 3.
 * @topic Containers
 *
 * FillByNumCountsPairsUObject
 */
/**
 * @begin FillByNumCountsPairsUObject
 * @summary An &out TMap<int, UObject> is filled so Num becomes 3.
 * @topic Containers
 */
UCLASS()
class UTMapFillByNumCountsPairsUObjectHost : UObject
{
}

void FillByNumCountsPairsUObject(TMap<int, UObject>&out Result)
{
	Result.Add(10, NewObject(GetTransientPackage(), UTMapFillByNumCountsPairsUObjectHost::StaticClass(), n"Num_Fill_0", true));
	Result.Add(20, NewObject(GetTransientPackage(), UTMapFillByNumCountsPairsUObjectHost::StaticClass(), n"Num_Fill_1", true));
	Result.Add(30, NewObject(GetTransientPackage(), UTMapFillByNumCountsPairsUObjectHost::StaticClass(), n"Num_Fill_2", true));
}
/** @end */
