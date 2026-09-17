/**
 * @version v1
 * @summary TMap whose value is TArray as a UPROPERTY is rejected.
 * @topic Containers
 *
 * OfArraysProperty
 */
/**
 * @begin OfArraysProperty
 * @summary TMap whose value is TArray as a UPROPERTY is rejected.
 * @topic Containers
 */
UCLASS()
class UTMapOfArraysPropertyReject : UObject
{
	UPROPERTY()
	TMap<int, TArray<int>> Groups;
}
/** @end */
