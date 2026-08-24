// Theme: Language.Preprocessor. Positive consumer: duplicate import statements collapse to one dependency.
// C++: AngelscriptPreprocessorImportTests.cpp::DuplicateStatementsDeduplicateDependency block 2
// sha256=b81a355d6ddd0924a7b1a802aa1f16fce7d3c411957b38768abac267f94e3374; lines 335-342.
// Oracle: Entry() == 17 through the deduplicated import of Tests.Preprocessor.ImportDedup.Shared.
// Extra: Entry matches SharedValue. DefaultSafe.

import Tests.Preprocessor.ImportDedup.Shared;
import Tests.Preprocessor.ImportDedup.Shared;
int Entry()
{
	return SharedValue();
}

bool Observe_Entry_Nominal()
{
	return Entry() == 17;
}

bool Observe_Entry_MatchesProvider()
{
	return Entry() == SharedValue();
}
