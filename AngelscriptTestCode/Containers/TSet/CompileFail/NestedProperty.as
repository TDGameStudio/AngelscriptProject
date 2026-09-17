/**
 * @version v1
 * @summary Nested TSet<TSet<int>> as a UPROPERTY is rejected.
 * @topic Containers
 *
 * NestedProperty
 */
/**
 * @begin NestedProperty
 * @summary Nested TSet<TSet<int>> as a UPROPERTY is rejected.
 * @topic Containers
 */
UCLASS()
class UTSetNestedPropertyReject : UObject
{
	UPROPERTY()
	TSet<TSet<int>> Nested;
}
/** @end */
