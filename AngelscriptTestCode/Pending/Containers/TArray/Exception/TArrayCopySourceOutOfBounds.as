/**
 * @version v1
 * @summary Copy throws "Source array out of bounds." when the source slice does not fit.
 * @topic Containers
 */
/**
 * @version root
 * @summary Copy throws "Source array out of bounds." when SourceIndex + Count exceeds Source.Num().
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Copy when the source slice runs past Source.Num throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Copy
	 * @Inputs Source [10]; Dest [0, 0]; Copy(Source, 0, 2, 0)
	 * @Return void; throws "Source array out of bounds."
	 * @Boundary SourceIndex + Count > Source.Num()
	 */
	UFUNCTION()
	void CopySourceOutOfBounds()
	{
		TArray<int> Source;
		Source.Add(10);
		TArray<int> Dest;
		Dest.Add(0);
		Dest.Add(0);
		Dest.Copy(Source, 0, 2, 0);
	}
}
/** @end */
/**
 * @version empty-index
 * @parent root
 * @summary Copy throws "Source array out of bounds." when the source is empty and Count is 1.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Copy one element from an empty source throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Copy
	 * @Inputs Empty Source; Dest [0]; Copy(Source, 0, 1, 0)
	 * @Return void; throws "Source array out of bounds."
	 * @Boundary Source.Num() == 0 and Count > 0
	 */
	UFUNCTION()
	void CopySourceEmptyIndex()
	{
		TArray<int> Source;
		TArray<int> Dest;
		Dest.Add(0);
		Dest.Copy(Source, 0, 1, 0);
	}
}
/** @end */
