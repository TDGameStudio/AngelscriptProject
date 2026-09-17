/**
 * @version v1
 * @summary Nested TSet<TArray<int>> as a UPROPERTY is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TSet<TArray<int>> as a UPROPERTY is rejected.
 * @topic Baseline
 */
UCLASS()
class UTSetOfArraysPropertyReject : UObject
{
	UPROPERTY()
	TSet<TArray<int>> Nested;
}
/** @end */
