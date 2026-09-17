/**
 * @version v1
 * @summary An &out TSet<UObject> is filled by Add including a skipped duplicate identity.
 * @topic Containers
 *
 * FillByAddDuplicateIgnoredUObject
 */
/**
 * @begin FillByAddDuplicateIgnoredUObject
 * @summary An &out TSet<UObject> is filled by Add including a skipped duplicate identity.
 * @topic Containers
 */
UCLASS()
class UTSetFillByAddDuplicateIgnoredUObjectHost : UObject
{
}

void FillByAddDuplicateIgnoredUObject(TSet<UObject>&out Result)
{
	UObject First = NewObject(GetTransientPackage(), UTSetFillByAddDuplicateIgnoredUObjectHost::StaticClass(), n"FillByAddDuplicateIgnored_0", true);
	Result.Add(First);
	Result.Add(First);
}
/** @end */
