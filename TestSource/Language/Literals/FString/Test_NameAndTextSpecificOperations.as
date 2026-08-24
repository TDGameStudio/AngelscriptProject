// Theme: Language.Literals.FString. Positive FName/FText specific operations.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::NameAndTextSpecificOperations
// sha256 from TS-LANG-0130; lines 508-585.
// Oracle: default IsNone; GetPlainNameString "Plain"; case-insensitive equal; case-sensitive unequal;
// Compare orders; hash stable; FromString state; culture invariant; FromName; Format A:7; params 2; Join A|B.
// Extra: empty default FName IsNone; empty join parts produce empty.
// DefaultSafe. Source owns locals.

bool DefaultNameIsNone()
{
	FName Value;
	return Value.IsNone();
}

FString PlainNameString()
{
	FName Value = FName("Plain_17");
	return Value.GetPlainNameString();
}

bool NameCaseInsensitiveEquality()
{
	FName Lower = FName("display");
	FName Upper = FName("DISPLAY");
	return Lower.IsEqual(Upper);
}

bool NameCaseSensitiveInequality()
{
	FName Lower = FName("display");
	FName Upper = FName("DISPLAY");
	return !Lower.IsEqual(Upper, false);
}

bool NameCompareOrdersValues()
{
	FName Alpha = n"Alpha";
	FName Beta = n"Beta";
	return Alpha.Compare(Beta) < 0 && Beta.Compare(Alpha) > 0;
}

bool NameHashIsStable()
{
	FName Value = n"StableHash";
	return Value.GetHash() == Value.GetHash();
}

bool TextFromStringState()
{
	FText Value = FText::FromString("State");
	return Value.IsInitializedFromString() && !Value.IsEmpty();
}

bool CultureInvariantTextState()
{
	FText Value = FText::AsCultureInvariant("Invariant");
	return Value.IsCultureInvariant() && Value.ToString() == "Invariant";
}

FString TextFromName()
{
	return FText::FromName(n"NameText").ToString();
}

FString TextFormatOrdered()
{
	FText Pattern = FText::FromString("{0}:{1}");
	return FText::Format(Pattern, FText::FromString("A"), 7).ToString();
}

int TextFormatPatternParameterCount()
{
	TArray<FString> Names;
	FText::GetFormatPatternParameters(FText::FromString("{First}-{Second}"), Names);
	return Names.Num();
}

FString TextJoin()
{
	TArray<FText> Parts;
	Parts.Add(FText::FromString("A"));
	Parts.Add(FText::FromString("B"));
	return FText::Join(FText::FromString("|"), Parts).ToString();
}

bool Observe_NameAndText_Nominal()
{
	return DefaultNameIsNone()
		&& PlainNameString() == "Plain"
		&& NameCaseInsensitiveEquality()
		&& NameCaseSensitiveInequality()
		&& NameCompareOrdersValues()
		&& NameHashIsStable()
		&& TextFromStringState()
		&& CultureInvariantTextState()
		&& TextFromName() == "NameText"
		&& TextFormatOrdered() == "A:7"
		&& TextFormatPatternParameterCount() == 2
		&& TextJoin() == "A|B";
}

bool Observe_DefaultName_EmptyNone()
{
	FName Empty;
	return Empty.IsNone();
}

FString Observe_TextJoin_EmptyParts()
{
	TArray<FText> Parts;
	return FText::Join(FText::FromString("|"), Parts).ToString();
}
