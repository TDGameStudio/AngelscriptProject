/**
 * @version v1
 * @summary Copy throws "Cannot copy an array into itself." when source is destination.
 * @topic Containers
 */
/**
 * @version root
 * @summary Copy throws "Cannot copy an array into itself." when source is destination.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Copy from the same array into itself throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Copy
	 * @Inputs [10]; Copy(self, 0, 1, 0)
	 * @Return void; throws "Cannot copy an array into itself."
	 * @Boundary source is destination
	 */
	UFUNCTION()
	void CopySelf()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Copy(Values, 0, 1, 0);
	}
}
/** @end */
