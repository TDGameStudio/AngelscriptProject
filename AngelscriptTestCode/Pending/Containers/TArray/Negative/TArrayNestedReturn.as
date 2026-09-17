/**
 * @version v1
 * @summary Nested TArray<TArray<int>> as a UFUNCTION return type is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TArray<TArray<int>> as a UFUNCTION return type is rejected.
 * @topic Baseline
 */
namespace TArrayTest
{
	UFUNCTION()
	TArray<TArray<int>> MakeNestedArray()
	{
		TArray<TArray<int>> Result;
		return Result;
	}
}
/** @end */
