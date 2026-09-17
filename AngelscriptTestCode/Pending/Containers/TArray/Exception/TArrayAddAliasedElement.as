/**
 * @version v1
 * @summary Add throws when the value argument aliases this array's storage.
 * @topic Containers
 */
/**
 * @version root
 * @summary Add throws when the value argument aliases this array's storage.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Add an element by reference from the same array throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Add
	 * @Inputs [10]; Add(Values[0]) without a local copy
	 * @Return void; throws "Cannot Add an element from the same array by reference. Copy it to a temporary first."
	 * @Boundary value aliases array storage
	 */
	UFUNCTION()
	void AddElementFromSameArray()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(Values[0]);
	}
}
/** @end */
