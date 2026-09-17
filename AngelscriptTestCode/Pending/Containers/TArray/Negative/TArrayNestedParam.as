/**
 * @version v1
 * @summary Nested TArray<TArray<int>> as a UFUNCTION parameter is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TArray<TArray<int>> as a UFUNCTION parameter is rejected.
 * @topic Baseline
 */
namespace TArrayTest
{
	UFUNCTION()
	void TakeNestedArray(TArray<TArray<int>> Values)
	{
	}
}
/** @end */
