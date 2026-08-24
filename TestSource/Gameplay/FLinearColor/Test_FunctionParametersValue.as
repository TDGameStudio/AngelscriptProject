// Theme: Gameplay.FLinearColor. Positive value-parameter oracles.
// C++: AngelscriptCoverageFLinearColorFunctionTests.cpp::FunctionParametersValue
// Oracle: AcceptColor(0.2,0.3,0.4,0.5) Equals (0.4,0.6,0.8,1.0);
// BlendColors(Red, Blue) R>0.4 and B>0.4.
// Extra: AcceptColor default empty; BlendColors copy independence. DefaultSafe.

FLinearColor AcceptColor(FLinearColor c)
{
	return c * 2.0;
}

FLinearColor BlendColors(FLinearColor a, FLinearColor b)
{
	return a * 0.5 + b * 0.5;
}

bool Observe_AcceptColor_Nominal()
{
	return AcceptColor(FLinearColor(0.2, 0.3, 0.4, 0.5)).Equals(FLinearColor(0.4, 0.6, 0.8, 1.0), 0.001);
}

bool Observe_BlendColors_Nominal()
{
	FLinearColor Result = BlendColors(FLinearColor::Red, FLinearColor::Blue);
	return Result.R > 0.4 && Result.B > 0.4;
}

bool Observe_AcceptColor_DefaultEmpty()
{
	return AcceptColor(FLinearColor()).Equals(FLinearColor(0.0, 0.0, 0.0, 2.0), 0.001);
}

bool Observe_BlendColors_CopyIndependence()
{
	FLinearColor A = FLinearColor::Red;
	FLinearColor B = FLinearColor::Blue;
	FLinearColor Mid = BlendColors(A, B);
	Mid.R = 0.0;
	return A.Equals(FLinearColor::Red) && B.Equals(FLinearColor::Blue);
}
