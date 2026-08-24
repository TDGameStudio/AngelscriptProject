// Theme: Definitions.UFunction. WorldStory FRotator add, Vector(), and &out.
// C++: AngelscriptCoverageFRotatorFunctionTests.cpp::UFunctionParametersAndReturn
// Oracle: AddRotators((10,20,30),(5,10,15))==(15,30,45); WriteOut (30,60,90).
// Extra: ZeroRotator+ZeroRotator empty; nullptr actor is the empty handle; addends unchanged after sum.
// FixtureIsolated.

UCLASS()
class ACoverageFRotatorFunctionActor : AActor
{
	UFUNCTION()
	FRotator AddRotators(FRotator a, FRotator b)
	{
		return a + b;
	}

	UFUNCTION()
	FVector RotatorToVector(FRotator r)
	{
		return r.Vector();
	}

	UFUNCTION()
	void WriteOut(FRotator&out result)
	{
		result = FRotator(30, 60, 90);
	}
}

bool Observe_RotatorFunction_Nominal(ACoverageFRotatorFunctionActor Actor)
{
	FRotator Sum = Actor.AddRotators(FRotator(10, 20, 30), FRotator(5, 10, 15));
	FRotator OutValue = FRotator::ZeroRotator;
	Actor.WriteOut(OutValue);
	return Sum.Equals(FRotator(15, 30, 45), 0.01)
		&& OutValue.Equals(FRotator(30, 60, 90), 0.01)
		&& Actor.RotatorToVector(FRotator(0, 90, 0)).Equals(FRotator(0, 90, 0).Vector(), 0.001);
}

bool Observe_RotatorFunction_ZeroEmpty(ACoverageFRotatorFunctionActor Actor)
{
	FRotator Sum = Actor.AddRotators(FRotator::ZeroRotator, FRotator::ZeroRotator);
	return Sum.Equals(FRotator::ZeroRotator, 0.01);
}

bool Observe_RotatorFunction_NullDefault()
{
	ACoverageFRotatorFunctionActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_RotatorFunction_CopyIndependence(ACoverageFRotatorFunctionActor Actor)
{
	FRotator A = FRotator(10, 20, 30);
	FRotator B = FRotator(5, 10, 15);
	FRotator Sum = Actor.AddRotators(A, B);
	return A.Equals(FRotator(10, 20, 30), 0.01)
		&& B.Equals(FRotator(5, 10, 15), 0.01)
		&& Sum.Equals(FRotator(15, 30, 45), 0.01);
}
