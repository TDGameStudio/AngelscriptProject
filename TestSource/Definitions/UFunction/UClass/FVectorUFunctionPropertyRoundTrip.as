/**
 * FVector stored-property UFUNCTION round trip. StoreAndReturn((-1,1000,-3000))
 * yields (9,1020,-2970). CallDefaultParameter yields (1,0,1) from Up+Forward.
 * StoreAndReturn of ZeroVector writes (10,20,30), and a nullptr actor is the
 * empty handle.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.FVectorUFunctionPropertyRoundTrip
 * @Harness UClass
 * @Tag Definitions.UFunction.FVectorUFunctionPropertyRoundTrip
 * @Provenance Theme: Definitions.UFunction. C++ compiles FVector stored-property UFUNCTION (CSV NegativeDiagnostic is wrong).
 * @Provenance C++: AngelscriptCoverageFVectorPropertyTests.cpp::FVectorUFunctionPropertyRoundTrip
 * @Provenance Oracle: StoreAndReturn((-1,1000,-3000))==(9,1020,-2970); CallDefaultParameter == (1,0,1) from Up+Forward.
 * @Provenance Extra: StoreAndReturn ZeroVector writes (10,20,30); nullptr actor is the empty handle.
 * @Provenance FixtureIsolated. Keep StoredVector name.
 */

UCLASS()
class ACoverageFVectorUFunctionPropertyActor : AActor
{
	UPROPERTY()
	FVector StoredVector = FVector(1, 2, 3);

	/**
	 * Store Input plus (10,20,30) and return the stored vector.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Input Vector added to (10,20,30)
	 * @Inputs Input
	 * @Return StoredVector after the write
	 */
	UFUNCTION()
	FVector StoreAndReturn(FVector Input)
	{
		StoredVector = Input + FVector(10, 20, 30);
		return StoredVector;
	}

	/**
	 * Store Input, defaulting to UpVector, and return it plus ForwardVector.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Input Vector stored, default UpVector
	 * @Inputs Input
	 * @Return StoredVector + ForwardVector
	 */
	UFUNCTION()
	FVector UseDefaultParameter(FVector Input = FVector::UpVector)
	{
		StoredVector = Input;
		return StoredVector + FVector::ForwardVector;
	}

	/**
	 * Call UseDefaultParameter with no arguments.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs UseDefaultParameter()
	 * @Return UpVector + ForwardVector
	 */
	UFUNCTION()
	FVector CallDefaultParameter()
	{
		return UseDefaultParameter();
	}

	/**
	 * Observe StoreAndReturn of (-1,1000,-3000).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs StoreAndReturn(FVector(-1, 1000, -3000))
	 * @Return true when the result and StoredVector equal (9,1020,-2970)
	 */
	UFUNCTION()
	bool StoreAndReturnNominal()
	{
		FVector Stored = StoreAndReturn(FVector(-1, 1000, -3000));
		if (!Stored.Equals(FVector(9, 1020, -2970), 0.01))
		{
			return false;
		}
		return StoredVector.Equals(FVector(9, 1020, -2970), 0.01);
	}

	/**
	 * Observe StoreAndReturn of ZeroVector.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs StoreAndReturn(FVector::ZeroVector)
	 * @Return true when the result and StoredVector equal (10,20,30)
	 * @Boundary zero vector
	 */
	UFUNCTION()
	bool StoreAndReturnZeroVector()
	{
		FVector Stored = StoreAndReturn(FVector::ZeroVector);
		if (!Stored.Equals(FVector(10, 20, 30), 0.01))
		{
			return false;
		}
		return StoredVector.Equals(FVector(10, 20, 30), 0.01);
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ACoverageFVectorUFunctionPropertyActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageFVectorUFunctionPropertyActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe CallDefaultParameter yielding Up plus Forward.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs CallDefaultParameter()
	 * @Return true when the result is (1,0,1) and StoredVector is UpVector
	 * @Boundary default parameter
	 */
	UFUNCTION()
	bool DefaultParameterBoundary()
	{
		FVector Defaulted = CallDefaultParameter();
		if (!Defaulted.Equals(FVector(1, 0, 1), 0.01))
		{
			return false;
		}
		return StoredVector.Equals(FVector::UpVector, 0.01);
	}
}
