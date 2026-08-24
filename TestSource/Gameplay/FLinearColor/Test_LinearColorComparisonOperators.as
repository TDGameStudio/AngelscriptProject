// Theme: Gameplay.FLinearColor. Positive == / != oracles.
// C++: AngelscriptCoverageFLinearColorExpressionTests.cpp::LinearColorComparisonOperators
// Oracle: OpEquals_True true; OpEquals_False false; OpNotEquals_True true;
// OpNotEquals_False false.
// Extra: default FLinearColor() equals itself; Black != White. DefaultSafe.

bool OpEquals_True()
{
	FLinearColor a = FLinearColor(0.5, 0.6, 0.7, 0.8);
	FLinearColor b = FLinearColor(0.5, 0.6, 0.7, 0.8);
	return a == b;
}

bool OpEquals_False()
{
	FLinearColor a = FLinearColor(0.5, 0.6, 0.7, 0.8);
	FLinearColor b = FLinearColor(0.5, 0.6, 0.8, 0.8);
	return a == b;
}

bool OpNotEquals_True()
{
	FLinearColor a = FLinearColor::Red;
	FLinearColor b = FLinearColor::Blue;
	return a != b;
}

bool OpNotEquals_False()
{
	FLinearColor a = FLinearColor::White;
	FLinearColor b = FLinearColor::White;
	return a != b;
}

bool Observe_Comparison_Nominal()
{
	return OpEquals_True() == true
		&& OpEquals_False() == false
		&& OpNotEquals_True() == true
		&& OpNotEquals_False() == false;
}

bool Observe_Comparison_DefaultEmpty()
{
	FLinearColor EmptyA = FLinearColor();
	FLinearColor EmptyB = FLinearColor();
	return (EmptyA == EmptyB) == true && (EmptyA != EmptyB) == false;
}

bool Observe_Comparison_BlackWhiteBoundary()
{
	return (FLinearColor::Black == FLinearColor::White) == false
		&& (FLinearColor::Black != FLinearColor::White) == true;
}
