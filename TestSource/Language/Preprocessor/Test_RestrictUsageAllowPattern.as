// Theme: Language.Preprocessor. Positive: allow then disallow usage patterns are recorded.
// C++: AngelscriptPreprocessorNamespaceTests.cpp::RestrictUsageAllowPattern
// sha256=d32afebb49cf60ae3cad71e6bf45929cef8e3b0eaaf3a3914e7106fb3597b7c5; lines 263-270.
// Oracle: Entry() == 42; restrictions[0] allow Game.UI.*; restrictions[1] disallow Game.Internal.*.
// Extra: repeat stays 42. DefaultSafe.

#restrict usage allow Game.UI.*
#restrict usage disallow Game.Internal.*
int Entry()
{
	return 42;
}

bool Observe_Entry_Nominal()
{
	return Entry() == 42;
}

bool Observe_Entry_RepeatBoundary()
{
	return Entry() == 42 && Entry() == 42;
}
