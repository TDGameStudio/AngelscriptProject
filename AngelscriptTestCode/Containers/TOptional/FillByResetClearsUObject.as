/**
 * @version v1
 * @summary An &out TOptional<UObject> is set then Reset back to unset.
 * @topic Containers
 *
 * FillByResetClearsUObject
 */
/**
 * @begin FillByResetClearsUObject
 * @summary An &out TOptional<UObject> is set then Reset back to unset.
 * @topic Containers
 */
UCLASS()
class UTOptionalFillByResetClearsUObjectHost : UObject
{
}

void FillByResetClearsUObject(TOptional<UObject>&out Result)
{
	Result.Set(NewObject(GetTransientPackage(), UTOptionalFillByResetClearsUObjectHost::StaticClass(), n"FillByResetClears_0", true));
	Result.Reset();
}
/** @end */
