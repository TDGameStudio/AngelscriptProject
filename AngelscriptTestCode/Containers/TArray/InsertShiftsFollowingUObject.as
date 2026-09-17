/**
 * @version v1
 * @summary Insert at an index shifts following UObject handles and default Insert prepends.
 * @topic Containers
 *
 * InsertShiftsFollowingUObject
 */
/**
 * @begin InsertShiftsFollowingUObject
 * @summary Insert at an index shifts following UObject handles and default Insert prepends.
 * @topic Containers
 */
UCLASS()
class UTArrayInsertShiftsFollowingUObjectHost : UObject
{
}

bool InsertShiftsFollowingUObject()
{
	TArray<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTArrayInsertShiftsFollowingUObjectHost::StaticClass(), n"InsertShiftsFollowing_First", true);
	UObject Third = NewObject(GetTransientPackage(), UTArrayInsertShiftsFollowingUObjectHost::StaticClass(), n"InsertShiftsFollowing_Third", true);
	UObject Mid = NewObject(GetTransientPackage(), UTArrayInsertShiftsFollowingUObjectHost::StaticClass(), n"InsertShiftsFollowing_Mid", true);
	UObject Head = NewObject(GetTransientPackage(), UTArrayInsertShiftsFollowingUObjectHost::StaticClass(), n"InsertShiftsFollowing_Head", true);
	Values.Add(First);
	Values.Add(Third);
	Values.Insert(Mid, 1);
	bool bInsertedAtOne = Values.Num() == 3 && Values[0] == First && Values[1] == Mid && Values[2] == Third;
	Values.Insert(Head);
	return bInsertedAtOne && Values[0] == Head && Values.Num() == 4;
}
/** @end */
