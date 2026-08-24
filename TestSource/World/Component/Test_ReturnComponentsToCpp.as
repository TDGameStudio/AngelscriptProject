// Theme: World.Component. WorldStory: return typed components and arrays to C++.
// C++: AngelscriptActorComponentTests.cpp::ReturnComponentsToCpp
// sha256=996595abb891e0d6e76a9daf51421711e1bbf54cadebe83bdefd34d1f7e35129; lines 817-916.
// Oracle ReturnBaseAForCpp / ReturnDerivedBForCpp identity. Extra: local
// construct stored arrays empty, BaseA/DerivedB null. FixtureIsolated.

UCLASS()
class UReturnComponentBase : USceneComponent
{
}

UCLASS()
class UReturnComponentDerived : UReturnComponentBase
{
}

UCLASS()
class ATestActorReturnComponentsToCpp : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UReturnComponentBase BaseA;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UReturnComponentBase BaseB;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UReturnComponentDerived DerivedA;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UReturnComponentDerived DerivedB;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UBillboardComponent BillboardA;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UBillboardComponent BillboardB;

	UPROPERTY()
	TArray<UActorComponent> StoredBaseFamily;

	UPROPERTY()
	TArray<UActorComponent> StoredAllComponents;

	UPROPERTY()
	TArray<UActorComponent> StoredBillboards;

	UFUNCTION()
	UActorComponent ReturnBaseAForCpp()
	{
		return BaseA;
	}

	UFUNCTION()
	UActorComponent ReturnDerivedBForCpp()
	{
		return DerivedB;
	}

	UFUNCTION()
	UActorComponent ReturnComponentByNameForCpp(FName ComponentName)
	{
		return GetComponent(UActorComponent::StaticClass(), ComponentName);
	}

	UFUNCTION()
	USceneComponent ReturnCreatedNamedSceneForCpp()
	{
		return Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"CppExplicitNamedScene"));
	}

	UFUNCTION()
	void ReturnBaseFamilyArrayForCpp(TArray<UActorComponent>& OutComponents)
	{
		GetAllComponents(UReturnComponentBase::StaticClass(), OutComponents);
	}

	UFUNCTION()
	void ReturnAllComponentsArrayForCpp(TArray<UActorComponent>& OutComponents)
	{
		GetAllComponents(UActorComponent::StaticClass(), OutComponents);
	}

	UFUNCTION()
	void AppendBillboardArrayForCpp(TArray<UActorComponent>& OutComponents)
	{
		GetAllComponents(UBillboardComponent::StaticClass(), OutComponents);
	}

	UFUNCTION()
	void StoreComponentArraysForCpp()
	{
		StoredBaseFamily.Empty();
		GetAllComponents(UReturnComponentBase::StaticClass(), StoredBaseFamily);

		StoredAllComponents.Empty();
		GetAllComponents(UActorComponent::StaticClass(), StoredAllComponents);

		StoredBillboards.Empty();
		GetAllComponents(UBillboardComponent::StaticClass(), StoredBillboards);
	}
}

bool Observe_ReturnComponents_DefaultEmpty(ATestActorReturnComponentsToCpp Actor)
{
	if (Actor is null)
	{
		throw("Test_ReturnComponentsToCpp setup: required Actor is null");
	}
	return Actor.StoredBaseFamily.Num() == 0
		&& Actor.StoredAllComponents.Num() == 0
		&& Actor.StoredBillboards.Num() == 0
		&& Actor.BaseA == nullptr
		&& Actor.DerivedB == nullptr
		&& Actor.ReturnBaseAForCpp() == nullptr
		&& Actor.ReturnDerivedBForCpp() == nullptr
		&& Actor.ReturnComponentByNameForCpp(n"Missing") == nullptr;
}

bool Observe_ReturnComponents_MissingNameNull(ATestActorReturnComponentsToCpp Actor)
{
	if (Actor is null)
	{
		throw("Test_ReturnComponentsToCpp setup: required Actor is null");
	}
	return Actor.ReturnComponentByNameForCpp(n"") == nullptr;
}
