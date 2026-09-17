/**
 * @version v1
 * @summary Writing a FVector2D UPROPERTY and reading it back across positive, negative and zero values. C++ sets and verifies the value by path, so the UPROPERTY name is part of the contract and is kept verbatim. The observers.
 * @topic Math
 */
/**
 * @version root
 * @summary Writing a FVector2D UPROPERTY and reading it back across positive, negative and zero values. C++ sets and verifies the value by path, so the UPROPERTY name is part of the contract and is kept verbatim. The observers.
 * @topic Baseline
 */
UCLASS()
class ACoverageFVector2DWriteActor : AActor
{
	UPROPERTY()
	FVector2D VectorValue;

	/**
	 * Observe that an untouched property is empty.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.WriteRoundTrip
	 * @Inputs none
	 * @Return true when both components are 0
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (VectorValue.X != 0.0)
		{
			return false;
		}
		return VectorValue.Y == 0.0;
	}

	/**
	 * Observe that a positive write reads back unchanged.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.WriteRoundTrip
	 * @Inputs none
	 * @Return true when both components read (100, 200)
	 */
	UFUNCTION()
	bool WritePositive()
	{
		VectorValue.X = 100.0;
		VectorValue.Y = 200.0;

		if (VectorValue.X != 100.0)
		{
			return false;
		}
		return VectorValue.Y == 200.0;
	}

	/**
	 * Observe that a negative write reads back unchanged.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.WriteRoundTrip
	 * @Inputs none
	 * @Return true when both components read (-50, -75)
	 */
	UFUNCTION()
	bool WriteNegative()
	{
		VectorValue.X = -50.0;
		VectorValue.Y = -75.0;

		if (VectorValue.X != -50.0)
		{
			return false;
		}
		return VectorValue.Y == -75.0;
	}

	/**
	 * Observe that overwriting a component with zero lands at zero.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.WriteRoundTrip
	 * @Inputs none
	 * @Return true when both components read 0
	 * @Boundary zero overwrite
	 */
	UFUNCTION()
	bool WriteZeroBoundary()
	{
		VectorValue.X = 100.0;
		VectorValue.X = 0.0;
		VectorValue.Y = 0.0;

		if (VectorValue.X != 0.0)
		{
			return false;
		}
		return VectorValue.Y == 0.0;
	}

	/**
	 * Observe that writing one instance leaves another instance empty.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.WriteRoundTrip
	 * @Inputs a second actor
	 * @Return true when this instance reads 100 and the other still reads 0
	 * @Param Second the other actor, expected to stay empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageFVector2DWriteActor Second)
	{
		if (Second is null)
		{
			throw("FVector2DWriteRoundTrip setup: required Second is null");
		}
		VectorValue.X = 100.0;

		if (VectorValue.X != 100.0)
		{
			return false;
		}
		return Second.VectorValue.X == 0.0;
	}
}
/** @end */
