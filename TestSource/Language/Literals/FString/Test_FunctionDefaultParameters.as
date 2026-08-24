// Theme: Language.Literals.FString. Positive default FString/FName parameters.
// C++: AngelscriptCoverageFStringFunctionTests.cpp::FunctionDefaultParameters
// sha256 from TS-LANG-0146; lines 473-508.
// Oracle: ConcatWithDefault explicit "Test Custom"; implicit "Test Default";
// GreetWithImplicitDefault "Hello World"; TextWithDefault "DefaultText"; NameWithImplicitDefault "DefaultName".
// Extra: empty name greets "Hello "; empty concat of two empty strings.
// DefaultSafe. Source owns locals.

FString ConcatWithDefault(FString a, FString b = " Default")
{
	return a + b;
}

FString ConcatWithImplicitDefault(FString a)
{
	return ConcatWithDefault(a);
}

FString GreetWithDefault(FString name = "World")
{
	return "Hello " + name;
}

FString GreetWithImplicitDefault()
{
	return GreetWithDefault();
}

FString TextWithDefault(FText text)
{
	return text.ToString();
}

FString NameWithDefault(FName name = n"DefaultName")
{
	return name.ToString();
}

FString NameWithImplicitDefault()
{
	return NameWithDefault();
}

bool Observe_FunctionDefaultParameters_Nominal()
{
	return ConcatWithDefault("Test", " Custom") == "Test Custom"
		&& ConcatWithImplicitDefault("Test") == "Test Default"
		&& GreetWithImplicitDefault() == "Hello World"
		&& TextWithDefault(FText::FromString("DefaultText")) == "DefaultText"
		&& NameWithImplicitDefault() == "DefaultName";
}

bool Observe_GreetWithDefault_EmptyName()
{
	return GreetWithDefault("") == "Hello ";
}

bool Observe_ConcatWithDefault_EmptyPair()
{
	return ConcatWithDefault("", "") == "";
}
