/**
 * @version v1
 * @summary Expanded USTRUCT operators and compound assign. C++ VerifyByPath Results==25 (C=9, D=24, E=4, F=-12). Keep the UPROPERTY name Results.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Expanded USTRUCT operators and compound assign. C++ VerifyByPath Results==25 (C=9, D=24, E=4, F=-12). Keep the UPROPERTY name Results.
 * @topic Baseline
 */
USTRUCT()
struct FExpandedOperatorStruct
{
	UPROPERTY()
	int Value = 0;

	/**
	 * Subtract another instance.
	 *
	 * @Covers UStruct.UStructOperatorExpansion
	 * @Inputs another FExpandedOperatorStruct
	 * @Return Value minus Other.Value
	 * @Param Other the other instance
	 */
	FExpandedOperatorStruct opSub(const FExpandedOperatorStruct&in Other) const
	{
		FExpandedOperatorStruct Result;
		Result.Value = Value - Other.Value;
		return Result;
	}

	/**
	 * Multiply by a scalar.
	 *
	 * @Covers UStruct.UStructOperatorExpansion
	 * @Inputs a scale
	 * @Return Value * Scale
	 * @Param Scale the multiplier
	 */
	FExpandedOperatorStruct opMul(int Scale) const
	{
		FExpandedOperatorStruct Result;
		Result.Value = Value * Scale;
		return Result;
	}

	/**
	 * Divide by a scalar.
	 *
	 * @Covers UStruct.UStructOperatorExpansion
	 * @Inputs a divisor
	 * @Return Value / Divisor
	 * @Param Divisor the divisor
	 */
	FExpandedOperatorStruct opDiv(int Divisor) const
	{
		FExpandedOperatorStruct Result;
		Result.Value = Value / Divisor;
		return Result;
	}

	/**
	 * Negate Value.
	 *
	 * @Covers UStruct.UStructOperatorExpansion
	 * @Inputs none
	 * @Return -Value
	 */
	FExpandedOperatorStruct opNeg() const
	{
		FExpandedOperatorStruct Result;
		Result.Value = -Value;
		return Result;
	}

	/**
	 * Compound-add another instance into this.
	 *
	 * @Covers UStruct.UStructOperatorExpansion
	 * @Inputs another FExpandedOperatorStruct
	 * @Return this after adding Other.Value
	 * @Param Other the other instance
	 */
	FExpandedOperatorStruct& opAddAssign(const FExpandedOperatorStruct&in Other)
	{
		Value += Other.Value;
		return this;
	}

	/**
	 * Compound-subtract another instance from this.
	 *
	 * @Covers UStruct.UStructOperatorExpansion
	 * @Inputs another FExpandedOperatorStruct
	 * @Return this after subtracting Other.Value
	 * @Param Other the other instance
	 */
	FExpandedOperatorStruct& opSubAssign(const FExpandedOperatorStruct&in Other)
	{
		Value -= Other.Value;
		return this;
	}

	/**
	 * Compound-multiply this by another instance.
	 *
	 * @Covers UStruct.UStructOperatorExpansion
	 * @Inputs another FExpandedOperatorStruct
	 * @Return this after multiplying by Other.Value
	 * @Param Other the other instance
	 */
	FExpandedOperatorStruct& opMulAssign(const FExpandedOperatorStruct&in Other)
	{
		Value *= Other.Value;
		return this;
	}

	/**
	 * Compound-divide this by another instance.
	 *
	 * @Covers UStruct.UStructOperatorExpansion
	 * @Inputs another FExpandedOperatorStruct
	 * @Return this after dividing by Other.Value
	 * @Param Other the other instance
	 */
	FExpandedOperatorStruct& opDivAssign(const FExpandedOperatorStruct&in Other)
	{
		Value /= Other.Value;
		return this;
	}
}

UCLASS()
class AExpandedOperatorActor : AActor
{
	UPROPERTY()
	int Results = 0;

	/**
	 * WorldStory: BeginPlay walks sub/mul/div/neg and compound assign into Results.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructOperatorExpansion
	 * @Inputs none
	 * @Return Results 25
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FExpandedOperatorStruct A;
		A.Value = 12;
		FExpandedOperatorStruct B;
		B.Value = 3;
		FExpandedOperatorStruct C = A - B;
		FExpandedOperatorStruct D = A * 2;
		FExpandedOperatorStruct E = A / 3;
		FExpandedOperatorStruct F = -A;
		C += B;
		C -= B;
		C *= B;
		C /= B;
		Results = C.Value + D.Value + E.Value + F.Value;
	}

	/**
	 * Observe the expanded-operator oracle on locals.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructOperatorExpansion
	 * @Inputs A=12 and B=3 through sub/mul/div/neg and compound assign
	 * @Return 25
	 */
	UFUNCTION()
	int ExpandedOperatorsNominalResults()
	{
		FExpandedOperatorStruct A;
		A.Value = 12;
		FExpandedOperatorStruct B;
		B.Value = 3;
		FExpandedOperatorStruct C = A - B;
		FExpandedOperatorStruct D = A * 2;
		FExpandedOperatorStruct E = A / 3;
		FExpandedOperatorStruct F = -A;
		C += B;
		C -= B;
		C *= B;
		C /= B;
		return C.Value + D.Value + E.Value + F.Value;
	}

	/**
	 * Observe Results plus a default Value before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructOperatorExpansion
	 * @Inputs an actor that has not begun play
	 * @Return 0
	 * @Boundary default zero
	 */
	UFUNCTION()
	int ExpandedOperatorsDefaultZero()
	{
		FExpandedOperatorStruct Empty;
		return Results + Empty.Value;
	}

	/**
	 * Observe subtract and negate of zero operands.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructOperatorExpansion
	 * @Inputs two default structs
	 * @Return 0
	 * @Boundary zero operands
	 */
	UFUNCTION()
	int ExpandedOperatorsZeroOperandBoundary()
	{
		FExpandedOperatorStruct A;
		FExpandedOperatorStruct B;
		FExpandedOperatorStruct C = A - B;
		FExpandedOperatorStruct Negated = -A;
		return C.Value + Negated.Value;
	}

	/**
	 * Observe that += on a copy leaves the original intact.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructOperatorExpansion
	 * @Inputs a copy that += the original
	 * @Return true when the original stays 12 and the copy is 24
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ExpandedOperatorsCopyIndependence()
	{
		FExpandedOperatorStruct Original;
		Original.Value = 12;
		FExpandedOperatorStruct Copy = Original;
		Copy += Original;
		if (Original.Value != 12)
		{
			return false;
		}
		return Copy.Value == 24;
	}
}
/** @end */
