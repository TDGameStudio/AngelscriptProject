/**
 * @version v1
 * @summary An &out TSet<UObject> is filled then Reset clears Num.
 * @topic Containers
 *
 * FillByResetClearsNumUObject
 */
/**
 * @begin FillByResetClearsNumUObject
 * @summary An &out TSet<UObject> is filled then Reset clears Num.
 * @topic Containers
 */
UCLASS()
class UTSetFillByResetClearsNumUObjectHost : UObject
{
}

void FillByResetClearsNumUObject(TSet<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTSetFillByResetClearsNumUObjectHost::StaticClass(), n"FillByResetClearsNum_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTSetFillByResetClearsNumUObjectHost::StaticClass(), n"FillByResetClearsNum_1", true));
	Result.Reset();
}
/** @end */
