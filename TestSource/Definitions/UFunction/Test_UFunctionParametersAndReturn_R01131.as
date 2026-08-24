// Theme: Definitions.UFunction. WorldStory FLinearColor mix/luminance/out/clamp/packed convert.
// C++: AngelscriptCoverageFLinearColorFunctionTests.cpp::UFunctionParametersAndReturn
// Oracle: MixColors(Red,Blue) R>0.4 and B>0.4; White luminance >0.9; WriteOut Yellow; Clamp (-0.25,0.5,1.5,2)->(0,0.5,1,1).
// Extra: MixColors(Black,Black) empty; nullptr actor is the empty handle.
// FixtureIsolated.

UCLASS()
class ACoverageFLinearColorFunctionActor : AActor
{
	UFUNCTION()
	FLinearColor MixColors(FLinearColor a, FLinearColor b)
	{
		return a * 0.5 + b * 0.5;
	}

	UFUNCTION()
	float GetColorLuminance(FLinearColor c)
	{
		return c.GetLuminance();
	}

	UFUNCTION()
	void WriteOut(FLinearColor&out result)
	{
		result = FLinearColor::Yellow;
	}

	UFUNCTION()
	FLinearColor ClampInput(FLinearColor color)
	{
		FLinearColor MutableColor = color;
		return MutableColor.GetClamped(0.0, 1.0);
	}

	UFUNCTION()
	FLinearColor ConvertPacked(FColor color)
	{
		return FLinearColor(color);
	}
}

bool Observe_LinearColor_MixNominal(ACoverageFLinearColorFunctionActor Actor)
{
	FLinearColor Mixed = Actor.MixColors(FLinearColor::Red, FLinearColor::Blue);
	return Mixed.R > 0.4 && Mixed.B > 0.4;
}

bool Observe_LinearColor_BlackEmpty(ACoverageFLinearColorFunctionActor Actor)
{
	FLinearColor Mixed = Actor.MixColors(FLinearColor::Black, FLinearColor::Black);
	return Mixed.Equals(FLinearColor::Black, 0.001);
}

bool Observe_LinearColor_NullDefault()
{
	ACoverageFLinearColorFunctionActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_LinearColor_ClampAndOutBoundary(ACoverageFLinearColorFunctionActor Actor)
{
	FLinearColor OutValue = FLinearColor::Black;
	Actor.WriteOut(OutValue);
	FLinearColor Clamped = Actor.ClampInput(FLinearColor(-0.25, 0.5, 1.5, 2.0));
	FLinearColor Packed = Actor.ConvertPacked(FColor(255, 0, 0, 255));
	return OutValue.Equals(FLinearColor::Yellow, 0.001)
		&& Clamped.Equals(FLinearColor(0.0, 0.5, 1.0, 1.0), 0.001)
		&& Packed.R > 0.99 && Packed.G < 0.01 && Packed.B < 0.01 && Packed.A > 0.99
		&& Actor.GetColorLuminance(FLinearColor::White) > 0.9;
}
