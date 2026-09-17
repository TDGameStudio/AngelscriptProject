/**
 * @version v1
 * @summary An &out TOptional<UObject> is filled so Get returns the stored handle.
 * @topic Containers
 *
 * FillByGetReturnsStoredValueUObject
 */
/**
 * @begin FillByGetReturnsStoredValueUObject
 * @summary An &out TOptional<UObject> is filled so Get returns the stored handle.
 * @topic Containers
 */
UCLASS()
class UTOptionalFillByGetReturnsStoredValueUObjectHost : UObject
{
}

void FillByGetReturnsStoredValueUObject(TOptional<UObject>&out Result)
{
	Result.Set(NewObject(GetTransientPackage(), UTOptionalFillByGetReturnsStoredValueUObjectHost::StaticClass(), n"FillByGetReturnsStoredValue_0", true));
}
/** @end */
