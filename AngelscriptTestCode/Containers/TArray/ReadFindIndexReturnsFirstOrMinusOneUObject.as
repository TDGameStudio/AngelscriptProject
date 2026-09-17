/**
 * @version v1
 * @summary A const&in TArray<UObject> reports FindIndex first match by identity.
 * @topic Containers
 *
 * ReadFindIndexReturnsFirstOrMinusOneUObject
 */
/**
 * @begin ReadFindIndexReturnsFirstOrMinusOneUObject
 * @summary A const&in TArray<UObject> reports FindIndex first match by identity.
 * @topic Containers
 */
UCLASS()
class UTArrayReadFindIndexReturnsFirstOrMinusOneUObjectHost : UObject
{
}

bool ReadFindIndexReturnsFirstOrMinusOneUObject(const TArray<UObject>&in Values)
{
	return Values.Num() >= 3
		&& Values.FindIndex(Values[0]) == 0
		&& Values.FindIndex(Values[1]) == 1
		&& Values.FindIndex(Values[2]) == 0;
}
/** @end */
