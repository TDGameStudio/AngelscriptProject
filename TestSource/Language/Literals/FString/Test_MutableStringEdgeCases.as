// Theme: Language.Literals.FString. Positive InsertAt/RemoveAt/ReplaceInline edge cases.
// C++: AngelscriptCoverageFStringMethodTests.cpp::MutableStringEdgeCases
// sha256 from TS-LANG-0156; lines 634-677.
// Oracle: Start-|Center-End; payload; A\tBC; 1:Hit token TOKEN; 1:B.
// Extra: insert at Len on empty; RemoveSpacesInline on empty.
// DefaultSafe. Source owns locals.

FString TestInsertAtBoundaries()
{
	FString s = "Center";
	s.InsertAt(0, "Start-");
	s.InsertAt(s.Len(), "-End");
	s.InsertAt(6, 0x7C);
	return s;
}

FString TestRemoveAtFirstAndLast()
{
	FString s = "[payload]";
	s.RemoveAt(0, 1);
	s.RemoveAt(s.Len() - 1, 1);
	return s;
}

FString TestRemoveSpacesInlinePreservesWhitespaceKinds()
{
	FString s = " A\tB C ";
	s.RemoveSpacesInline();
	return s;
}

FString TestReplaceInlineCaseSensitiveCount()
{
	FString s = "Token token TOKEN";
	int Count = s.ReplaceInline("Token", "Hit", ESearchCase::CaseSensitive);
	return FString::Format("{0}:{1}", Count, s);
}

FString TestMemoryMethodsRemainUsable()
{
	FString s = "carry";
	s.Reserve(128);
	s.Empty(16);
	s.Append("A");
	s.Reset(32);
	s.Append("B");
	s.Shrink();
	return FString::Format("{0}:{1}", s.Len(), s);
}

bool Observe_MutableStringEdgeCases_Nominal()
{
	return TestInsertAtBoundaries() == "Start-|Center-End"
		&& TestRemoveAtFirstAndLast() == "payload"
		&& TestRemoveSpacesInlinePreservesWhitespaceKinds() == "A\tBC"
		&& TestReplaceInlineCaseSensitiveCount() == "1:Hit token TOKEN"
		&& TestMemoryMethodsRemainUsable() == "1:B";
}

FString Observe_InsertAt_EmptyDefault()
{
	FString s;
	s.InsertAt(0, "Start-");
	return s;
}

FString Observe_RemoveSpaces_EmptyBoundary()
{
	FString s;
	s.RemoveSpacesInline();
	return s;
}
