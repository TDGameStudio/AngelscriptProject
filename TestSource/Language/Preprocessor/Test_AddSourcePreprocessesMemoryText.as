// Theme: Language.Preprocessor. Positive memory-source snippet (no physical filename).
// C++: AngelscriptVirtualScriptPathPreprocessorTests.cpp::AddSourcePreprocessesMemoryText
// sha256=b10539ba99493915949dad58b49fb3976634be5221106d35fdc21b78a2c5bfbb; lines 72-77.
// Oracle: Entry() == 11; module Angelscript.Memory.Immediate.Snippet_001, one code section.
// Extra: repeat stays 11. DefaultSafe.

int Entry()
{
	return 11;
}

bool Observe_Entry_Nominal()
{
	return Entry() == 11;
}

bool Observe_Entry_RepeatBoundary()
{
	return Entry() == 11 && Entry() == 11;
}
