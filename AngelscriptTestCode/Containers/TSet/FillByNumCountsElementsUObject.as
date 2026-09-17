/**
 * @version v1
 * @summary An &out TSet<UObject> is filled so Num becomes 2.
 * @topic Containers
 *
 * FillByNumCountsElementsUObject
 */
/**
 * @begin FillByNumCountsElementsUObject
 * @summary An &out TSet<UObject> is filled so Num becomes 2.
 * @topic Containers
 */
UCLASS()
class UTSetFillByNumCountsElementsUObjectHost : UObject
{
}

void FillByNumCountsElementsUObject(TSet<UObject>&out Result)
{
	UObject First = NewObject(GetTransientPackage(), UTSetFillByNumCountsElementsUObjectHost::StaticClass(), n"FillByNumCountsElements_0", true);
	UObject Second = NewObject(GetTransientPackage(), UTSetFillByNumCountsElementsUObjectHost::StaticClass(), n"FillByNumCountsElements_1", true);
	Result.Add(First);
	Result.Add(Second);
	Result.Add(First);
}
/** @end */
