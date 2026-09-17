/**
 * @version v1
 * @summary Nested TMap of TMap of TMap as a UPROPERTY is rejected.
 * @topic Containers
 *
 * NestedPropertyDeep
 */
/**
 * @begin NestedPropertyDeep
 * @summary Nested TMap of TMap of TMap as a UPROPERTY is rejected.
 * @topic Containers
 */
UCLASS()
class UTMapNestedPropertyDeepReject : UObject
{
	UPROPERTY()
	TMap<int, TMap<int, TMap<int, int>>> Nested;
}
/** @end */
