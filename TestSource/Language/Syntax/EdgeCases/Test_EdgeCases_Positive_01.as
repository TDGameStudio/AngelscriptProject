// Theme: Language.Syntax.EdgeCases. Positive empty function body compiles.
// C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Positive ASSyntaxMiscEmptyFunc AssertCompiles
// sha256=8bd1e6fa92effb44b49d763fab5135e033d1d1cfa7f6ce2fdfcc450342610523; lines 229-231.
// Oracle: DoNothing compiles and can be invoked.
// Extra: a second call is independent of the first (no state).
// DefaultSafe. Source owns nothing.

void DoNothing()
{
}

void Observe_DoNothing_Nominal()
{
	DoNothing();
}

void Observe_DoNothing_SecondCall()
{
	DoNothing();
	DoNothing();
}
