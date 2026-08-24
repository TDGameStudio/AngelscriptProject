// Theme: Language.Syntax.EdgeCases. Positive import-provider v1.
// C++: AngelscriptCompilerImportReloadTests.cpp::DeclaredFunctionImportRebindsAfterProviderReload block 1
// sha256=ff550a0b178158619bcebfdaf520fe0a05f7c97fa52a659a02df63a3afac54a5; lines 90-95.
// Oracle: SharedValue() returns 1. Extra: repeating SharedValue stays 1.
// DefaultSafe.

int SharedValue()
{
	return 1;
}

bool Observe_ImportReloadProviderV1_Nominal()
{
	return SharedValue() == 1;
}

bool Observe_ImportReloadProviderV1_RepeatCall()
{
	int First = SharedValue();
	int Second = SharedValue();
	return First == 1 && Second == 1;
}
