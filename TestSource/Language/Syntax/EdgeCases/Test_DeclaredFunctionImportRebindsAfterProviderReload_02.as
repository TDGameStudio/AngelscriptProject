// Theme: Language.Syntax.EdgeCases. Positive import-provider v2 after reload.
// C++: AngelscriptCompilerImportReloadTests.cpp::DeclaredFunctionImportRebindsAfterProviderReload block 2
// sha256=d4a20de1933924ff5e9bf21cc82be5631ad9f062b8fbd618d8e4514f0cbcf507; lines 97-102.
// Oracle: SharedValue() returns 2. Extra: repeating SharedValue stays 2.
// DefaultSafe.

int SharedValue()
{
	return 2;
}

bool Observe_ImportReloadProviderV2_Nominal()
{
	return SharedValue() == 2;
}

bool Observe_ImportReloadProviderV2_RepeatCall()
{
	int First = SharedValue();
	int Second = SharedValue();
	return First == 2 && Second == 2;
}
