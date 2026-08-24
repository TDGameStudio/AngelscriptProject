// Theme: Feature.DefaultComponent. WorldStory scripted root DefaultComponent.
// C++: AngelscriptComponentTests.cpp::Basic
// Oracle after spawn: actor root IsA UTestDefaultComponentBasicRoot.
// Extra: empty actor / empty root class handle are null. FixtureIsolated.

UCLASS()
class UTestDefaultComponentBasicRoot : USceneComponent
{
}

UCLASS()
class ATestDefaultComponentBasic : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestDefaultComponentBasicRoot RootScene;
}

bool Observe_BasicActor_EmptyDefaultIsNull()
{
	ATestDefaultComponentBasic Actor;
	return Actor == nullptr;
}

bool Observe_BasicRoot_EmptyDefaultIsNull()
{
	UTestDefaultComponentBasicRoot Comp;
	return Comp == nullptr;
}

bool Observe_BasicRootScene_DefaultIsNull(ATestDefaultComponentBasic Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0190 setup: required ATestDefaultComponentBasic is null");
	}
	return Actor.RootScene == nullptr;
}
