/**
 * @version v1
 * @summary Nested TSet of TSet of TSet as a local is rejected (same diagnostic as two layers).
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TSet of TSet of TSet as a local is rejected (same diagnostic as two layers).
 * @topic Baseline
 */
namespace TSetTest
{
	void Test()
	{
		TSet<TSet<TSet<int>>> Nested;
	}
}
/** @end */
