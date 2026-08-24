// Purpose: Observe actor-component BeginPlay/owner/creation/visualization
// queries plus Get/GetOrCreate lookup helpers on a runner-owned actor.
// AS-facing API: bool UActorComponent.HasBegunPlay() const;
// AActor UActorComponent.GetOwner() const;
// EComponentCreationMethod UActorComponent.GetComponentCreationMethod() const;
// bool UActorComponent.IsVisualizationComponent() const;
// UActorComponent FComponentReference.GetComponent(AActor OwningActor) const;
// UActorComponent AActor.GetComponent(const TSubclassOf<UActorComponent>& ComponentClass, const FName& WithName = NAME_None);
// UActorComponent AActor.GetOrCreateComponent(const TSubclassOf<UActorComponent>& ComponentClass, const FName& WithName = NAME_None);
// void AActor.GetAllComponents(UClass ComponentClass, TArray<UActorComponent>& OutComponents);
// <ComponentType> <ComponentType>::Get(const AActor Actor, const FName& WithName = NAME_None);
// <ComponentType> <ComponentType>::GetOrCreate(AActor Actor, const FName& WithName = NAME_None);
// Inputs: Runner-owned Actor and Component, empty FComponentReference,
// NAME_None, n"Root", expected handles, and an output array seeded with a
// sentinel.
// Expected observations: returned bool is the exact comparison. Empty
// component-reference lookup is null. GetAllComponents preserves the seeded
// entry. GetOrCreate of a unique name returns the same instance on repeat.
// Boundary/ownership: SetupOwner=Runner. GetAllComponents appends without a
// clear. Unique-name GetOrCreate components are destroyed in this file.

namespace TS_UActorComponent_Queries_01
{
	bool Observe_HasBegunPlay_Nominal(UActorComponent Component, bool bExpectBegunPlay)
	{
		if (Component is null)
		{
			throw("TS_UActorComponent_Queries_01 setup: required Component is null");
		}
		return Component.HasBegunPlay() == bExpectBegunPlay;
	}

	bool Observe_GetOwner_Nominal(UActorComponent Component, AActor ExpectedOwner)
	{
		if (Component is null)
		{
			throw("TS_UActorComponent_Queries_01 setup: required Component is null");
		}
		return Component.GetOwner() == ExpectedOwner;
	}

	bool Observe_GetComponentCreationMethod_Nominal(UActorComponent Component, EComponentCreationMethod Expected)
	{
		if (Component is null)
		{
			throw("TS_UActorComponent_Queries_01 setup: required Component is null");
		}
		return Component.GetComponentCreationMethod() == Expected;
	}

	bool Observe_IsVisualizationComponent_Nominal(UActorComponent Component, bool bExpectVisualization)
	{
		if (Component is null)
		{
			throw("TS_UActorComponent_Queries_01 setup: required Component is null");
		}
		return Component.IsVisualizationComponent() == bExpectVisualization;
	}

	bool Observe_GetComponent_Nominal(AActor Actor, UActorComponent ExpectedAny, UActorComponent ExpectedRoot)
	{
		if (Actor is null)
		{
			throw("TS_UActorComponent_Queries_01 setup: required Actor is null");
		}
		FComponentReference Reference;
		UActorComponent FromReference = Reference.GetComponent(Actor);
		UActorComponent FromNullOwner = Reference.GetComponent(nullptr);
		TSubclassOf<UActorComponent> SceneClass = USceneComponent::StaticClass();
		UActorComponent AnyName = Actor.GetComponent(SceneClass);
		UActorComponent Named = Actor.GetComponent(SceneClass, n"Root");
		UActorComponent NoneName = Actor.GetComponent(SceneClass, NAME_None);
		return FromReference is null &&
			FromNullOwner is null &&
			AnyName == ExpectedAny &&
			Named == ExpectedRoot &&
			NoneName == ExpectedAny;
	}

	bool Observe_GetOrCreateComponent_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_UActorComponent_Queries_01 setup: required Actor is null");
		}
		TSubclassOf<UActorComponent> SceneClass = USceneComponent::StaticClass();
		UActorComponent Created = Actor.GetOrCreateComponent(SceneClass);
		UActorComponent Named = Actor.GetOrCreateComponent(SceneClass, n"TS_OrCreate");
		UActorComponent Again = Actor.GetOrCreateComponent(SceneClass, n"TS_OrCreate");
		bool bCreated = Created != nullptr && Named != nullptr && Again == Named;
		if (Named != nullptr)
		{
			Named.DestroyComponent();
		}
		return bCreated;
	}

	bool Observe_GetAllComponents_Nominal(AActor Actor, UActorComponent Sentinel)
	{
		if (Actor is null)
		{
			throw("TS_UActorComponent_Queries_01 setup: required Actor is null");
		}
		TArray<UActorComponent> OutComponents;
		OutComponents.Add(Sentinel);
		int32 SeededNum = OutComponents.Num();
		Actor.GetAllComponents(USceneComponent::StaticClass(), OutComponents);
		return OutComponents.Num() >= SeededNum && OutComponents[0] == Sentinel;
	}

	bool Observe_Get_Nominal(AActor Actor, USceneComponent ExpectedAny, USceneComponent ExpectedRoot)
	{
		if (Actor is null)
		{
			throw("TS_UActorComponent_Queries_01 setup: required Actor is null");
		}
		USceneComponent AnyName = USceneComponent::Get(Actor);
		USceneComponent Named = USceneComponent::Get(Actor, n"Root");
		USceneComponent NoneName = USceneComponent::Get(Actor, NAME_None);
		return AnyName == ExpectedAny && Named == ExpectedRoot && NoneName == ExpectedAny;
	}

	bool Observe_GetOrCreate_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_UActorComponent_Queries_01 setup: required Actor is null");
		}
		USceneComponent Created = USceneComponent::GetOrCreate(Actor);
		USceneComponent Named = USceneComponent::GetOrCreate(Actor, n"TS_TypedOrCreate");
		USceneComponent Again = USceneComponent::GetOrCreate(Actor, n"TS_TypedOrCreate");
		bool bCreated = Created != nullptr && Named != nullptr && Again == Named;
		if (Named != nullptr)
		{
			Named.DestroyComponent();
		}
		return bCreated;
	}
}
