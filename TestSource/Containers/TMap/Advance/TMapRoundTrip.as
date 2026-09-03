/**
 * Generic UFUNCTION payload [10->100, 20->200, 30->300, 40->400, 50->500].
 * Protocol files also expose their own const&in / &out / &inout / return so
 * C++ can assert writeback. Equality is by pairs, not insertion order.
 *
 * @Theme Containers.TMap
 * @Subject TMap.RoundTrip
 * @Harness Advance
 * @Tag Containers.TMap.TMapRoundTrip
 * @Namespace TMapTest
 */

namespace TMapTest
{
	/**
	 * In-only: read the Advance payload from const&in.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs Values has keys 10..50 step 10
	 * @Return true when Num() == 5 and each key maps to key*10
	 */
	UFUNCTION()
	bool ReadAdvancePayload(const TMap<int, int>&in Values)
	{
		return Values.Num() == 5
			&& Values[10] == 100 && Values[20] == 200 && Values[30] == 300
			&& Values[40] == 400 && Values[50] == 500;
	}

	/**
	 * Out-only: fill an empty &out map with the Advance payload.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result has keys 10..50 step 10
	 */
	UFUNCTION()
	void FillAdvancePayload(TMap<int, int>&out Result)
	{
		Result.Add(10, 100);
		Result.Add(20, 200);
		Result.Add(30, 300);
		Result.Add(40, 400);
		Result.Add(50, 500);
	}

	/**
	 * Inout: add 40 and 50 onto an existing [10, 20, 30].
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Map received as TMap<int, int>&inout, starts with 10/20/30
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() == 5
	 */
	UFUNCTION()
	void AppendAdvancePayload(TMap<int, int>&inout Values)
	{
		Values.Add(40, 400);
		Values.Add(50, 500);
	}

	/**
	 * Return a TMap<int, int> from a UFUNCTION. Same payload as FillAdvancePayload.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Inputs none
	 * @Return TMap with keys 10..50 step 10
	 */
	UFUNCTION()
	TMap<int, int> ReturnAdvancePayload()
	{
		TMap<int, int> Result;
		Result.Add(10, 100);
		Result.Add(20, 200);
		Result.Add(30, 300);
		Result.Add(40, 400);
		Result.Add(50, 500);
		return Result;
	}
}
