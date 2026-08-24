// Theme: Definitions.UClass. WorldStory: script actor compiles to a generated UClass.
// C++: AngelscriptScriptClassCreationTests.cpp::CompilesToUClass CompileScriptModule then ReadPropertyValue.
// Oracle: spawned instance SpawnMarker == 7; class is AActor-derived.
// Extra: EmptyMarker 0 is the empty/default vector; mutating one actor does not write the other.
// FixtureIsolated. Runner owns spawn and World teardown. Keep SpawnMarker for VerifyByPath.

UCLASS()
class ATestScriptClassCompilesToUClass : AActor
{
	UPROPERTY()
	int SpawnMarker = 7;

	UPROPERTY()
	int EmptyMarker = 0;
}

int Observe_CompilesToUClass_SpawnMarkerDefault(ATestScriptClassCompilesToUClass Actor)
{
	return Actor.SpawnMarker;
}

int Observe_CompilesToUClass_EmptyMarkerDefault(ATestScriptClassCompilesToUClass Actor)
{
	return Actor.EmptyMarker;
}

bool Observe_CompilesToUClass_IsActorChild()
{
	return ATestScriptClassCompilesToUClass::StaticClass().IsChildOf(AActor::StaticClass());
}

bool Observe_CompilesToUClass_CopyIndependent(ATestScriptClassCompilesToUClass First, ATestScriptClassCompilesToUClass Second)
{
	First.SpawnMarker = 1;
	return Second.SpawnMarker == 7;
}
