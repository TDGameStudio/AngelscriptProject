/**
 * @version v1
 * @summary TArray<FTransform> as a UFUNCTION value: local Observe, const&in, &out, and return.
 * @topic Containers
 */
/**
 * @version root
 * @summary TArray<FTransform> as a UFUNCTION value: local Observe, const&in, &out, and return.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Observe local TArray<FTransform> after Add.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Inputs Add Identity, translation (10,20,30), scale (2,3,4)
	 * @Return true when Num() == 3 and location/scale match
	 */
	UFUNCTION()
	bool TransformArrayHoldsAddedValues()
	{
		TArray<FTransform> Values;
		Values.Add(FTransform::Identity);
		Values.Add(FTransform(FVector(10.0f, 20.0f, 30.0f)));
		Values.Add(FTransform(FQuat::Identity, FVector(1.0f, 2.0f, 3.0f), FVector(2.0f, 3.0f, 4.0f)));
		return Values.Num() == 3
			&& Values[0].Equals(FTransform::Identity, 0.001f)
			&& Values[1].GetLocation().Equals(FVector(10.0f, 20.0f, 30.0f), 0.001f)
			&& Values[2].GetScale3D().Equals(FVector(2.0f, 3.0f, 4.0f), 0.001f);
	}

	/**
	 * In-only: combine transforms received as const TArray<FTransform>&in.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<FTransform>&in
	 * @Inputs Values == [translation (1,0,0), translation (0,2,0)]
	 * @Return combined transform whose location is (1,2,0)
	 */
	UFUNCTION()
	FTransform CombineTransformArray(const TArray<FTransform>&in Values)
	{
		FTransform Result = FTransform::Identity;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			Result *= Values[Index];
		}
		return Result;
	}

	/**
	 * Out-only: fill an empty &out transform array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Result Destination received as TArray<FTransform>&out
	 * @Inputs Empty &out TArray<FTransform>
	 * @Return void; Result becomes [Identity, (10,20,30), scale (2,3,4)]
	 */
	UFUNCTION()
	void FillTransformArray(TArray<FTransform>&out Result)
	{
		Result.Add(FTransform::Identity);
		Result.Add(FTransform(FVector(10.0f, 20.0f, 30.0f)));
		Result.Add(FTransform(FQuat::Identity, FVector(1.0f, 2.0f, 3.0f), FVector(2.0f, 3.0f, 4.0f)));
	}

	/**
	 * Return a TArray<FTransform> from a UFUNCTION.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Inputs none
	 * @Return TArray with Identity, (10,20,30), scale (2,3,4)
	 */
	UFUNCTION()
	TArray<FTransform> ReturnTransformArray()
	{
		TArray<FTransform> Values;
		Values.Add(FTransform::Identity);
		Values.Add(FTransform(FVector(10.0f, 20.0f, 30.0f)));
		Values.Add(FTransform(FQuat::Identity, FVector(1.0f, 2.0f, 3.0f), FVector(2.0f, 3.0f, 4.0f)));
		return Values;
	}
}
/** @end */
