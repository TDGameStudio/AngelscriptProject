// Theme: Language.Literals.FString. Positive FString::Format, FromInt, Chr, pad, tabs.
// C++: AngelscriptCoverageFStringMethodTests.cpp::FormatMethods
// sha256 from TS-LANG-0158; lines 845-888.
// Oracle: 42; 3.140000; Hello World; 2 + 3 = 5; -17; ABBB; "  7|7  "; "A B".
// Extra: Format of empty string; FromInt 0.
// DefaultSafe. Source owns locals.

FString TestFormatInt()
{
	return FString::Format("{0}", 42);
}

FString TestFormatFloat()
{
	return FString::Format("{0}", 3.14f);
}

FString TestFormatString()
{
	return FString::Format("Hello {0}", "World");
}

FString TestFormatMultiple()
{
	return FString::Format("{0} + {1} = {2}", 2, 3, 5);
}

FString TestFromInt()
{
	return FString::FromInt(-17);
}

FString TestChrAndChrN()
{
	return FString::Chr(0x41) + FString::ChrN(3, 0x42);
}

FString TestLeftPadAndRightPad()
{
	FString left = "7";
	FString right = "7";
	return left.LeftPad(3) + "|" + right.RightPad(3);
}

FString TestConvertTabsToSpaces()
{
	FString value = "A\tB";
	return value.ConvertTabsToSpaces(2);
}

bool Observe_FormatMethods_Nominal()
{
	return TestFormatInt() == "42"
		&& TestFormatFloat() == "3.140000"
		&& TestFormatString() == "Hello World"
		&& TestFormatMultiple() == "2 + 3 = 5"
		&& TestFromInt() == "-17"
		&& TestChrAndChrN() == "ABBB"
		&& TestLeftPadAndRightPad() == "  7|7  "
		&& TestConvertTabsToSpaces() == "A B";
}

FString Observe_FormatString_EmptyArg()
{
	return FString::Format("Hello {0}", "");
}

FString Observe_FromInt_ZeroBoundary()
{
	return FString::FromInt(0);
}
