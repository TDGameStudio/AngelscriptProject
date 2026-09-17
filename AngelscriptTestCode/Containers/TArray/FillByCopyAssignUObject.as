/**
 * @version v1
 * @summary An &out TArray<UObject> is filled by assigning a local source array.
 * @topic Containers
 *
 * FillByCopyAssignUObject
 */
/**
 * @begin FillByCopyAssignUObject
 * @summary An &out TArray<UObject> is filled by assigning a local source array.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByCopyAssignUObjectHost : UObject
{
}

void FillByCopyAssignUObject(TArray<UObject>&out Result)
{
	TArray<UObject> Source;
	Source.Add(NewObject(GetTransientPackage(), UTArrayFillByCopyAssignUObjectHost::StaticClass(), n"FillByCopyAssign_0", true));
	Source.Add(NewObject(GetTransientPackage(), UTArrayFillByCopyAssignUObjectHost::StaticClass(), n"FillByCopyAssign_1", true));
	Result = Source;
}
/** @end */
