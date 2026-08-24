// Theme: Feature.DefaultComponent. WorldStory root plus attached billboard DefaultComponents.
// C++: AngelscriptComponentTests.cpp::Multiple
// Oracle after spawn: Billboard attach parent is RootScene.
// Extra: empty actor / empty component handles are null. FixtureIsolated.

UCLASS()
class UTestDefaultComponentMultipleRoot : USceneComponent
{
}

UCLASS()
class UTestDefaultComponentMultipleBillboard : UBillboardComponent
{
}

UCLASS()
class ATestDefaultComponentMultiple : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestDefaultComponentMultipleRoot RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UTestDefaultComponentMultipleBillboard Billboard;
}

bool Observe_MultipleActor_EmptyDefaultIsNull()
{
	ATestDefaultComponentMultiple Actor;
	return Actor == nullptr;
}

bool Observe_MultipleRoot_EmptyDefaultIsNull()
{
	UTestDefaultComponentMultipleRoot Comp;
	return Comp == nullptr;
}

bool Observe_MultipleBillboard_EmptyDefaultIsNull()
{
	UTestDefaultComponentMultipleBillboard Comp;
	return Comp == nullptr;
}
