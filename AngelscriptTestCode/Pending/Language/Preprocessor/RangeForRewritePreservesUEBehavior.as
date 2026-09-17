/**
 * @version v1
 * @summary The range-for rewrite converts range-based loops into an index-based form. Text that merely looks like a range-for — inside a string literal or a comment — must be left alone, while real loops over arrays and maps still.
 * @topic Language
 */
/**
 * @version root
 * @summary The range-for rewrite converts range-based loops into an index-based form. Text that merely looks like a range-for — inside a string literal or a comment — must be left alone, while real loops over arrays and maps still.
 * @topic Baseline
 */
namespace PreprocessorTest
{
	/**
	 * Walks an array, a map and a C-style loop, while holding literal and
	 * commented loop text that must not be rewritten.
	 *
	 * @Covers Preprocessor.Rewrites
	 * @Inputs an int array and a string-to-int map
	 * @Param Values the array walked by the first range-for
	 * @Param Lookup the map walked by the second range-for
	 * @Return nothing
	 */
	void Iterate(const TArray<int>&in Values, const TMap<FString, int>&in Lookup)
	{
		FString Preserved = "for (int Fake : Values)";
		// for (int Commented : Values) {}

		for (int Value : Values)
		{
			Print(f"{Value}");
		}

		for (auto Element : Lookup)
		{
			Print(Element.GetKey());
		}

		for (int Index = 0; Index < 1; ++Index)
		{
			Print(f"{Index}");
		}
	}

	/**
	 * Observe that walking empty containers leaves them empty.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Rewrites
	 * @Inputs an empty array and an empty map
	 * @Return 0, the combined element count
	 * @Boundary empty containers
	 */
	UFUNCTION()
	int IterateEmptyDefault()
	{
		TArray<int> Values;
		TMap<FString, int> Lookup;
		Iterate(Values, Lookup);
		return Values.Num() + Lookup.Num();
	}

	/**
	 * Observe that walking populated containers preserves their contents.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Rewrites
	 * @Inputs a two-element array and a one-entry map
	 * @Return 3, the combined element count
	 */
	UFUNCTION()
	int IteratePopulatedPreservesCounts()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		TMap<FString, int> Lookup;
		Lookup.Add("A", 3);
		Iterate(Values, Lookup);
		return Values.Num() + Lookup.Num();
	}

	/**
	 * Observe that a copy taken before the walk is unaffected by it.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Rewrites
	 * @Inputs a copy of a one-element array, taken before the walk
	 * @Return the walked array's count, or 0 when the copy was disturbed
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int IterateCopyIndependence()
	{
		TArray<int> Values;
		Values.Add(4);
		TArray<int> Copy = Values;
		TMap<FString, int> Lookup;
		Iterate(Values, Lookup);

		if (Copy.Num() != 1)
		{
			return 0;
		}

		if (Copy[0] != 4)
		{
			return 0;
		}

		return Values.Num();
	}
}
/** @end */
