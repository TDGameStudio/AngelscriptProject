/**
 * @version v1
 * @summary Num counts distinct int keys in a TMap of UObject values; overwrite does not grow Num.
 * @topic Containers
 *
 * NumCountsPairsUObject
 */
/**
 * @begin NumCountsPairsUObject
 * @summary Num counts distinct int keys in a TMap of UObject values; overwrite does not grow Num.
 * @topic Containers
 */
UCLASS()
class UTMapNumObject : UObject
{
}

bool NumCountsPairsUObject()
{
	TMap<int, UObject> Map;
	UObject First = NewObject(GetTransientPackage(), UTMapNumObject::StaticClass(), n"TMapNum_First", true);
	if (Map.Num() != 0 || First == nullptr)
	{
		return false;
	}
	Map.Add(10, First);
	Map.Add(20, First);
	Map.Add(10, First);
	return Map.Num() == 2;
}
/** @end */
