// Theme: Gameplay.FLinearColor. Positive default-parameter oracles.
// C++: AngelscriptCoverageFLinearColorFunctionTests.cpp::FunctionDefaultParameters
// Oracle: BlendWithDefault(Red, Blue) R>0.4 and B>0.4;
// BlendWithImplicitDefault(White) R in (0.4, 0.6) (blends with Black).
// Extra: BlendWithDefault of default empty. DefaultSafe.

FLinearColor BlendWithDefault(FLinearColor a, FLinearColor b = FLinearColor::Black)
{
	return a * 0.5 + b * 0.5;
}

FLinearColor BlendWithImplicitDefault(FLinearColor a)
{
	return BlendWithDefault(a);
}

bool Observe_BlendWithDefault_Explicit()
{
	FLinearColor Result = BlendWithDefault(FLinearColor::Red, FLinearColor::Blue);
	return Result.R > 0.4 && Result.B > 0.4;
}

bool Observe_BlendWithImplicitDefault_White()
{
	FLinearColor Result = BlendWithImplicitDefault(FLinearColor::White);
	return Result.R > 0.4 && Result.R < 0.6;
}

bool Observe_BlendWithDefault_DefaultEmpty()
{
	FLinearColor Result = BlendWithDefault(FLinearColor());
	return Result.Equals(FLinearColor(0.0, 0.0, 0.0, 1.0), 0.001);
}

bool Observe_BlendWithImplicitDefault_CopyIndependence()
{
	FLinearColor Input = FLinearColor::White;
	FLinearColor Result = BlendWithImplicitDefault(Input);
	Result.R = 0.0;
	return Input.Equals(FLinearColor::White);
}
