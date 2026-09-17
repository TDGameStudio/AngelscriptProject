/**
 * @version v1
 * @summary An &out TOptional<UObject> is filled by copy assignment.
 * @topic Containers
 *
 * FillByCopyAssignUObject
 */
/**
 * @begin FillByCopyAssignUObject
 * @summary An &out TOptional<UObject> is filled by copy assignment.
 * @topic Containers
 */
UCLASS()
class UTOptionalFillByCopyAssignUObjectHost : UObject
{
}

void FillByCopyAssignUObject(TOptional<UObject>&out Result)
{
	TOptional<UObject> Source;
	Source.Set(NewObject(GetTransientPackage(), UTOptionalFillByCopyAssignUObjectHost::StaticClass(), n"FillByCopyAssign_0", true));
	Result = Source;
}
/** @end */
