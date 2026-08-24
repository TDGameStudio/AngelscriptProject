// Theme: World.Component. WorldStory: GetAllComponents fill/store arrays.
// C++: AngelscriptActorComponentTests.cpp::GetAllComponents
// sha256=a42f11f164f497bcfddbf7df4cf952bab6cf3f70007a68cb3d31a85d88201880; lines 555-671.
// Oracle seven actor/scene components, two billboards; FillNoStaticMeshMatches empty.
// Extra: local construct stored arrays empty, CompA/DerivedB null.
// FixtureIsolated.

UCLASS()
class UTestCompA : USceneComponent
{
}

UCLASS()
class UTestCompB : USceneComponent
{
}

UCLASS()
class UTestCompDerivedB : UTestCompB
{
}

UCLASS()
class ATestActorGetAllComponents : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestCompA CompA;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UTestCompB CompB;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UTestCompB CompB2;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UTestCompDerivedB DerivedB;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UTestCompDerivedB DerivedB2;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UBillboardComponent Billboard;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UBillboardComponent Billboard2;

	UPROPERTY()
	TArray<UActorComponent> LastBFamilyForCpp;

	UPROPERTY()
	TArray<UActorComponent> LastAllComponentsForCpp;

	UPROPERTY()
	TArray<UActorComponent> LastBillboardsForCpp;

	UFUNCTION()
	UActorComponent ReturnRootForCpp()
	{
		return CompA;
	}

	UFUNCTION()
	UActorComponent ReturnDerivedForCpp()
	{
		return DerivedB;
	}

	UFUNCTION()
	void FillAllActorComponentsForCpp(TArray<UActorComponent>& OutComponents)
	{
		GetAllComponents(UActorComponent::StaticClass(), OutComponents);
	}

	UFUNCTION()
	void FillAllSceneComponentsForCpp(TArray<UActorComponent>& OutComponents)
	{
		GetAllComponents(USceneComponent::StaticClass(), OutComponents);
	}

	UFUNCTION()
	void FillBFamilyForCpp(TArray<UActorComponent>& OutComponents)
	{
		GetAllComponents(UTestCompB::StaticClass(), OutComponents);
	}

	UFUNCTION()
	void FillDerivedBOnlyForCpp(TArray<UActorComponent>& OutComponents)
	{
		GetAllComponents(UTestCompDerivedB::StaticClass(), OutComponents);
	}

	UFUNCTION()
	void FillBillboardsForCpp(TArray<UActorComponent>& OutComponents)
	{
		GetAllComponents(UBillboardComponent::StaticClass(), OutComponents);
	}

	UFUNCTION()
	void FillNoStaticMeshMatchesForCpp(TArray<UActorComponent>& OutComponents)
	{
		GetAllComponents(UStaticMeshComponent::StaticClass(), OutComponents);
	}

	UFUNCTION()
	void AppendBillboardsForCpp(TArray<UActorComponent>& OutComponents)
	{
		GetAllComponents(UBillboardComponent::StaticClass(), OutComponents);
	}

	UFUNCTION()
	void StoreArraysForCpp()
	{
		LastBFamilyForCpp.Empty();
		GetAllComponents(UTestCompB::StaticClass(), LastBFamilyForCpp);

		LastAllComponentsForCpp.Empty();
		GetAllComponents(UActorComponent::StaticClass(), LastAllComponentsForCpp);

		LastBillboardsForCpp.Empty();
		GetAllComponents(UBillboardComponent::StaticClass(), LastBillboardsForCpp);
	}
}

bool Observe_GetAllComponents_DefaultEmpty(ATestActorGetAllComponents Actor)
{
	if (Actor is null)
	{
		throw("Test_GetAllComponents setup: required Actor is null");
	}
	return Actor.LastBFamilyForCpp.Num() == 0
		&& Actor.LastAllComponentsForCpp.Num() == 0
		&& Actor.LastBillboardsForCpp.Num() == 0
		&& Actor.CompA == nullptr
		&& Actor.DerivedB == nullptr
		&& Actor.ReturnRootForCpp() == nullptr
		&& Actor.ReturnDerivedForCpp() == nullptr;
}

bool Observe_GetAllComponents_NoStaticMeshEmpty(ATestActorGetAllComponents Actor)
{
	if (Actor is null)
	{
		throw("Test_GetAllComponents setup: required Actor is null");
	}
	TArray<UActorComponent> OutComponents;
	Actor.FillNoStaticMeshMatchesForCpp(OutComponents);
	return OutComponents.Num() == 0;
}
