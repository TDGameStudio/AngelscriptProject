/**
 * @version v1
 * @summary Shuffle keeps Num and membership of every original UObject handle.
 * @topic Containers
 *
 * ShufflePreservesMembershipUObject
 */
/**
 * @begin ShufflePreservesMembershipUObject
 * @summary Shuffle keeps Num and membership of every original UObject handle.
 * @topic Containers
 */
UCLASS()
class UTArrayShufflePreservesMembershipUObjectHost : UObject
{
}

bool ShufflePreservesMembershipUObject()
{
	TArray<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTArrayShufflePreservesMembershipUObjectHost::StaticClass(), n"Shuffle_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayShufflePreservesMembershipUObjectHost::StaticClass(), n"Shuffle_Second", true);
	UObject Third = NewObject(GetTransientPackage(), UTArrayShufflePreservesMembershipUObjectHost::StaticClass(), n"Shuffle_Third", true);
	Values.Add(First);
	Values.Add(Second);
	Values.Add(Third);
	Values.Shuffle();
	return Values.Num() == 3 && Values.Contains(First) && Values.Contains(Second) && Values.Contains(Third);
}
/** @end */
