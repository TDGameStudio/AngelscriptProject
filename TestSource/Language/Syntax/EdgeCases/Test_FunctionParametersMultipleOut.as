// Theme: Language.Syntax.EdgeCases. Positive multiple bool &out parameters.
// C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionParametersMultipleOut
// sha256=28b9c3a745491621e9e4c8c783c5b60c45e8b1b96747888790ad8a717604fd81; lines 139-145.
// Oracle: SetPair writes First=true, Second=false. Extra: inverted seeds are
// overwritten (copy-independence of the out writes). DefaultSafe.

void SetPair(bool&out First, bool&out Second)
{
	First = true;
	Second = false;
}

bool Observe_SetPair_Nominal()
{
	bool First = false;
	bool Second = true;
	SetPair(First, Second);
	return First == true && Second == false;
}

bool Observe_SetPair_SeededBoundary()
{
	bool First = true;
	bool Second = false;
	SetPair(First, Second);
	return First == true && Second == false;
}
