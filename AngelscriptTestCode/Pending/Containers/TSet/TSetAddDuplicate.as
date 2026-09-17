/**
 * @version v1
 * @summary Adding an equal member a second time leaves Num at 1.
 * @topic Containers
 */
/**
 * @version root
 * @summary Adding an equal member a second time leaves Num at 1.
 * @topic Baseline
 */
namespace TSetTest
{
	/**
	 * Observe duplicate Add: the second Add does not grow Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Inputs Default-constructed TSet<int>; Add(10); Add(10)
	 * @Return true when Num() stays 1 and Contains(10) is true
	 */
	UFUNCTION()
	bool AddDuplicateKeepsNumOne()
	{
		TSet<int> Values;
		Values.Add(10);
		if (Values.Num() != 1 || !Values.Contains(10))
		{
			return false;
		}

		Values.Add(10);
		return Values.Num() == 1 && Values.Contains(10);
	}
}
/** @end */
