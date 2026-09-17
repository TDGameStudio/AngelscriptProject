/**
 * @version v1
 * @summary Nested TSet of TSet of TSet as a UPROPERTY is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TSet of TSet of TSet as a UPROPERTY is rejected.
 * @topic Baseline
 */
UCLASS()
class UTSetNestedPropertyDeepReject : UObject
{
	UPROPERTY()
	TSet<TSet<TSet<int>>> Nested;
}
/** @end */
