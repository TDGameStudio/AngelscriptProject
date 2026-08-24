// Theme: Definitions.UClass. WorldStory recompile pair AFTER class switch.
// C++: AngelscriptScriptClassCreationTests.cpp::RecompileDoesNotCrashClassSwitch block 2
// Oracle: RecompiledGenerationValue == 2; AddedAfterRecompile == 17. Replaced default 1; retained class name.
// Extra: nullptr actor is the empty handle; mutating First does not write Second.
// FixtureIsolated. Pair with Test_RecompileDoesNotCrashClassSwitch_01.as. Keep GenerationValue/AddedAfterRecompile.

UCLASS()
class ATestScriptClassRecompileDoesNotCrashClassSwitch : AActor
{
	UPROPERTY()
	int GenerationValue = 2;

	UPROPERTY()
	int AddedAfterRecompile = 17;
}

bool Observe_RecompiledGeneration_Nominal(ATestScriptClassRecompileDoesNotCrashClassSwitch Actor)
{
	return Actor.GenerationValue == 2 && Actor.AddedAfterRecompile == 17;
}

bool Observe_RecompiledGeneration_NullDefault()
{
	ATestScriptClassRecompileDoesNotCrashClassSwitch Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_RecompiledGeneration_CopyIndependent(
	ATestScriptClassRecompileDoesNotCrashClassSwitch First,
	ATestScriptClassRecompileDoesNotCrashClassSwitch Second)
{
	First.GenerationValue = 0;
	First.AddedAfterRecompile = 0;
	return Second.GenerationValue == 2 && Second.AddedAfterRecompile == 17;
}
