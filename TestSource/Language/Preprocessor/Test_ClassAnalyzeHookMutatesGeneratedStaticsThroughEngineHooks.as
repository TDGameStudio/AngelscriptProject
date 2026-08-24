// Theme: Language.Preprocessor. Positive: class-analyze hook carrier.
// C++: AngelscriptPreprocessorCompilationEventsTests.cpp::ClassAnalyzeHookMutatesGeneratedStaticsThroughEngineHooks
// lines 126-136; ClassAnalyzeCount==1; generated EngineHookValue returns 31.
// sha256=084c4bb7df875487ce8153595d9419ac1d273271736b340e503c2e95e3003009.
// Oracle: Entry() == 5. The 31 return is C++ hook injection, not this source.
// Extra: 5 is the authored return; no empty branch in Entry.
// DefaultSafe. Keep UClassAnalyzeHookCarrier / Entry.

UCLASS()
class UClassAnalyzeHookCarrier : UObject
{
	UFUNCTION()
	int Entry()
	{
		return 5;
	}
}

bool Observe_Entry_Nominal(UClassAnalyzeHookCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_ClassAnalyzeHookMutatesGeneratedStaticsThroughEngineHooks setup: required Carrier is null");
	}
	return Carrier.Entry() == 5;
}
