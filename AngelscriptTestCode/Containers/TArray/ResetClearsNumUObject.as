/**
 * @version v1
 * @summary Reset clears UObject Num to 0 and Reset(4) retains Max of at least 4.
 * @topic Containers
 *
 * ResetClearsNumUObject
 */
/**
 * @begin ResetClearsNumUObject
 * @summary Reset clears UObject Num to 0 and Reset(4) retains Max of at least 4.
 * @topic Containers
 */
UCLASS()
class UTArrayResetClearsNumUObjectHost : UObject
{
}

bool ResetClearsNumUObject()
{
	TArray<UObject> Values;
	Values.Add(NewObject(GetTransientPackage(), UTArrayResetClearsNumUObjectHost::StaticClass(), n"ResetClearsNum_0", true));
	Values.Add(NewObject(GetTransientPackage(), UTArrayResetClearsNumUObjectHost::StaticClass(), n"ResetClearsNum_1", true));
	Values.Reset();
	bool bDefaultReset = Values.IsEmpty();
	Values.Add(NewObject(GetTransientPackage(), UTArrayResetClearsNumUObjectHost::StaticClass(), n"ResetClearsNum_2", true));
	Values.Reset(4);
	return bDefaultReset && Values.IsEmpty() && Values.Max() >= 4;
}
/** @end */
