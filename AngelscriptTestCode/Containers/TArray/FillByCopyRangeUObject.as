/**
 * @version v1
 * @summary An &out TArray<UObject> is filled then overwritten by Copy.
 * @topic Containers
 *
 * FillByCopyRangeUObject
 */
/**
 * @begin FillByCopyRangeUObject
 * @summary An &out TArray<UObject> is filled then overwritten by Copy.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByCopyRangeUObjectHost : UObject
{
}

void FillByCopyRangeUObject(TArray<UObject>&out Result)
{
	Result.Add(nullptr);
	Result.Add(nullptr);
	Result.Add(nullptr);
	TArray<UObject> Source;
	Source.Add(NewObject(GetTransientPackage(), UTArrayFillByCopyRangeUObjectHost::StaticClass(), n"FillByCopyRange_0", true));
	Source.Add(NewObject(GetTransientPackage(), UTArrayFillByCopyRangeUObjectHost::StaticClass(), n"FillByCopyRange_1", true));
	Result.Copy(Source, 0, 2, 1);
}
/** @end */
