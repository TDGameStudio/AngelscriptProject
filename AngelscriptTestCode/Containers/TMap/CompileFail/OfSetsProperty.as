/**
 * @version v1
 * @summary TMap whose value is TSet as a UPROPERTY is rejected.
 * @topic Containers
 *
 * OfSetsProperty
 */
/**
 * @begin OfSetsProperty
 * @summary TMap whose value is TSet as a UPROPERTY is rejected.
 * @topic Containers
 */
UCLASS()
class UTMapOfSetsPropertyReject : UObject
{
	UPROPERTY()
	TMap<int, TSet<int>> Groups;
}
/** @end */
