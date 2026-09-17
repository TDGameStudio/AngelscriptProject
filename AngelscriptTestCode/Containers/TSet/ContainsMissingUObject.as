/**
 * @version v1
 * @summary Contains is false for a UObject member that was never added.
 * @topic Containers
 *
 * ContainsMissingUObject
 */
/**
 * @begin ContainsMissingUObject
 * @summary Contains is false for a UObject member that was never added.
 * @topic Containers
 */
UCLASS()
class UTSetContainsMissingUObjectHost : UObject
{
}

bool ContainsMissingUObject()
{
	TSet<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTSetContainsMissingUObjectHost::StaticClass(), n"ContainsMissing_First", true);
	UObject Missing = NewObject(GetTransientPackage(), UTSetContainsMissingUObjectHost::StaticClass(), n"ContainsMissing_Missing", true);
	Values.Add(First);
	return !Values.Contains(Missing) && Values.Contains(First);
}
/** @end */
