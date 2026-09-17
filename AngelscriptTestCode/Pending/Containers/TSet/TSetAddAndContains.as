/**
 * @version v1
 * @summary Add inserts a member that Contains then reports as present.
 * @topic Containers
 */
/**
 * @version root
 * @summary Add inserts a member that Contains then reports as present.
 * @topic Baseline
 */
namespace TSetTest
{
	/**
	 * Observe Add then Contains: the added member is present.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Inputs Default-constructed TSet<int>; Add(10); Contains(10)
	 * @Return true when Num() is 1 and Contains(10) is true
	 */
	UFUNCTION()
	bool AddInsertsMemberThatContains()
	{
		TSet<int> Values;
		Values.Add(10);
		return Values.Num() == 1 && Values.Contains(10);
	}
}
/** @end */
