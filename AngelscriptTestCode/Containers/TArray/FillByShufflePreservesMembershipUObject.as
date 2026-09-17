/**
 * @version v1
 * @summary An &out TArray<UObject> is filled then Shuffle permutes handles.
 * @topic Containers
 *
 * FillByShufflePreservesMembershipUObject
 */
/**
 * @begin FillByShufflePreservesMembershipUObject
 * @summary An &out TArray<UObject> is filled then Shuffle permutes handles.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByShufflePreservesMembershipUObjectHost : UObject
{
}

void FillByShufflePreservesMembershipUObject(TArray<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByShufflePreservesMembershipUObjectHost::StaticClass(), n"FillByShuffle_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByShufflePreservesMembershipUObjectHost::StaticClass(), n"FillByShuffle_1", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByShufflePreservesMembershipUObjectHost::StaticClass(), n"FillByShuffle_2", true));
	Result.Shuffle();
}
/** @end */
