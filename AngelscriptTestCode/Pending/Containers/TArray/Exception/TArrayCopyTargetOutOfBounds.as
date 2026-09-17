/**
 * @version v1
 * @summary Copy throws "Target array out of bounds." when dest slots do not already exist.
 * @topic Containers
 */
/**
 * @version root
 * @summary Copy throws "Target array out of bounds." when TargetIndex + Count exceeds Dest.Num().
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Copy when dest does not already have enough slots throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Copy
	 * @Inputs Source [10, 20]; Dest [0]; Copy(Source, 0, 2, 0)
	 * @Return void; throws "Target array out of bounds."
	 * @Boundary TargetIndex + Count > Dest.Num()
	 */
	UFUNCTION()
	void CopyTargetOutOfBounds()
	{
		TArray<int> Source;
		Source.Add(10);
		Source.Add(20);
		TArray<int> Dest;
		Dest.Add(0);
		Dest.Copy(Source, 0, 2, 0);
	}
}
/** @end */
/**
 * @version empty-index
 * @parent root
 * @summary Copy throws "Target array out of bounds." when Dest[0] does not exist on an empty dest.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Copy one element onto empty dest [0] throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Copy
	 * @Inputs Source [10]; empty Dest; Copy(Source, 0, 1, 0)
	 * @Return void; throws "Target array out of bounds."
	 * @Boundary Dest.Num() == 0
	 */
	UFUNCTION()
	void CopyTargetEmptyIndex()
	{
		TArray<int> Source;
		Source.Add(10);
		TArray<int> Dest;
		Dest.Copy(Source, 0, 1, 0);
	}
}
/** @end */
