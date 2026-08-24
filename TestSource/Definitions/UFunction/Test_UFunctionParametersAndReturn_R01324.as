// Theme: Definitions.UFunction. WorldStory FVector add, Size, and &out UpVector.
// C++: AngelscriptCoverageFVectorFunctionTests.cpp::UFunctionParametersAndReturn
// Oracle: AddVectors((1,2,3),(4,5,6))==(5,7,9); VectorLength(3,4,0)==5; WriteOut UpVector.
// Extra: ZeroVector empty add; nullptr actor is the empty handle; addends unchanged after sum.
// FixtureIsolated.

UCLASS()
class ACoverageFVectorFunctionActor : AActor
{
	UFUNCTION()
	FVector AddVectors(FVector a, FVector b)
	{
		return a + b;
	}

	UFUNCTION()
	float VectorLength(FVector v)
	{
		return v.Size();
	}

	UFUNCTION()
	void WriteOut(FVector&out result)
	{
		result = FVector::UpVector;
	}
}

bool Observe_VectorFunction_Nominal(ACoverageFVectorFunctionActor Actor)
{
	FVector Sum = Actor.AddVectors(FVector(1, 2, 3), FVector(4, 5, 6));
	FVector OutValue = FVector::ZeroVector;
	Actor.WriteOut(OutValue);
	return Sum.Equals(FVector(5, 7, 9), 0.01)
		&& Math::IsNearlyEqual(Actor.VectorLength(FVector(3, 4, 0)), 5.0)
		&& OutValue.Equals(FVector::UpVector, 0.01);
}

bool Observe_VectorFunction_ZeroEmpty(ACoverageFVectorFunctionActor Actor)
{
	return Actor.AddVectors(FVector::ZeroVector, FVector::ZeroVector).Equals(FVector::ZeroVector, 0.01)
		&& Math::IsNearlyEqual(Actor.VectorLength(FVector::ZeroVector), 0.0);
}

bool Observe_VectorFunction_NullDefault()
{
	ACoverageFVectorFunctionActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_VectorFunction_CopyIndependence(ACoverageFVectorFunctionActor Actor)
{
	FVector A = FVector(1, 2, 3);
	FVector B = FVector(4, 5, 6);
	FVector Sum = Actor.AddVectors(A, B);
	return A.Equals(FVector(1, 2, 3), 0.01)
		&& B.Equals(FVector(4, 5, 6), 0.01)
		&& Sum.Equals(FVector(5, 7, 9), 0.01);
}
