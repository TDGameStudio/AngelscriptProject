// Theme: Language.Preprocessor. Positive consumer of the import chain (Entry imports Shared).
// C++: AngelscriptPreprocessorImportTests.cpp::TopologicalOrderRespectsDependencyChain block 3
// sha256=4b89ce88a98976abc0c65ee6428cd3f153e278f292d02717b58760cae730330c; lines 439-445.
// Oracle: Entry() == SharedValue() + 5 == 10.
// Extra: SharedValue is 5. DefaultSafe.

import Tests.Preprocessor.ImportTopology.Shared;
int Entry()
{
	return SharedValue() + 5;
}

bool Observe_Entry_Nominal()
{
	return Entry() == 10;
}

bool Observe_Entry_SharedBoundary()
{
	return SharedValue() == 5 && Entry() == SharedValue() + 5;
}
