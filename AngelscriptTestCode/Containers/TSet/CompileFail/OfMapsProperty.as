/**
 * @version v1
 * @summary Nested TSet<TMap<int, int>> as a UPROPERTY is rejected.
 * @topic Containers
 *
 * OfMapsProperty
 */
/**
 * @begin OfMapsProperty
 * @summary Nested TSet<TMap<int, int>> as a UPROPERTY is rejected.
 * @topic Containers
 */
UCLASS()
class UTSetOfMapsPropertyReject : UObject
{
	UPROPERTY()
	TSet<TMap<int, int>> Nested;
}
/** @end */
