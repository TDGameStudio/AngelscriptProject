// Theme: Definitions.UClass. WorldStory recompile pair BEFORE class switch.
// C++: AngelscriptScriptClassCreationTests.cpp::RecompileDoesNotCrashClassSwitch block 1
// Oracle: InitialGenerationValue == 1. Retained class name; replaced default 1 -> 2 in the after file.
// Extra: nullptr actor is the empty handle; mutating First does not write Second.
// FixtureIsolated. Pair with Test_RecompileDoesNotCrashClassSwitch_02.as. Keep GenerationValue.

UCLASS()
class ATestScriptClassRecompileDoesNotCrashClassSwitch : AActor
{
	UPROPERTY()
	int GenerationValue = 1;
}

bool Observe_InitialGeneration_Nominal(ATestScriptClassRecompileDoesNotCrashClassSwitch Actor)
{
	return Actor.GenerationValue == 1;
}

bool Observe_InitialGeneration_NullDefault()
{
	ATestScriptClassRecompileDoesNotCrashClassSwitch Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_InitialGeneration_CopyIndependent(
	ATestScriptClassRecompileDoesNotCrashClassSwitch First,
	ATestScriptClassRecompileDoesNotCrashClassSwitch Second)
{
	First.GenerationValue = 99;
	return Second.GenerationValue == 1;
}
