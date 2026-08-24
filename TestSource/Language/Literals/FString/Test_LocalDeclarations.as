// Theme: Language.Literals.FString. Positive local FString/FName/FText declarations.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::LocalDeclarations
// sha256 from TS-LANG-0125; lines 85-164.
// Oracle: Hello/World/Const/empty/NAME_None/MyName/ConstName/Convert/Visible Text/empty/Const Text/AutoText.
// Extra: default FString empty; default FName NAME_None; default FText ToString empty.
// DefaultSafe. Source owns locals.

FString LocalDefaultInit()
{
	FString Value = "Hello";
	return Value;
}

FString LocalDeferredInit()
{
	FString Value;
	Value = "World";
	return Value;
}

FString LocalConst()
{
	const FString Value = "Const";
	return Value;
}

FString LocalEmpty()
{
	FString Value = "";
	return Value;
}

FString LocalDefaultString()
{
	FString Value;
	return Value;
}

FName LocalName()
{
	FName Value = n"MyName";
	return Value;
}

FName LocalNameDefault()
{
	FName Value;
	return Value;
}

FName LocalNameConst()
{
	const FName Value = n"ConstName";
	return Value;
}

FString LocalNameToString()
{
	FName Value = n"Convert";
	return Value.ToString();
}

FString LocalTextToString()
{
	FText Value = FText::FromString("Visible Text");
	return Value.ToString();
}

FString LocalTextDefaultToString()
{
	FText Value;
	return Value.ToString();
}

FString LocalTextConstToString()
{
	const FText Value = FText::FromString("Const Text");
	return Value.ToString();
}

FString AutoStringLiteral()
{
	auto Value = "AutoText";
	return Value;
}

bool Observe_LocalDeclarations_Nominal()
{
	return LocalDefaultInit() == "Hello"
		&& LocalDeferredInit() == "World"
		&& LocalConst() == "Const"
		&& LocalName() == n"MyName"
		&& LocalNameConst() == n"ConstName"
		&& LocalNameToString() == "Convert"
		&& LocalTextToString() == "Visible Text"
		&& LocalTextConstToString() == "Const Text"
		&& AutoStringLiteral() == "AutoText";
}

bool Observe_LocalDeclarations_EmptyDefault()
{
	return LocalEmpty() == "" && LocalDefaultString() == "" && LocalTextDefaultToString() == "";
}

bool Observe_LocalName_NoneBoundary()
{
	return LocalNameDefault() == NAME_None;
}
