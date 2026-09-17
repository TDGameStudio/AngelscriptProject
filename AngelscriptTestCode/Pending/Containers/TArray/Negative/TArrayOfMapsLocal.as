/**
 * @version v1
 * @summary Nested TArray of TMap as a local is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TArray of TMap as a local is rejected.
 * @topic Baseline
 */
namespace TArrayTest
{
	void Test()
	{
		TArray<TMap<int, FString>> Rows;
	}
}
/** @end */
