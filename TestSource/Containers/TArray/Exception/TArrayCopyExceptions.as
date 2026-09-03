/**
 * Copy throws on self-copy, negative Count, or a source/target range that
 * does not already fit. Destination slots must exist before Copy.
 *
 * @Theme Containers.TArray
 * @Subject TArray.Copy
 * @Harness RuntimeException
 * @Tag Containers.TArray.TArrayCopyExceptions
 * @Namespace TArrayTest
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

	/**
	 * Copy with a negative Count throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Copy
	 * @Inputs Source [10]; Dest [0]; Copy(Source, 0, -1, 0)
	 * @Return void; throws "Count should not be negative."
	 * @Boundary Count < 0
	 */
	UFUNCTION()
	void CopyNegativeCount()
	{
		TArray<int> Source;
		Source.Add(10);
		TArray<int> Dest;
		Dest.Add(0);
		Dest.Copy(Source, 0, -1, 0);
	}

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

	/**
	 * Copy when the dest slice does not already exist throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Copy
	 * @Inputs Source [10]; empty Dest; Copy(Source, 0, 1, 0)
	 * @Return void; throws "Target array out of bounds."
	 * @Boundary TargetIndex + Count > Dest.Num()
	 */
	UFUNCTION()
	void CopyTargetOutOfBounds()
	{
		TArray<int> Source;
		Source.Add(10);
		TArray<int> Dest;
		Dest.Copy(Source, 0, 1, 0);
	}
}
