// Theme: Feature.DefaultComponent. ShowOnActor with DefaultComponent is valid.
// C++: AngelscriptPreprocessorPropertyTests.cpp::ShowOnActorRequiresDefaultComponent block 2
// CSV NegativeDiagnostic is wrong: this block preprocesses successfully.
// Oracle: RootScene is instanced, editable on defaults/instances, blueprint-readable,
// and carries DefaultComponent metadata.
// Extra: empty actor is null; RootScene default handle is null. Isolation=none.

UCLASS()
class AShowOnActorValidCarrier : AActor
{
	UPROPERTY(DefaultComponent, ShowOnActor, RootComponent)
	USceneComponent RootScene;
}

bool Observe_ShowOnActorValid_EmptyDefaultIsNull()
{
	AShowOnActorValidCarrier Actor;
	return Actor == nullptr;
}

bool Observe_ShowOnActorValid_RootDefaultIsNull(AShowOnActorValidCarrier Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0255 setup: required AShowOnActorValidCarrier is null");
	}
	return Actor.RootScene == nullptr;
}
