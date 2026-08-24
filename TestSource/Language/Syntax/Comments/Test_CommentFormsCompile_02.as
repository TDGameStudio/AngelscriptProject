// Theme: Language.Syntax.Comments. Positive multi-line block comments compile and return 2.
// C++: AngelscriptCoverageCommentTests.cpp::CommentFormsCompile block 2
// sha256=93dd89816d670a5f223dc661c197d8c3b5078746f508b06ad1d578eae3eaaf2e; lines 48-57.
// Oracle: MultiLineComment() == 2.
// Extra: repeat stays 2. DefaultSafe.

/*
	Multi-line block comment before a declaration.
*/
int MultiLineComment()
{
	int Value = 2;
	/* Inline block comment */ return Value;
}

bool Observe_MultiLineComment_Nominal()
{
	return MultiLineComment() == 2;
}

bool Observe_MultiLineComment_RepeatBoundary()
{
	return MultiLineComment() == 2 && MultiLineComment() == 2;
}
