// Theme: Language.Preprocessor. Positive Root of the fan-out import graph.
// C++: AngelscriptPreprocessorImportTests.cpp::WideImportGraph block 1
// sha256=65a35cdc6a921da31e8ac20ad91dcc1cf5d26510abe9a4e80ad6390bb99ec064; lines 732-737.
// Oracle: RootValue() == 1; Root is first in topological order.
// Extra: repeat stays 1. DefaultSafe.

int RootValue()
{
	return 1;
}

bool Observe_RootValue_Nominal()
{
	return RootValue() == 1;
}

bool Observe_RootValue_RepeatBoundary()
{
	return RootValue() == 1 && RootValue() == 1;
}
