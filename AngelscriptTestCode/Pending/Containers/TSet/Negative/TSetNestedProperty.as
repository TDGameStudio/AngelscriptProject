/**
 * @version v1
 * @summary Nested TSet<TSet<int>> as a UPROPERTY is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TSet<TSet<int>> as a UPROPERTY is rejected.
 * @topic Baseline
 */
UCLASS()
class UTSetNestedPropertyReject : UObject
{
	UPROPERTY()
	TSet<TSet<int>> Nested;
}
/** @end */
