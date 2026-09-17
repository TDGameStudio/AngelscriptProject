/**
 * @version v1
 * @summary An &out TOptional<UObject> is marked set by Set of a NewObject handle.
 * @topic Containers
 *
 * FillByIsSetAfterSetUObject
 */
/**
 * @begin FillByIsSetAfterSetUObject
 * @summary An &out TOptional<UObject> is marked set by Set of a NewObject handle.
 * @topic Containers
 */
UCLASS()
class UTOptionalFillByIsSetAfterSetUObjectHost : UObject
{
}

void FillByIsSetAfterSetUObject(TOptional<UObject>&out Result)
{
	Result.Set(NewObject(GetTransientPackage(), UTOptionalFillByIsSetAfterSetUObjectHost::StaticClass(), n"FillByIsSetAfterSet_0", true));
}
/** @end */
