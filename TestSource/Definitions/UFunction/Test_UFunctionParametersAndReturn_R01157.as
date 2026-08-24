// Theme: Definitions.UFunction. WorldStory float/double value, &out, and &inout UFUNCTION paths.
// C++: AngelscriptCoverageFloatFunctionTests.cpp::UFunctionParametersAndReturn
// Oracle: AddFloats(10.5,1.5)==12; MultiplyDoubles(4.25,2)==8.5; WriteFloatOut 20.75; WriteDoubleOut 31.25;
// MutateFloat 7 -> inout 14 return 15; MutateDouble 8 -> inout 24 return 25.
// Extra: AddFloats(0,0) empty; nullptr actor is the empty handle.
// FixtureIsolated.

UCLASS()
class ACoverageFloatFunctionActor : AActor
{
	UFUNCTION()
	float AddFloats(float A, float B)
	{
		return A + B;
	}

	UFUNCTION()
	double MultiplyDoubles(double A, double B)
	{
		return A * B;
	}

	UFUNCTION()
	void WriteFloatOut(float Seed, float&out Result)
	{
		Result = Seed + 0.75f;
	}

	UFUNCTION()
	void WriteDoubleOut(double Seed, double&out Result)
	{
		Result = Seed + 1.25;
	}

	UFUNCTION()
	float MutateFloat(float&inout Value)
	{
		Value = Value * 2.0f;
		return Value + 1.0f;
	}

	UFUNCTION()
	double MutateDouble(double&inout Value)
	{
		Value = Value * 3.0;
		return Value + 1.0;
	}
}

bool Observe_FloatFunction_Nominal(ACoverageFloatFunctionActor Actor)
{
	float FloatOut = 0.0f;
	double DoubleOut = 0.0;
	Actor.WriteFloatOut(20.0f, FloatOut);
	Actor.WriteDoubleOut(30.0, DoubleOut);
	float MutF = 7.0f;
	float MutFRet = Actor.MutateFloat(MutF);
	double MutD = 8.0;
	double MutDRet = Actor.MutateDouble(MutD);
	return Math::IsNearlyEqual(Actor.AddFloats(10.5f, 1.5f), 12.0f)
		&& Math::IsNearlyEqual(Actor.MultiplyDoubles(4.25, 2.0), 8.5)
		&& Math::IsNearlyEqual(FloatOut, 20.75f)
		&& Math::IsNearlyEqual(DoubleOut, 31.25)
		&& Math::IsNearlyEqual(MutF, 14.0f)
		&& Math::IsNearlyEqual(MutFRet, 15.0f)
		&& Math::IsNearlyEqual(MutD, 24.0)
		&& Math::IsNearlyEqual(MutDRet, 25.0);
}

bool Observe_FloatFunction_EmptyZero(ACoverageFloatFunctionActor Actor)
{
	return Math::IsNearlyEqual(Actor.AddFloats(0.0f, 0.0f), 0.0f)
		&& Math::IsNearlyEqual(Actor.MultiplyDoubles(0.0, 0.0), 0.0);
}

bool Observe_FloatFunction_NullDefault()
{
	ACoverageFloatFunctionActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_FloatFunction_MutateZeroBoundary(ACoverageFloatFunctionActor Actor)
{
	float Zero = 0.0f;
	float Ret = Actor.MutateFloat(Zero);
	return Math::IsNearlyEqual(Zero, 0.0f) && Math::IsNearlyEqual(Ret, 1.0f);
}
