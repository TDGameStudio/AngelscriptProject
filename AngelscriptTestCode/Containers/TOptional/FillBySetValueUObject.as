/**
 * @version v1
 * @summary An &out TOptional<UObject> is filled by Set of a NewObject handle.
 * @topic Containers
 *
 * FillBySetValueUObject
 */
/**
 * @begin FillBySetValueUObject
 * @summary An &out TOptional<UObject> is filled by Set of a NewObject handle.
 * @topic Containers
 */
UCLASS()
class UTOptionalFillBySetValueUObjectHost : UObject
{
}

void FillBySetValueUObject(TOptional<UObject>&out Result)
{
	Result.Set(NewObject(GetTransientPackage(), UTOptionalFillBySetValueUObjectHost::StaticClass(), n"FillBySetValue_0", true));
}
/** @end */
