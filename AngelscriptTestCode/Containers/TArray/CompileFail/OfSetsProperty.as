/**
 * @version v1
 * @summary Nested TArray of TSet as a UPROPERTY is rejected.
 * @topic Containers
 *
 * OfSetsProperty
 */
/**
 * @begin OfSetsProperty
 * @summary Nested TArray of TSet as a UPROPERTY is rejected.
 * @topic Containers
 */
UCLASS()
class UTArrayOfSetsPropertyReject : UObject
{
	UPROPERTY()
	TArray<TSet<int>> Groups;
}
/** @end */
