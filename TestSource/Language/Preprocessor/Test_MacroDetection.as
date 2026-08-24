// Theme: Language.Preprocessor. WorldStory: UPROPERTY Mesh and UFUNCTION BeginPlay.
// C++: AngelscriptPreprocessorBasicTests.cpp::MacroDetection
// lines 73-84; preprocess records property macro Mesh and function macro BeginPlay.
// sha256=37ad72c168426874b23a1b064d767bf009984f512097a98f984d01bb9a8836ef.
// Oracle: Mesh default is null; empty BeginPlay does not assign Mesh.
// Extra: null Mesh is the empty/default vector; BeginPlay is a no-op override.
// FixtureIsolated. Keep UPROPERTY name Mesh.

class AMacroActor : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	UStaticMesh Mesh;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
	}
}

bool Observe_Mesh_DefaultNull(AMacroActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MacroDetection setup: required Actor is null");
	}
	return Actor.Mesh is null;
}

bool Observe_BeginPlay_EmptyOverride(AMacroActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MacroDetection setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.Mesh is null;
}
