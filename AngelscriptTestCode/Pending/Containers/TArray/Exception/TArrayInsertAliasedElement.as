/**
 * @version v1
 * @summary Insert throws when the value argument aliases this array's storage.
 * @topic Containers
 */
/**
 * @version root
 * @summary Insert throws when the value argument aliases this array's storage.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Insert an element by reference from the same array throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Insert
	 * @Inputs [10]; Insert(Values[0], 1) without a local copy
	 * @Return void; throws "Cannot Insert an element from the same array by reference. Copy it to a temporary first."
	 * @Boundary value aliases array storage
	 */
	UFUNCTION()
	void InsertElementFromSameArray()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Insert(Values[0], 1);
	}
}
/** @end */
