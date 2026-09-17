/**
 * @version v1
 * @summary Nested TSet<TSet<int>> as a UFUNCTION parameter is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TSet<TSet<int>> as a UFUNCTION parameter is rejected.
 * @topic Baseline
 */
namespace TSetTest
{
	UFUNCTION()
	void TakeNestedSet(TSet<TSet<int>> Values)
	{
	}
}
/** @end */
