/**
 * @version v1
 * @summary Empty clears every UObject pair so Num is 0.
 * @topic Containers
 *
 * EmptyClearsNumUObject
 */
/**
 * @begin EmptyClearsNumUObject
 * @summary Empty clears every UObject pair so Num is 0.
 * @topic Containers
 */
UCLASS()
class UTMapEmptyClearsNumUObjectHost : UObject
{
}

bool EmptyClearsNumUObject()
{
	TMap<int, UObject> Map;
	UObject First = NewObject(GetTransientPackage(), UTMapEmptyClearsNumUObjectHost::StaticClass(), n"EmptyClears_First", true);
	if (First == nullptr)
	{
		return false;
	}
	Map.Add(10, First);
	Map.Empty();
	bool bDefaultEmpty = Map.IsEmpty();
	Map.Add(10, First);
	Map.Empty(4);
	return bDefaultEmpty && Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
