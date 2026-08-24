// Theme: Language.Preprocessor. Positive: minimal parse emits ReturnSeven.
// C++: AngelscriptPreprocessorBasicTests.cpp::BasicParse
// lines 39-44;
// sha256=bcfe9538d7b203ef7225623991f39a3de7795a2b9c494ecf53a765b3212837dd.
// Oracle: ReturnSeven() == 7. Processed code contains ReturnSeven.
// Extra: 7 is the sole return; no empty branch.
// DefaultSafe. Source owns locals.

int ReturnSeven()
{
	return 7;
}

bool Observe_ReturnSeven_Nominal()
{
	return ReturnSeven() == 7;
}
