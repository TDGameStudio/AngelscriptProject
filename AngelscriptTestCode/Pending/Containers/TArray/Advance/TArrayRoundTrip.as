/**
 * @version v1
 * @summary Generic UFUNCTION payload [1, 2, 3, 4, 5]. Protocol files also expose their own const&in / &out / &inout / return so C++ can assert writeback.
 * @topic Containers
 */
/**
 * @version root
 * @summary Generic UFUNCTION payload [1, 2, 3, 4, 5]. Protocol files also expose their own const&in / &out / &inout / return so C++ can assert writeback.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * In-only: read the Advance sequence from const&in.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [1, 2, 3, 4, 5]
	 * @Return true when Num() == 5 and elements are [1, 2, 3, 4, 5]
	 */
	UFUNCTION()
	bool ReadAdvanceSequence(const TArray<int>&in Values)
	{
		return Values.Num() == 5
			&& Values[0] == 1 && Values[1] == 2 && Values[2] == 3
			&& Values[3] == 4 && Values[4] == 5;
	}

	/**
	 * Out-only: fill an empty &out array with the Advance sequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [1, 2, 3, 4, 5]
	 */
	UFUNCTION()
	void FillAdvanceSequence(TArray<int>&out Result)
	{
		Result.Add(1);
		Result.Add(2);
		Result.Add(3);
		Result.Add(4);
		Result.Add(5);
	}

	/**
	 * Inout: append 4 and 5 onto an existing [1, 2, 3].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Array received as TArray<int>&inout, starts as [1, 2, 3]
	 * @Inputs Values.Num() == 3 with [1, 2, 3]
	 * @Return void; Values becomes [1, 2, 3, 4, 5]
	 */
	UFUNCTION()
	void AppendAdvanceSequence(TArray<int>&inout Values)
	{
		Values.Add(4);
		Values.Add(5);
	}

	/**
	 * Return a TArray<int> from a UFUNCTION. Same payload as FillAdvanceSequence.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Inputs none
	 * @Return TArray [1, 2, 3, 4, 5]
	 */
	UFUNCTION()
	TArray<int> ReturnAdvanceSequence()
	{
		TArray<int> Result;
		Result.Add(1);
		Result.Add(2);
		Result.Add(3);
		Result.Add(4);
		Result.Add(5);
		return Result;
	}
}
/** @end */
