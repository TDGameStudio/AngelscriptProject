/**
 * @version v1
 * @summary Contains is true for present int keys in a TMap of UObject values.
 * @topic Containers
 *
 * ContainsKeyUObject
 */
/**
 * @begin ContainsKeyUObject
 * @summary Contains is true for present int keys in a TMap of UObject values.
 * @topic Containers
 */
UCLASS()
class UTMapContainsObject : UObject
{
}

bool ContainsKeyUObject()
{
	TMap<int, UObject> Map;
	UObject First = NewObject(GetTransientPackage(), UTMapContainsObject::StaticClass(), n"TMapContains_First", true);
	if (First == nullptr)
	{
		return false;
	}
	Map.Add(10, First);
	Map.Add(20, First);
	return Map.Contains(10) && Map.Contains(20);
}
/** @end */
