// Theme: Definitions.UFunction. WorldStory FVector2D add, Size, and &out.
// C++: AngelscriptCoverageFVector2DFunctionTests.cpp::UFunctionParametersAndReturn
// Oracle: AddVectors((10,20),(5,10))==(15,30); VectorLength(3,4)==5; WriteOut (99,88).
// Extra: ZeroVector empty add; nullptr actor is the empty handle; addends unchanged after sum.
// FixtureIsolated.

UCLASS()
class ACoverageFVector2DFunctionActor : AActor
{
	UFUNCTION()
	FVector2D AddVectors(FVector2D a, FVector2D b)
	{
		return a + b;
	}

	UFUNCTION()
	float VectorLength(FVector2D v)
	{
		return v.Size();
	}

	UFUNCTION()
	void WriteOut(FVector2D&out result)
	{
		result = FVector2D(99, 88);
	}
}

bool Observe_Vector2DFunction_Nominal(ACoverageFVector2DFunctionActor Actor)
{
	FVector2D Sum = Actor.AddVectors(FVector2D(10, 20), FVector2D(5, 10));
	FVector2D OutValue = FVector2D::ZeroVector;
	Actor.WriteOut(OutValue);
	return Sum.Equals(FVector2D(15, 30), 0.01)
		&& Math::IsNearlyEqual(Actor.VectorLength(FVector2D(3, 4)), 5.0)
		&& OutValue.Equals(FVector2D(99, 88), 0.01);
}

bool Observe_Vector2DFunction_ZeroEmpty(ACoverageFVector2DFunctionActor Actor)
{
	return Actor.AddVectors(FVector2D::ZeroVector, FVector2D::ZeroVector).Equals(FVector2D::ZeroVector, 0.01)
		&& Math::IsNearlyEqual(Actor.VectorLength(FVector2D::ZeroVector), 0.0);
}

bool Observe_Vector2DFunction_NullDefault()
{
	ACoverageFVector2DFunctionActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_Vector2DFunction_CopyIndependence(ACoverageFVector2DFunctionActor Actor)
{
	FVector2D A = FVector2D(10, 20);
	FVector2D B = FVector2D(5, 10);
	FVector2D Sum = Actor.AddVectors(A, B);
	return A.Equals(FVector2D(10, 20), 0.01)
		&& B.Equals(FVector2D(5, 10), 0.01)
		&& Sum.Equals(FVector2D(15, 30), 0.01);
}
