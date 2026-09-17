/**
 * @version v1
 * @summary Empty clears every UObject member so Num is 0.
 * @topic Containers
 *
 * EmptyClearsNumUObject
 */
/**
 * @begin EmptyClearsNumUObject
 * @summary Empty clears every UObject member so Num is 0.
 * @topic Containers
 */
UCLASS()
class UTSetEmptyClearsNumUObjectHost : UObject
{
}

bool EmptyClearsNumUObject()
{
	TSet<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTSetEmptyClearsNumUObjectHost::StaticClass(), n"EmptyClearsNum_First", true);
	Values.Add(First);
	Values.Empty();
	return Values.IsEmpty() && Values.Num() == 0 && !Values.Contains(First);
}
/** @end */
