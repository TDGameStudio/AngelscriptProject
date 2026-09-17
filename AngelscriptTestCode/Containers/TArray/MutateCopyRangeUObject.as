/**
 * @version v1
 * @summary An &inout TArray<UObject> is overwritten in place by Copy.
 * @topic Containers
 *
 * MutateCopyRangeUObject
 */
/**
 * @begin MutateCopyRangeUObject
 * @summary An &inout TArray<UObject> is overwritten in place by Copy.
 * @topic Containers
 */
UCLASS()
class UTArrayMutateCopyRangeUObjectHost : UObject
{
}

void MutateCopyRangeUObject(TArray<UObject>&inout Values)
{
	TArray<UObject> Source;
	Source.Add(NewObject(GetTransientPackage(), UTArrayMutateCopyRangeUObjectHost::StaticClass(), n"MutateCopyRange_0", true));
	Source.Add(NewObject(GetTransientPackage(), UTArrayMutateCopyRangeUObjectHost::StaticClass(), n"MutateCopyRange_1", true));
	Values.Copy(Source, 0, 2, 0);
}
/** @end */
