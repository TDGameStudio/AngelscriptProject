/**
 * @version v1
 * @summary Nested TMap<int, TMap<int, int>> as a UFUNCTION return is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TMap<int, TMap<int, int>> as a UFUNCTION return is rejected.
 * @topic Baseline
 */
namespace TMapTest
{
	UFUNCTION()
	TMap<int, TMap<int, int>> MakeNestedMap()
	{
		TMap<int, TMap<int, int>> Values;
		return Values;
	}
}
/** @end */
