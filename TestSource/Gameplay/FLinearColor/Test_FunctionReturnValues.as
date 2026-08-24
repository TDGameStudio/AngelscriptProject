// Theme: Gameplay.FLinearColor. Positive return-value oracles.
// C++: AngelscriptCoverageFLinearColorFunctionTests.cpp::FunctionReturnValues
// Oracle: ReturnWhite == White; ReturnCustomColor Equals (0.3,0.6,0.9,1.0);
// ReturnComputedColor R>0.4 and B>0.4.
// Extra: default empty is not White; copy independence of computed mix. DefaultSafe.

FLinearColor ReturnWhite()
{
	return FLinearColor::White;
}

FLinearColor ReturnCustomColor()
{
	return FLinearColor(0.3, 0.6, 0.9, 1.0);
}

FLinearColor ReturnComputedColor()
{
	FLinearColor a = FLinearColor::Red;
	FLinearColor b = FLinearColor::Blue;
	return a * 0.5 + b * 0.5;
}

bool Observe_ReturnWhite()
{
	return ReturnWhite() == FLinearColor::White;
}

bool Observe_ReturnCustomColor()
{
	return ReturnCustomColor().Equals(FLinearColor(0.3, 0.6, 0.9, 1.0), 0.001);
}

bool Observe_ReturnComputedColor()
{
	FLinearColor Result = ReturnComputedColor();
	return Result.R > 0.4 && Result.B > 0.4;
}

bool Observe_ReturnWhite_NotDefaultEmpty()
{
	return FLinearColor() != FLinearColor::White;
}

bool Observe_ReturnComputedColor_CopyIndependence()
{
	FLinearColor Result = ReturnComputedColor();
	Result.R = 0.0;
	return ReturnComputedColor().R > 0.4;
}
