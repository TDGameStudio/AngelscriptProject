/**
 * @version v1
 * @summary An &out TSet<UObject> is filled then Remove of an absent handle is a no-op.
 * @topic Containers
 *
 * FillByRemoveMissingUObject
 */
/**
 * @begin FillByRemoveMissingUObject
 * @summary An &out TSet<UObject> is filled then Remove of an absent handle is a no-op.
 * @topic Containers
 */
UCLASS()
class UTSetFillByRemoveMissingUObjectHost : UObject
{
}

void FillByRemoveMissingUObject(TSet<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTSetFillByRemoveMissingUObjectHost::StaticClass(), n"FillByRemoveMissing_0", true));
	UObject Missing = NewObject(GetTransientPackage(), UTSetFillByRemoveMissingUObjectHost::StaticClass(), n"FillByRemoveMissing_Missing", true);
	Result.Remove(Missing);
}
/** @end */
