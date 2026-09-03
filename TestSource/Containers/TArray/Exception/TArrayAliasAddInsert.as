/**
 * Add and Insert throw when the value argument aliases this array's storage.
 * Copy the element to a temporary first; that path is the Function Observe.
 *
 * @Theme Containers.TArray
 * @Subject TArray.Add
 * @Harness RuntimeException
 * @Tag Containers.TArray.TArrayAliasAddInsert
 * @Namespace TArrayTest
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
