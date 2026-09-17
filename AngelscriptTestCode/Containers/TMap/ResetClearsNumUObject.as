/**
 * @version v1
 * @summary Reset clears every UObject pair so Num is 0.
 * @topic Containers
 *
 * ResetClearsNumUObject
 */
/**
 * @begin ResetClearsNumUObject
 * @summary Reset clears every UObject pair so Num is 0.
 * @topic Containers
 */
UCLASS()
class UTMapResetClearsNumUObjectHost : UObject
{
}

bool ResetClearsNumUObject()
{
	TMap<int, UObject> Map;
	UObject First = NewObject(GetTransientPackage(), UTMapResetClearsNumUObjectHost::StaticClass(), n"ResetClears_First", true);
	if (First == nullptr)
	{
		return false;
	}
	Map.Add(10, First);
	Map.Reset();
	return Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
