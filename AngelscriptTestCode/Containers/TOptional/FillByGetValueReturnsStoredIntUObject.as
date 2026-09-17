/**
 * @version v1
 * @summary An &out TOptional<UObject> is filled so GetValue can read it.
 * @topic Containers
 *
 * FillByGetValueReturnsStoredIntUObject
 */
/**
 * @begin FillByGetValueReturnsStoredIntUObject
 * @summary An &out TOptional<UObject> is filled so GetValue can read it.
 * @topic Containers
 */
UCLASS()
class UTOptionalFillByGetValueReturnsStoredIntUObjectHost : UObject
{
}

void FillByGetValueReturnsStoredIntUObject(TOptional<UObject>&out Result)
{
	Result.Set(NewObject(GetTransientPackage(), UTOptionalFillByGetValueReturnsStoredIntUObjectHost::StaticClass(), n"FillByGetValueReturnsStoredInt_0", true));
}
/** @end */
