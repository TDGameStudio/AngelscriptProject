/**
 * @version v1
 * @summary Mutating a TSet passed by value is rejected (read-only copy).
 * @topic Containers
 */
/**
 * @version root
 * @summary Mutating a TSet passed by value is rejected (read-only copy).
 * @topic Negative
 */
namespace TSetTest
{
	int MutateByValue(TSet<int> Values)
	{
		Values.Add(1);
		return Values.Num();
	}
}
/** @end */
