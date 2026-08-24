// Theme: Language.Literals.FString. Positive FString/FName/FText &out parameters.
// C++: AngelscriptCoverageFStringFunctionTests.cpp::FunctionParametersOut
// sha256=3d9ba63b2dabf68347403f5d8d647222c330c7f4122fc79c66a0aaf2fd5530de; lines 209-230.
// Oracle: WriteString "Output"; WriteName n"OutputName"; WriteText "OutputText"; WriteMultiple First/Second.
// Extra: empty &out overwritten; WriteMultiple independent of prior values.
// DefaultSafe. Source owns locals.

void WriteString(FString&out x)
{
	x = "Output";
}

void WriteName(FName&out x)
{
	x = n"OutputName";
}

void WriteText(FText&out x)
{
	x = FText::FromString("OutputText");
}

void WriteMultiple(FString&out a, FString&out b)
{
	a = "First";
	b = "Second";
}

bool Observe_FunctionParametersOut_Nominal()
{
	FString OutValue;
	WriteString(OutValue);
	FName OutName;
	WriteName(OutName);
	FText OutText;
	WriteText(OutText);
	FString OutA;
	FString OutB;
	WriteMultiple(OutA, OutB);
	return OutValue == "Output"
		&& OutName == n"OutputName"
		&& OutText.ToString() == "OutputText"
		&& OutA == "First"
		&& OutB == "Second";
}

bool Observe_WriteString_EmptyDefault()
{
	FString OutValue = "";
	WriteString(OutValue);
	return OutValue == "Output";
}

bool Observe_WriteMultiple_CopyIndependence()
{
	FString A = "Keep";
	FString B = "Keep";
	WriteMultiple(A, B);
	return A == "First" && B == "Second";
}
