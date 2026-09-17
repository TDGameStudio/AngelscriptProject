/**
 * @version v1
 * @summary Reset clears every UObject member so Num is 0.
 * @topic Containers
 *
 * ResetClearsNumUObject
 */
/**
 * @begin ResetClearsNumUObject
 * @summary Reset clears every UObject member so Num is 0.
 * @topic Containers
 */
UCLASS()
class UTSetResetClearsNumUObjectHost : UObject
{
}

bool ResetClearsNumUObject()
{
	TSet<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTSetResetClearsNumUObjectHost::StaticClass(), n"ResetClearsNum_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTSetResetClearsNumUObjectHost::StaticClass(), n"ResetClearsNum_Second", true);
	Values.Add(First);
	Values.Add(Second);
	Values.Reset();
	return Values.IsEmpty() && Values.Num() == 0 && !Values.Contains(First);
}
/** @end */
