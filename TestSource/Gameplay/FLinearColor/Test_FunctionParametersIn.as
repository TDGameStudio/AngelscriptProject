// Theme: Gameplay.FLinearColor. Positive &in parameter oracle.
// C++: AngelscriptCoverageFLinearColorFunctionTests.cpp::FunctionParametersIn
// Oracle: AcceptColorIn(White) luminance > 0.9.
// Extra: default empty / Black luminance 0. DefaultSafe.

float AcceptColorIn(FLinearColor&in c)
{
	return c.GetLuminance();
}

bool Observe_AcceptColorIn_White()
{
	FLinearColor Input = FLinearColor::White;
	return AcceptColorIn(Input) > 0.9;
}

bool Observe_AcceptColorIn_DefaultEmpty()
{
	FLinearColor Empty = FLinearColor();
	return AcceptColorIn(Empty) == 0.0;
}

bool Observe_AcceptColorIn_BlackBoundary()
{
	FLinearColor Input = FLinearColor::Black;
	return AcceptColorIn(Input) == 0.0;
}
