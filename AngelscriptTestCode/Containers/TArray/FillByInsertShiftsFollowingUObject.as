/**
 * @version v1
 * @summary An &out TArray<UObject> is filled by Insert of NewObject handles.
 * @topic Containers
 *
 * FillByInsertShiftsFollowingUObject
 */
/**
 * @begin FillByInsertShiftsFollowingUObject
 * @summary An &out TArray<UObject> is filled by Insert of NewObject handles.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByInsertShiftsFollowingUObjectHost : UObject
{
}

void FillByInsertShiftsFollowingUObject(TArray<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByInsertShiftsFollowingUObjectHost::StaticClass(), n"FillByInsert_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByInsertShiftsFollowingUObjectHost::StaticClass(), n"FillByInsert_1", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByInsertShiftsFollowingUObjectHost::StaticClass(), n"FillByInsert_2", true));
	Result.Insert(NewObject(GetTransientPackage(), UTArrayFillByInsertShiftsFollowingUObjectHost::StaticClass(), n"FillByInsert_Mid", true), 1);
}
/** @end */
