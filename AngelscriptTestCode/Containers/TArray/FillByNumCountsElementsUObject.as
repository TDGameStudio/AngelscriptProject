/**
 * @version v1
 * @summary An &out TArray<UObject> is filled so Num becomes 3.
 * @topic Containers
 *
 * FillByNumCountsElementsUObject
 */
/**
 * @begin FillByNumCountsElementsUObject
 * @summary An &out TArray<UObject> is filled so Num becomes 3.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByNumCountsElementsUObjectHost : UObject
{
}

void FillByNumCountsElementsUObject(TArray<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByNumCountsElementsUObjectHost::StaticClass(), n"FillByNum_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByNumCountsElementsUObjectHost::StaticClass(), n"FillByNum_1", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByNumCountsElementsUObjectHost::StaticClass(), n"FillByNum_2", true));
}
/** @end */
