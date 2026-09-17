/**
 * @version v1
 * @summary Nested TSet of TSet of TSet as a UPROPERTY is rejected.
 * @topic Containers
 *
 * NestedPropertyDeep
 */
/**
 * @begin NestedPropertyDeep
 * @summary Nested TSet of TSet of TSet as a UPROPERTY is rejected.
 * @topic Containers
 */
UCLASS()
class UTSetNestedPropertyDeepReject : UObject
{
	UPROPERTY()
	TSet<TSet<TSet<int>>> Nested;
}
/** @end */
