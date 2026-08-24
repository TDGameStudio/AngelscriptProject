// Theme: Feature.DefaultComponent. Positive RootComponent plus Attach DefaultComponent.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Positive_Attach
// Oracle: AssertCompiles ADefCompAttachActor. Extra: empty actor is null;
// Mesh default handle is null. FixtureIsolated.

class ADefCompAttachActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach = Root)
	UStaticMeshComponent Mesh;
}

bool Observe_DefCompAttach_EmptyDefaultIsNull()
{
	ADefCompAttachActor Actor;
	return Actor == nullptr;
}

bool Observe_DefCompAttach_MeshDefaultIsNull(ADefCompAttachActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0286 setup: required ADefCompAttachActor is null");
	}
	return Actor.Mesh == nullptr;
}
