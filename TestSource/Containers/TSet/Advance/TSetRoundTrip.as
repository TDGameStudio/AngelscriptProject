/**
 * Generic UFUNCTION payload [10, 20, 30, 40, 50].
 * Protocol files also expose their own const&in / &out / &inout / return so
 * C++ can assert writeback. Equality is by members, not insertion order.
 *
 * @Theme Containers.TSet
 * @Subject TSet.RoundTrip
 * @Harness Advance
 * @Tag Containers.TSet.TSetRoundTrip
 * @Namespace TSetTest
 */

namespace TSetTest
{
	/**
	 * In-only: read the Advance payload from const&in.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs Values has members 10..50 step 10
	 * @Return true when Num() == 5 and each member is present
	 */
	UFUNCTION()
	bool ReadAdvancePayload(const TSet<int>&in Values)
	{
		return Values.Num() == 5
			&& Values.Contains(10) && Values.Contains(20) && Values.Contains(30)
			&& Values.Contains(40) && Values.Contains(50);
	}

	/**
	 * Out-only: fill an empty &out set with the Advance payload.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Result Destination received as TSet<int>&out
	 * @Inputs Empty &out TSet<int>
	 * @Return void; Result has members 10..50 step 10
	 */
	UFUNCTION()
	void FillAdvancePayload(TSet<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
		Result.Add(40);
		Result.Add(50);
	}

	/**
	 * Inout: add 40 and 50 onto an existing [10, 20, 30].
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Set received as TSet<int>&inout, starts with 10/20/30
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 5
	 */
	UFUNCTION()
	void AppendAdvancePayload(TSet<int>&inout Values)
	{
		Values.Add(40);
		Values.Add(50);
	}

	/**
	 * Return a TSet<int> from a UFUNCTION. Same payload as FillAdvancePayload.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Inputs none
	 * @Return TSet with members 10..50 step 10
	 */
	UFUNCTION()
	TSet<int> ReturnAdvancePayload()
	{
		TSet<int> Result;
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
		Result.Add(40);
		Result.Add(50);
		return Result;
	}
}
