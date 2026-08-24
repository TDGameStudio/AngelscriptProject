// Theme: World.Component. WorldStory: GetComponent by class/name, including
// missing and wrong-class nulls.
// C++: AngelscriptActorComponentTests.cpp::GetComponent
// sha256=185eaeda72c445ce175de052d9f110a4581ffd3d8e25119de393c4afa547dad1; lines 329-389.
// Oracle FindBillboardWithWrongClassForCpp, FindMissingSceneByNameForCpp,
// FindMissingComponentByClassForCpp return null. Extra: local construct all
// Find* return null. FixtureIsolated.

UCLASS()
class UTestActorGetComponentMissing : UActorComponent
{
}

UCLASS()
class ATestActorGetComponent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UStaticMeshComponent Mesh;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UBillboardComponent Billboard;

	UFUNCTION()
	UActorComponent FindFirstSceneByClassForCpp()
	{
		return GetComponent(USceneComponent::StaticClass());
	}

	UFUNCTION()
	UActorComponent FindMeshByClassForCpp()
	{
		return GetComponent(UStaticMeshComponent::StaticClass());
	}

	UFUNCTION()
	UActorComponent FindRootByClassAndNameForCpp()
	{
		return GetComponent(USceneComponent::StaticClass(), n"RootScene");
	}

	UFUNCTION()
	UActorComponent FindMeshByParentClassAndNameForCpp()
	{
		return GetComponent(USceneComponent::StaticClass(), n"Mesh");
	}

	UFUNCTION()
	UActorComponent FindBillboardWithWrongClassForCpp()
	{
		return GetComponent(UStaticMeshComponent::StaticClass(), n"Billboard");
	}

	UFUNCTION()
	UActorComponent FindMissingSceneByNameForCpp()
	{
		return GetComponent(USceneComponent::StaticClass(), n"MissingScene");
	}

	UFUNCTION()
	UActorComponent FindMissingComponentByClassForCpp()
	{
		return GetComponent(UTestActorGetComponentMissing::StaticClass());
	}
}

bool Observe_GetComponent_DefaultNull(ATestActorGetComponent Actor)
{
	if (Actor is null)
	{
		throw("Test_GetComponent setup: required Actor is null");
	}
	return Actor.RootScene == nullptr
		&& Actor.Mesh == nullptr
		&& Actor.Billboard == nullptr;
}

bool Observe_GetComponent_MissingAndWrongClassNull(ATestActorGetComponent Actor)
{
	if (Actor is null)
	{
		throw("Test_GetComponent setup: required Actor is null");
	}
	return Actor.FindBillboardWithWrongClassForCpp() == nullptr
		&& Actor.FindMissingSceneByNameForCpp() == nullptr
		&& Actor.FindMissingComponentByClassForCpp() == nullptr;
}
