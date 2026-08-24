// Theme: Language.Syntax.EdgeCases. Positive import consumer after provider reload.
// C++: AngelscriptCompilerImportReloadTests.cpp::DeclaredFunctionImportRebindsAfterProviderReload block 3
// sha256=0fc3449de9cef6e07980aa55b4d04f383166b5340ab1513af7697241ad1b377c; lines 104-111.
// Oracle: Entry() returns the imported SharedValue. Extra: repeating Entry is
// stable for a given provider version. DefaultSafe.

import int SharedValue() from "Tests.Compiler.ImportReloadSource";

int Entry()
{
	return SharedValue();
}

bool Observe_ImportReloadConsumer_Nominal(int ExpectedShared)
{
	return Entry() == ExpectedShared && SharedValue() == ExpectedShared;
}

bool Observe_ImportReloadConsumer_RepeatCall(int ExpectedShared)
{
	int First = Entry();
	int Second = Entry();
	return First == ExpectedShared && Second == ExpectedShared;
}
