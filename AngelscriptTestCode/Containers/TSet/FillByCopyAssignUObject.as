/**
 * @version v1
 * @summary An &out TSet<UObject> is filled by assigning a local source set.
 * @topic Containers
 *
 * FillByCopyAssignUObject
 */
/**
 * @begin FillByCopyAssignUObject
 * @summary An &out TSet<UObject> is filled by assigning a local source set.
 * @topic Containers
 */
UCLASS()
class UTSetFillByCopyAssignUObjectHost : UObject
{
}

void FillByCopyAssignUObject(TSet<UObject>&out Result)
{
	TSet<UObject> Source;
	Source.Add(NewObject(GetTransientPackage(), UTSetFillByCopyAssignUObjectHost::StaticClass(), n"FillByCopyAssign_0", true));
	Source.Add(NewObject(GetTransientPackage(), UTSetFillByCopyAssignUObjectHost::StaticClass(), n"FillByCopyAssign_1", true));
	Result = Source;
}
/** @end */
