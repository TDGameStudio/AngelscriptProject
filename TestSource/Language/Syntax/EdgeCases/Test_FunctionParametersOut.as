// Theme: Language.Syntax.EdgeCases. Positive bool &out parameter.
// C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionParametersOut
// sha256=76748e52aacbee9119a288eda4b03fe1a03f20805cd9641e41517339cb1667a6; lines 111-116.
// Oracle: SetTrue writes true into a false local. Extra: already-true stays true.
// DefaultSafe.

void SetTrue(bool&out b)
{
	b = true;
}

bool Observe_SetTrue_Nominal()
{
	bool OutValue = false;
	SetTrue(OutValue);
	return OutValue == true;
}

bool Observe_SetTrue_AlreadyTrueBoundary()
{
	bool OutValue = true;
	SetTrue(OutValue);
	return OutValue == true;
}
