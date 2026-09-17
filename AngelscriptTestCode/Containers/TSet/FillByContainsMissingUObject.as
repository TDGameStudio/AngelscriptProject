/**
 * @version v1
 * @summary An &out TSet<UObject> is filled so Contains can miss an absent handle.
 * @topic Containers
 *
 * FillByContainsMissingUObject
 */
/**
 * @begin FillByContainsMissingUObject
 * @summary An &out TSet<UObject> is filled so Contains can miss an absent handle.
 * @topic Containers
 */
UCLASS()
class UTSetFillByContainsMissingUObjectHost : UObject
{
}

void FillByContainsMissingUObject(TSet<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTSetFillByContainsMissingUObjectHost::StaticClass(), n"FillByContainsMissing_0", true));
}
/** @end */
