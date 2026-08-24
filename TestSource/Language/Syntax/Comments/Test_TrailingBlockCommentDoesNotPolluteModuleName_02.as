// Theme: Language.Syntax.Comments. Positive consumer: /* comment */ after the import name is stripped.
// C++: AngelscriptPreprocessorImportTests.cpp::TrailingBlockCommentDoesNotPolluteModuleName block 2
// sha256=02b3da2c75b71e7a9e8ed9e2b27d5a9f7f76d380896e81101b7bf90d0ac47f5d; lines 246-252.
// Oracle: Entry() == 11; import name is Tests.Preprocessor.ImportTrailingBlockComment.Shared not the comment text.
// Extra: Entry matches SharedValue. DefaultSafe.

import Tests.Preprocessor.ImportTrailingBlockComment.Shared /* shared helpers */;
int Entry()
{
	return SharedValue();
}

bool Observe_Entry_Nominal()
{
	return Entry() == 11;
}

bool Observe_Entry_MatchesProvider()
{
	return Entry() == SharedValue();
}
