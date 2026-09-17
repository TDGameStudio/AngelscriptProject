/**
 * @version v1
 * @summary A const&in TArray<UObject> reports Num of three distinct handles.
 * @topic Containers
 *
 * ReadNumCountsElementsUObject
 */
/**
 * @begin ReadNumCountsElementsUObject
 * @summary A const&in TArray<UObject> reports Num of three distinct handles.
 * @topic Containers
 */
UCLASS()
class UTArrayReadNumCountsElementsUObjectHost : UObject
{
}

bool ReadNumCountsElementsUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 3
		&& Values[0] != nullptr && Values[1] != nullptr && Values[2] != nullptr
		&& Values[0] != Values[1] && Values[1] != Values[2] && Values[0] != Values[2];
}
/** @end */
