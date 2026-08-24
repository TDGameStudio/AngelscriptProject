// Theme: Language.Literals.FString. Positive Append/InsertAt/RemoveAt/Empty/Reset/index.
// C++: AngelscriptCoverageFStringMethodTests.cpp::MutableStringMethods
// sha256 from TS-LANG-0155; lines 544-603.
// Oracle: Score: 42; Start-ABCD; ABEF; ABC; EmptyResetReserveShrink 1; IndexMutation true.
// Extra: Empty() on default string stays empty; invalid index 3 is false.
// DefaultSafe. Source owns locals.

FString TestAppendAndAppendInt()
{
	FString s = "Score";
	s.Append(": ");
	s.AppendInt(42);
	return s;
}

FString TestAppendCharAndInsertAt()
{
	FString s = "AC";
	s.InsertAt(1, 0x42);
	s.AppendChar(0x44);
	s.InsertAt(0, "Start-");
	return s;
}

FString TestRemoveAt()
{
	FString s = "ABCDEF";
	s.RemoveAt(2, 2);
	return s;
}

FString TestRemoveSpacesInline()
{
	FString s = "A B  C";
	s.RemoveSpacesInline();
	return s;
}

int TestEmptyResetReserveShrink()
{
	FString s = "abcdef";
	s.Reserve(64);
	s.Empty();
	int AfterEmpty = s.Len();

	s.Append("xy");
	s.Reset(32);
	int AfterReset = s.Len();

	s.Append("z");
	s.Shrink();
	return AfterEmpty * 100 + AfterReset * 10 + s.Len();
}

bool TestIndexMutationAndValidation()
{
	FString s = "ABC";
	if (!s.IsValidIndex(2) || s.IsValidIndex(3))
	{
		return false;
	}

	s[1] = 0x5A;
	return s == "AZC";
}

bool Observe_MutableStringMethods_Nominal()
{
	return TestAppendAndAppendInt() == "Score: 42"
		&& TestAppendCharAndInsertAt() == "Start-ABCD"
		&& TestRemoveAt() == "ABEF"
		&& TestRemoveSpacesInline() == "ABC"
		&& TestEmptyResetReserveShrink() == 1
		&& TestIndexMutationAndValidation();
}

bool Observe_Empty_DefaultLength()
{
	FString s;
	s.Empty();
	return s.Len() == 0;
}

bool Observe_IsValidIndex_FalseBoundary()
{
	FString s = "ABC";
	return !s.IsValidIndex(3);
}
