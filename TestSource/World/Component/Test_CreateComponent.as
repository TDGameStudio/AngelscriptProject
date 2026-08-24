// Theme: World.Component. WorldStory: CreateComponent returns named scene
// and billboard components to C++.
// C++: AngelscriptActorComponentTests.cpp::CreateComponent
// sha256=1e4bdfcc46807fa61cae29802577616d7ad9f1c86d7b355fcab2bf69f61242b3; lines 214-260.
// Oracle C++ receives DynamicRoot/DynamicChild/DynamicBillboard and
// FindDynamicBillboardAsWrongTypeForCpp is null. Extra: local construct
// FindDynamicRootForCpp / FindDynamicBillboardForCpp / wrong type all null
// because Create* was not called. FixtureIsolated.

UCLASS()
class ATestActorCreateComponent : AActor
{
	UFUNCTION()
	USceneComponent CreateDynamicRootForCpp()
	{
		return Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"DynamicRoot"));
	}

	UFUNCTION()
	USceneComponent CreateDynamicChildForCpp()
	{
		return Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"DynamicChild"));
	}

	UFUNCTION()
	UBillboardComponent CreateDynamicBillboardForCpp()
	{
		return Cast<UBillboardComponent>(CreateComponent(UBillboardComponent::StaticClass(), n"DynamicBillboard"));
	}

	UFUNCTION()
	USceneComponent CreateNamedSceneForCpp()
	{
		return Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"CppReturnedNamedScene"));
	}

	UFUNCTION()
	UActorComponent FindDynamicRootForCpp()
	{
		return GetComponent(USceneComponent::StaticClass(), n"DynamicRoot");
	}

	UFUNCTION()
	UActorComponent FindDynamicBillboardForCpp()
	{
		return GetComponent(UBillboardComponent::StaticClass(), n"DynamicBillboard");
	}

	UFUNCTION()
	UActorComponent FindDynamicBillboardAsWrongTypeForCpp()
	{
		return GetComponent(UStaticMeshComponent::StaticClass(), n"DynamicBillboard");
	}
}

bool Observe_CreateComponent_DefaultMissingNull(ATestActorCreateComponent Actor)
{
	if (Actor is null)
	{
		throw("Test_CreateComponent setup: required Actor is null");
	}
	return Actor.FindDynamicRootForCpp() == nullptr
		&& Actor.FindDynamicBillboardForCpp() == nullptr
		&& Actor.FindDynamicBillboardAsWrongTypeForCpp() == nullptr;
}
