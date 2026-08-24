// Theme: Gameplay.FLinearColor. Positive &inout brighten oracle.
// C++: AngelscriptCoverageFLinearColorFunctionTests.cpp::FunctionParametersInOut
// Oracle: BrightenColor((0.5,0.5,0.5,1.0), 2.0) Equals (1,1,1,2).
// Extra: amount 0 yields zero RGB; default empty * 2. DefaultSafe.

void BrightenColor(FLinearColor&inout c, float amount)
{
	c = c * amount;
}

bool Observe_BrightenColor_Nominal()
{
	FLinearColor Value = FLinearColor(0.5, 0.5, 0.5, 1.0);
	BrightenColor(Value, 2.0);
	return Value.Equals(FLinearColor(1.0, 1.0, 1.0, 2.0), 0.001);
}

bool Observe_BrightenColor_ZeroAmount()
{
	FLinearColor Value = FLinearColor(0.5, 0.5, 0.5, 1.0);
	BrightenColor(Value, 0.0);
	return Value.Equals(FLinearColor(0.0, 0.0, 0.0, 0.0), 0.001);
}

bool Observe_BrightenColor_DefaultEmpty()
{
	FLinearColor Value = FLinearColor();
	BrightenColor(Value, 2.0);
	return Value.Equals(FLinearColor(0.0, 0.0, 0.0, 2.0), 0.001);
}
