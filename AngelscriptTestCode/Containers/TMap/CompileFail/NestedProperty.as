/**
 * @version v1
 * @summary Nested TMap<int, TMap<int, int>> as a UPROPERTY is rejected.
 * @topic Containers
 *
 * NestedProperty
 */
/**
 * @begin NestedProperty
 * @summary Nested TMap<int, TMap<int, int>> as a UPROPERTY is rejected.
 * @topic Containers
 */
UCLASS()
class UTMapNestedPropertyReject : UObject
{
	UPROPERTY()
	TMap<int, TMap<int, int>> Nested;
}
/** @end */
