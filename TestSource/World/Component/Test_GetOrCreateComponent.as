// Theme: World.Component. WorldStory: GetOrCreateComponent reuse vs lazy create.
// C++: AngelscriptActorComponentTests.cpp::GetOrCreateComponent
// sha256=671e6fbd21124dd5201cc25d72839f292f089bb5eaeb357f80bfe56c3530c9ef; lines 453-496.
// Oracle existing root reused; lazy names preserved. Extra: local construct
// RootScene null. FixtureIsolated.

UCLASS()
class ATestActorGetOrCreateComponent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UFUNCTION()
	UActorComponent GetExistingRootByNameForCpp()
	{
		return GetOrCreateComponent(USceneComponent::StaticClass(), n"RootScene");
	}

	UFUNCTION()
	UActorComponent GetExistingRootByClassForCpp()
	{
		return GetOrCreateComponent(USceneComponent::StaticClass());
	}

	UFUNCTION()
	USceneComponent CreateLazySceneForCpp()
	{
		return Cast<USceneComponent>(GetOrCreateComponent(USceneComponent::StaticClass(), n"LazyScene"));
	}

	UFUNCTION()
	UActorComponent GetLazySceneAgainForCpp()
	{
		return GetOrCreateComponent(USceneComponent::StaticClass(), n"LazyScene");
	}

	UFUNCTION()
	UBillboardComponent CreateLazyBillboardForCpp()
	{
		return Cast<UBillboardComponent>(GetOrCreateComponent(UBillboardComponent::StaticClass(), n"LazyBillboard"));
	}

	UFUNCTION()
	UActorComponent GetLazyBillboardBySceneClassForCpp()
	{
		return GetOrCreateComponent(USceneComponent::StaticClass(), n"LazyBillboard");
	}
}

bool Observe_GetOrCreateComponent_DefaultNull(ATestActorGetOrCreateComponent Actor)
{
	if (Actor is null)
	{
		throw("Test_GetOrCreateComponent setup: required Actor is null");
	}
	return Actor.RootScene == nullptr;
}

bool Observe_GetOrCreateComponent_CopyIndependence(ATestActorGetOrCreateComponent First, ATestActorGetOrCreateComponent Second)
{
	if (First is null)
	{
		throw("Test_GetOrCreateComponent setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_GetOrCreateComponent setup: required Second is null");
	}
	return First.RootScene == nullptr && Second.RootScene == nullptr;
}
