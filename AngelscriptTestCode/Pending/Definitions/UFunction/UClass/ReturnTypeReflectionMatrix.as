/**
 * @version v1
 * @summary UFUNCTION return types bool, double, FString, FVector, and AActor. The oracle is true / 12.5 / "coverage" / FVector(1,2,3) / this. A second instance's ReturnSelfActor is not the first, and a default-constructed FVector.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UFUNCTION return types bool, double, FString, FVector, and AActor. The oracle is true / 12.5 / "coverage" / FVector(1,2,3) / this. A second instance's ReturnSelfActor is not the first, and a default-constructed FVector.
 * @topic Baseline
 */
UCLASS()
class ACoverageUFunctionReturnMatrixActor : AActor
{
	/**
	 * Return true.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool ReturnBool()
	{
		return true;
	}

	/**
	 * Return 12.5.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return 12.5
	 */
	UFUNCTION()
	double ReturnNumber()
	{
		return 12.5;
	}

	/**
	 * Return "coverage".
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return "coverage"
	 */
	UFUNCTION()
	FString ReturnString()
	{
		return "coverage";
	}

	/**
	 * Return FVector(1,2,3).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return FVector(1.0, 2.0, 3.0)
	 */
	UFUNCTION()
	FVector ReturnVector()
	{
		return FVector(1.0, 2.0, 3.0);
	}

	/**
	 * Return this actor.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return this
	 */
	UFUNCTION()
	AActor ReturnSelfActor()
	{
		return this;
	}

	/**
	 * Observe that ReturnSelfActor aliases this.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ReturnSelfActor()
	 * @Return true when the result is this
	 */
	UFUNCTION()
	bool SelfAlias()
	{
		return ReturnSelfActor() == this;
	}

	/**
	 * Observe that a second instance's ReturnSelfActor is not this.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Other Second actor
	 * @Inputs ReturnSelfActor on this and Other
	 * @Return true when the two selves differ
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool SecondInstanceIsNotFirst(ACoverageUFunctionReturnMatrixActor Other)
	{
		return ReturnSelfActor() != Other.ReturnSelfActor();
	}

	/**
	 * Observe that ReturnVector is not the empty zero vector.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ReturnVector() compared with ZeroVector
	 * @Return true when ZeroVector is (0,0,0) and ReturnVector differs
	 * @Boundary empty vector
	 */
	UFUNCTION()
	bool EmptyVectorIsNotNominal()
	{
		FVector Empty = FVector::ZeroVector;
		FVector Location = ReturnVector();
		if (Empty.X != 0.0)
		{
			return false;
		}
		if (Empty.Y != 0.0)
		{
			return false;
		}
		if (Empty.Z != 0.0)
		{
			return false;
		}
		if (Location.X != Empty.X)
		{
			return true;
		}
		if (Location.Y != Empty.Y)
		{
			return true;
		}
		return Location.Z != Empty.Z;
	}
}
/** @end */
