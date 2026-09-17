/**
 * @version v1
 * @summary Nested TArray<TArray<int>> as a UPROPERTY is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TArray<TArray<int>> as a UPROPERTY is rejected.
 * @topic Baseline
 */
UCLASS()
class UTArrayNestedPropertyReject : UObject
{
	UPROPERTY()
	TArray<TArray<int>> Matrix;
}
/** @end */
