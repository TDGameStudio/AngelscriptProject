/**
 * @version v1
 * @summary Nested TSet<TArray<int>> as a UPROPERTY is rejected.
 * @topic Containers
 *
 * OfArraysProperty
 */
/**
 * @begin OfArraysProperty
 * @summary Nested TSet<TArray<int>> as a UPROPERTY is rejected.
 * @topic Containers
 */
UCLASS()
class UTSetOfArraysPropertyReject : UObject
{
	UPROPERTY()
	TSet<TArray<int>> Nested;
}
/** @end */
