// Theme: Definitions.UFunction. C++ compiles FVector stored-property UFUNCTION (CSV NegativeDiagnostic is wrong).
// C++: AngelscriptCoverageFVectorPropertyTests.cpp::FVectorUFunctionPropertyRoundTrip
// Oracle: StoreAndReturn((-1,1000,-3000))==(9,1020,-2970); CallDefaultParameter == (1,0,1) from Up+Forward.
// Extra: StoreAndReturn ZeroVector writes (10,20,30); nullptr actor is the empty handle.
// FixtureIsolated. Keep StoredVector name.

UCLASS()
class ACoverageFVectorUFunctionPropertyActor : AActor
{
	UPROPERTY()
	FVector StoredVector = FVector(1, 2, 3);

	UFUNCTION()
	FVector StoreAndReturn(FVector Input)
	{
		StoredVector = Input + FVector(10, 20, 30);
		return StoredVector;
	}

	UFUNCTION()
	FVector UseDefaultParameter(FVector Input = FVector::UpVector)
	{
		StoredVector = Input;
		return StoredVector + FVector::ForwardVector;
	}

	UFUNCTION()
	FVector CallDefaultParameter()
	{
		return UseDefaultParameter();
	}
}

bool Observe_VectorProperty_Nominal(ACoverageFVectorUFunctionPropertyActor Actor)
{
	FVector Stored = Actor.StoreAndReturn(FVector(-1, 1000, -3000));
	return Stored.Equals(FVector(9, 1020, -2970), 0.01)
		&& Actor.StoredVector.Equals(FVector(9, 1020, -2970), 0.01);
}

bool Observe_VectorProperty_ZeroEmpty(ACoverageFVectorUFunctionPropertyActor Actor)
{
	FVector Stored = Actor.StoreAndReturn(FVector::ZeroVector);
	return Stored.Equals(FVector(10, 20, 30), 0.01)
		&& Actor.StoredVector.Equals(FVector(10, 20, 30), 0.01);
}

bool Observe_VectorProperty_NullDefault()
{
	ACoverageFVectorUFunctionPropertyActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_VectorProperty_DefaultBoundary(ACoverageFVectorUFunctionPropertyActor Actor)
{
	FVector Defaulted = Actor.CallDefaultParameter();
	return Defaulted.Equals(FVector(1, 0, 1), 0.01)
		&& Actor.StoredVector.Equals(FVector::UpVector, 0.01);
}
