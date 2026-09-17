/**
 * @version v1
 * @summary Nested TSet<TSet<int>> as a UFUNCTION return is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TSet<TSet<int>> as a UFUNCTION return is rejected.
 * @topic Baseline
 */
namespace TSetTest
{
	UFUNCTION()
	TSet<TSet<int>> MakeNestedSet()
	{
		TSet<TSet<int>> Values;
		return Values;
	}
}
/** @end */
