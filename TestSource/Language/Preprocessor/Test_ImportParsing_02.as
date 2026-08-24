// Theme: Language.Preprocessor. Positive: manual import is resolved then stripped.
// C++: AngelscriptPreprocessorBasicTests.cpp::ImportParsing UsesImport.as
// lines 128-134;
// sha256=d40909a8f6892292773a5e9ba8ee0fc7dfae54b8219605f5cae74cfdf7a5cd.
// Oracle: UseShared() == 11 via SharedValue().
// Extra: 11 is the provider return; import line stays in authored source.
// DefaultSafe. Import identity: Tests.Preprocessor.Shared.

import Tests.Preprocessor.Shared;

int UseShared()
{
	return SharedValue();
}

bool Observe_UseShared_Nominal()
{
	return UseShared() == 11;
}
