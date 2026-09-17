/**
 * @version v1
 * @summary Nested TMap<int, TMap<int, int>> as a UFUNCTION parameter is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TMap<int, TMap<int, int>> as a UFUNCTION parameter is rejected.
 * @topic Baseline
 */
namespace TMapTest
{
	UFUNCTION()
	void TakeNestedMap(TMap<int, TMap<int, int>> Values)
	{
	}
}
/** @end */
