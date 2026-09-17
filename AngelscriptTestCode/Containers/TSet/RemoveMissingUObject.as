/**
 * @version v1
 * @summary Remove of an absent UObject member returns false and does not throw.
 * @topic Containers
 *
 * RemoveMissingUObject
 */
/**
 * @begin RemoveMissingUObject
 * @summary Remove of an absent UObject member returns false and does not throw.
 * @topic Containers
 */
UCLASS()
class UTSetRemoveMissingUObjectHost : UObject
{
}

bool RemoveMissingUObject()
{
	TSet<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTSetRemoveMissingUObjectHost::StaticClass(), n"RemoveMissing_First", true);
	UObject Missing = NewObject(GetTransientPackage(), UTSetRemoveMissingUObjectHost::StaticClass(), n"RemoveMissing_Missing", true);
	Values.Add(First);
	return !Values.Remove(Missing) && Values.Num() == 1 && Values.Contains(First);
}
/** @end */
