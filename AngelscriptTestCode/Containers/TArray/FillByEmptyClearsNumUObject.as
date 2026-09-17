/**
 * @version v1
 * @summary An &out TArray<UObject> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNumUObject
 */
/**
 * @begin FillByEmptyClearsNumUObject
 * @summary An &out TArray<UObject> is filled then Empty clears Num.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByEmptyClearsNumUObjectHost : UObject
{
}

void FillByEmptyClearsNumUObject(TArray<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByEmptyClearsNumUObjectHost::StaticClass(), n"FillByEmpty_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByEmptyClearsNumUObjectHost::StaticClass(), n"FillByEmpty_1", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByEmptyClearsNumUObjectHost::StaticClass(), n"FillByEmpty_2", true));
	Result.Empty();
}
/** @end */
