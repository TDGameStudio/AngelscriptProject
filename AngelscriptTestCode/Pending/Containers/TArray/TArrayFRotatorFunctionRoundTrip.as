/**
 * @version v1
 * @summary TArray<FRotator> as a UFUNCTION value: local Observe, const&in, &out, and return.
 * @topic Containers
 */
/**
 * @version root
 * @summary TArray<FRotator> as a UFUNCTION value: local Observe, const&in, &out, and return.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Observe local TArray<FRotator> after Add.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Inputs Add ZeroRotator, (0,90,0), normalized (10,20,30)
	 * @Return true when Num() == 3 and elements Equals those rotators
	 */
	UFUNCTION()
	bool RotatorArrayHoldsAddedValues()
	{
		TArray<FRotator> Values;
		Values.Add(FRotator::ZeroRotator);
		Values.Add(FRotator(0.0f, 90.0f, 0.0f));
		Values.Add(FRotator(10.0f, 20.0f, 30.0f).GetNormalized());
		return Values.Num() == 3
			&& Values[0].Equals(FRotator::ZeroRotator, 0.001f)
			&& Values[1].Equals(FRotator(0.0f, 90.0f, 0.0f), 0.001f)
			&& Values[2].Equals(FRotator(10.0f, 20.0f, 30.0f), 0.001f);
	}

	/**
	 * In-only: sum rotators received as const TArray<FRotator>&in.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<FRotator>&in
	 * @Inputs Values == [(1,2,3), (4,5,6)]
	 * @Return FRotator(5,7,9)
	 */
	UFUNCTION()
	FRotator SumRotatorArray(const TArray<FRotator>&in Values)
	{
		FRotator Total = FRotator::ZeroRotator;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			Total += Values[Index];
		}
		return Total;
	}

	/**
	 * Out-only: fill an empty &out rotator array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Result Destination received as TArray<FRotator>&out
	 * @Inputs Empty &out TArray<FRotator>
	 * @Return void; Result becomes [Zero, (0,90,0), (10,20,30)]
	 */
	UFUNCTION()
	void FillRotatorArray(TArray<FRotator>&out Result)
	{
		Result.Add(FRotator::ZeroRotator);
		Result.Add(FRotator(0.0f, 90.0f, 0.0f));
		Result.Add(FRotator(10.0f, 20.0f, 30.0f));
	}

	/**
	 * Return a TArray<FRotator> from a UFUNCTION.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Inputs none
	 * @Return TArray with Zero, (0,90,0), (10,20,30)
	 */
	UFUNCTION()
	TArray<FRotator> ReturnRotatorArray()
	{
		TArray<FRotator> Values;
		Values.Add(FRotator::ZeroRotator);
		Values.Add(FRotator(0.0f, 90.0f, 0.0f));
		Values.Add(FRotator(10.0f, 20.0f, 30.0f));
		return Values;
	}
}
/** @end */
