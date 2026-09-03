/**
 * A carrier for the class-analyze hook. C++ injects a generated static that
 * returns 31, but that value is hook injection rather than anything authored
 * here; this script's own Entry returns 5, which is the authored oracle.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.ClassAnalyzeHookCarrier
 * @Harness UClass
 * @Tag Language.Preprocessor.ClassAnalyzeHookCarrier
 * @Provenance C++: AngelscriptPreprocessorCompilationEventsTests.cpp::ClassAnalyzeHookMutatesGeneratedStaticsThroughEngineHooks
 * @Provenance lines 126-136; ClassAnalyzeCount==1; generated EngineHookValue returns 31.
 * @Provenance sha256=084c4bb7df875487ce8153595d9419ac1d273271736b340e503c2e95e3003009.
 * @Provenance Oracle: Entry() == 5. The 31 return is C++ hook injection, not this source.
 * @Provenance Extra: 5 is the authored return; no empty branch in Entry.
 * @Provenance DefaultSafe. Keep UClassAnalyzeHookCarrier / Entry.
 */

UCLASS()
class UClassAnalyzeHookCarrier : UObject
{
	/**
	 * The authored entry point whose value the hook does not alter.
	 *
	 * @Covers Preprocessor.Events
	 * @Inputs none
	 * @Return 5
	 */
	UFUNCTION()
	int Entry()
	{
		return 5;
	}

	/**
	 * Observe that the authored return survives the analyze hook.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Events
	 * @Inputs Entry()
	 * @Return true when the value is 5
	 */
	UFUNCTION()
	bool ClassAnalyzeHookKeepsAuthoredReturn()
	{
		return Entry() == 5;
	}
}
