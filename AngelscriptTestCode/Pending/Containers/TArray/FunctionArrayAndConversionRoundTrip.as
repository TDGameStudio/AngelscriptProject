/**
 * @version v1
 * @summary TArray<FLinearColor> as a UFUNCTION value, plus FColor packed conversion extras that the original file carried with the array round trip.
 * @topic Containers
 */
/**
 * @version root
 * @summary TArray<FLinearColor> as a UFUNCTION value, plus FColor packed conversion extras that the original file carried with the array round trip.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Observe local TArray<FLinearColor> after Add, then copy independence.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Inputs Add Red, (0.25,0.5,0.75,1), clamped Blue; copy two arrays; write [0]
	 * @Return true when elements match and copies do not alias
	 */
	UFUNCTION()
	bool ColorArrayHoldsAddedValuesAndCopiesIndependently()
	{
		TArray<FLinearColor> Values;
		Values.Add(FLinearColor::Red);
		Values.Add(FLinearColor(0.25f, 0.5f, 0.75f, 1.0f));
		FLinearColor Blue = FLinearColor::Blue;
		Values.Add(Blue.GetClamped());
		if (Values.Num() != 3
			|| Values[0] != FLinearColor::Red
			|| !Values[1].Equals(FLinearColor(0.25f, 0.5f, 0.75f, 1.0f), 0.001f)
			|| Values[2] != FLinearColor::Blue)
		{
			return false;
		}

		TArray<FLinearColor> First = Values;
		TArray<FLinearColor> Second = Values;
		First[0] = FLinearColor::Green;
		return Second[0] == FLinearColor::Red && First[0] == FLinearColor::Green;
	}

	/**
	 * In-only: sum colors received as const TArray<FLinearColor>&in.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<FLinearColor>&in
	 * @Inputs Values == [(0.1,0.2,0.3,0.4), (0.2,0.3,0.4,0.5)]
	 * @Return FLinearColor(0.3, 0.5, 0.7, 0.9)
	 */
	UFUNCTION()
	FLinearColor SumColorArray(const TArray<FLinearColor>&in Values)
	{
		FLinearColor Total = FLinearColor::Transparent;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			Total += Values[Index];
		}
		return Total;
	}

	/**
	 * Out-only: fill an empty &out color array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Result Destination received as TArray<FLinearColor>&out
	 * @Inputs Empty &out TArray<FLinearColor>
	 * @Return void; Result becomes [Red, (0.25,0.5,0.75,1), Blue]
	 */
	UFUNCTION()
	void FillColorArray(TArray<FLinearColor>&out Result)
	{
		Result.Add(FLinearColor::Red);
		Result.Add(FLinearColor(0.25f, 0.5f, 0.75f, 1.0f));
		Result.Add(FLinearColor::Blue);
	}

	/**
	 * Return a TArray<FLinearColor> from a UFUNCTION.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Inputs none
	 * @Return TArray with Red, (0.25,0.5,0.75,1), Blue
	 */
	UFUNCTION()
	TArray<FLinearColor> ReturnColorArray()
	{
		TArray<FLinearColor> Values;
		Values.Add(FLinearColor::Red);
		Values.Add(FLinearColor(0.25f, 0.5f, 0.75f, 1.0f));
		Values.Add(FLinearColor::Blue);
		return Values;
	}

	/**
	 * Packed FColor::Red converts to a linear red.
	 *
	 * @Kind Observe
	 * @Covers FColor conversion
	 * @Inputs FColor::Red through FLinearColor constructor and ReinterpretAsLinear
	 * @Return true when constructor red channel is near 1 and green/blue near 0
	 */
	UFUNCTION()
	bool PackedRedConvertsToLinearRed()
	{
		FLinearColor FromPacked = FLinearColor(FColor::Red);
		return FromPacked.R > 0.99f && FromPacked.G < 0.01f && FromPacked.B < 0.01f;
	}
}
/** @end */
