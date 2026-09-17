/**
 * @version v1
 * @summary An &out TArray<UObject> is filled with a FindIndex sequence that repeats the first handle.
 * @topic Containers
 *
 * FillByFindIndexReturnsFirstOrMinusOneUObject
 */
/**
 * @begin FillByFindIndexReturnsFirstOrMinusOneUObject
 * @summary An &out TArray<UObject> is filled with a FindIndex sequence that repeats the first handle.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByFindIndexReturnsFirstOrMinusOneUObjectHost : UObject
{
}

void FillByFindIndexReturnsFirstOrMinusOneUObject(TArray<UObject>&out Result)
{
	UObject First = NewObject(GetTransientPackage(), UTArrayFillByFindIndexReturnsFirstOrMinusOneUObjectHost::StaticClass(), n"FillByFindIndex_0", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayFillByFindIndexReturnsFirstOrMinusOneUObjectHost::StaticClass(), n"FillByFindIndex_1", true);
	Result.Add(First);
	Result.Add(Second);
	Result.Add(First);
}
/** @end */
