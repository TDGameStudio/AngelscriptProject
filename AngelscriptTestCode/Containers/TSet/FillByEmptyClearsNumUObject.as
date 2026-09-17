/**
 * @version v1
 * @summary An &out TSet<UObject> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNumUObject
 */
/**
 * @begin FillByEmptyClearsNumUObject
 * @summary An &out TSet<UObject> is filled then Empty clears Num.
 * @topic Containers
 */
UCLASS()
class UTSetFillByEmptyClearsNumUObjectHost : UObject
{
}

void FillByEmptyClearsNumUObject(TSet<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTSetFillByEmptyClearsNumUObjectHost::StaticClass(), n"FillByEmptyClearsNum_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTSetFillByEmptyClearsNumUObjectHost::StaticClass(), n"FillByEmptyClearsNum_1", true));
	Result.Empty();
}
/** @end */
