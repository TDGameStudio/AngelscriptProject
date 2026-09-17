/**
 * @version v1
 * @summary Writing a FVector UPROPERTY and reading it back across positive, negative and zero values. C++ sets and verifies the value by path, so the UPROPERTY name is part of the contract and is kept verbatim. The observers cover.
 * @topic Math
 */
/**
 * @version root
 * @summary Writing a FVector UPROPERTY and reading it back across positive, negative and zero values. C++ sets and verifies the value by path, so the UPROPERTY name is part of the contract and is kept verbatim. The observers cover.
 * @topic Baseline
 */
UCLASS()
class ACoverageFVectorWriteActor : AActor
{
	UPROPERTY()
	FVector VectorValue;

	/**
	 * Observe that an untouched property is empty.
	 *
	 * @Kind Observe
	 * @Covers FVector.WriteRoundTrip
	 * @Inputs none
	 * @Return true when all three components are 0
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (VectorValue.X != 0.0)
		{
			return false;
		}
		if (VectorValue.Y != 0.0)
		{
			return false;
		}
		return VectorValue.Z == 0.0;
	}

	/**
	 * Observe that a positive write reads back unchanged.
	 *
	 * @Kind Observe
	 * @Covers FVector.WriteRoundTrip
	 * @Inputs none
	 * @Return true when all three components read (10, 20, 30)
	 */
	UFUNCTION()
	bool WritePositive()
	{
		VectorValue.X = 10.0;
		VectorValue.Y = 20.0;
		VectorValue.Z = 30.0;

		if (VectorValue.X != 10.0)
		{
			return false;
		}
		if (VectorValue.Y != 20.0)
		{
			return false;
		}
		return VectorValue.Z == 30.0;
	}

	/**
	 * Observe that a negative write reads back unchanged.
	 *
	 * @Kind Observe
	 * @Covers FVector.WriteRoundTrip
	 * @Inputs none
	 * @Return true when all three components read (-5, -10, -15)
	 */
	UFUNCTION()
	bool WriteNegative()
	{
		VectorValue.X = -5.0;
		VectorValue.Y = -10.0;
		VectorValue.Z = -15.0;

		if (VectorValue.X != -5.0)
		{
			return false;
		}
		if (VectorValue.Y != -10.0)
		{
			return false;
		}
		return VectorValue.Z == -15.0;
	}

	/**
	 * Observe that overwriting a component with zero lands at zero.
	 *
	 * @Kind Observe
	 * @Covers FVector.WriteRoundTrip
	 * @Inputs none
	 * @Return true when all three components read 0
	 * @Boundary zero overwrite
	 */
	UFUNCTION()
	bool WriteZeroBoundary()
	{
		VectorValue.X = 10.0;
		VectorValue.X = 0.0;
		VectorValue.Y = 0.0;
		VectorValue.Z = 0.0;

		if (VectorValue.X != 0.0)
		{
			return false;
		}
		if (VectorValue.Y != 0.0)
		{
			return false;
		}
		return VectorValue.Z == 0.0;
	}

	/**
	 * Observe that writing one instance leaves another instance empty.
	 *
	 * @Kind Observe
	 * @Covers FVector.WriteRoundTrip
	 * @Inputs a second actor
	 * @Return true when this instance reads 10 and the other still reads 0
	 * @Param Second the other actor, expected to stay empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageFVectorWriteActor Second)
	{
		if (Second is null)
		{
			throw("FVectorWriteRoundTrip setup: required Second is null");
		}
		VectorValue.X = 10.0;

		if (VectorValue.X != 10.0)
		{
			return false;
		}
		return Second.VectorValue.X == 0.0;
	}
}
/** @end */
