// Theme: Feature.DefaultComponent. WorldStory RootScene -> MidScene -> LeafScene attach chain.
// C++: AngelscriptComponentTests.cpp::DeepAttachChain
// Oracle: MidScene and LeafScene properties exist on the generated class.
// Extra: empty actor is null; Mid/Leaf default handles are null. FixtureIsolated.

UCLASS()
class ADeepAttachActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	USceneComponent MidScene;

	UPROPERTY(DefaultComponent, Attach = MidScene)
	USceneComponent LeafScene;
}

bool Observe_DeepAttachActor_EmptyDefaultIsNull()
{
	ADeepAttachActor Actor;
	return Actor == nullptr;
}

bool Observe_DeepAttach_MidDefaultIsNull(ADeepAttachActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0193 setup: required ADeepAttachActor is null");
	}
	return Actor.MidScene == nullptr;
}

bool Observe_DeepAttach_LeafDefaultIsNull(ADeepAttachActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0193 setup: required ADeepAttachActor is null");
	}
	return Actor.LeafScene == nullptr;
}
