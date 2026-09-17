/**
 * @version v1
 * @summary An &inout TArray<UObject> receives Insert of one NewObject handle.
 * @topic Containers
 *
 * MutateInsertShiftsFollowingUObject
 */
/**
 * @begin MutateInsertShiftsFollowingUObject
 * @summary An &inout TArray<UObject> receives Insert of one NewObject handle.
 * @topic Containers
 */
UCLASS()
class UTArrayMutateInsertShiftsFollowingUObjectHost : UObject
{
}

void MutateInsertShiftsFollowingUObject(TArray<UObject>&inout Values)
{
	Values.Insert(NewObject(GetTransientPackage(), UTArrayMutateInsertShiftsFollowingUObjectHost::StaticClass(), n"MutateInsert_Mid", true), 1);
}
/** @end */
