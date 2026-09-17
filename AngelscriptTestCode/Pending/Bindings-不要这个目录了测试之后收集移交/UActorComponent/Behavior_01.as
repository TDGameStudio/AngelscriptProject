/**
 * @version v1
 * @summary Observe render dirtying, activate/deactivate, tag lookup, compiler component helpers, and the optional raw component factory.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe render dirtying, activate/deactivate, tag lookup, compiler component helpers, and the optional raw component factory.
 * @topic Baseline
 */
// Runner owns the Actor/Component fixtures and teardown. Null fixtures are
// setup failure.
// AS-facing API: void UActorComponent.MarkRenderStateDirty();
// void UActorComponent.Activate(bool bReset = false);
// void UActorComponent.Deactivate();
// bool UActorComponent.ComponentHasTag(FName Tag) const;
// void __Actor_GetComponentByClass(const AActor Actor, const TSubclassOf<UObject>& Class, ?& OutComponent, const FName& WithName);
// void __Actor_GetOrCreateComponentByClass(AActor Actor, const TSubclassOf<UObject>& Class, ?& OutComponent, const FName& WithName);
// void __Actor_GetAllComponentsByClass(const AActor Actor, const TSubclassOf<UObject>& Class, ?& OutComponents);
// void __Actor_CreateComponentByClass(AActor Actor, const TSubclassOf<UObject>& Class, ?& OutComponent, const FName& WithName);
// <ComponentType> Value(AActor InActor, FName Name = NAME_None);
// Inputs: Runner-owned Actor and Component, n"Probe", NAME_None, Activate with
// default and bReset true, Expected scene component, and a sentinel for
// GetAllComponentsByClass.
// Expected observations: ComponentHasTag is false for NAME_None and missing
// tags, true after ComponentTags contains Probe. Compiler helpers write the
// specialized OutComponent. Raw Value constructs a scene component.
// Boundary/ownership: SetupOwner=Runner. CleanupOwner=Runner. Created
// components from Create helpers are destroyed in this file. NAME_None is
// treated as no tag.

namespace TS_UActorComponent_Behavior_01
{
	bool Observe_MarkRenderStateDirty_Nominal(UActorComponent Component, AActor ExpectedOwner)
	{
		if (Component is null)
		{
			throw("TS_UActorComponent_Behavior_01 setup: required Component is null");
		}
		Component.MarkRenderStateDirty();
		Component.MarkRenderStateDirty();
		return Component.GetOwner() == ExpectedOwner;
	}

	bool Observe_Activate_Nominal(UActorComponent Component, AActor ExpectedOwner)
	{
		if (Component is null)
		{
			throw("TS_UActorComponent_Behavior_01 setup: required Component is null");
		}
		Component.Activate();
		Component.Activate(false);
		Component.Activate(true);
		return Component.GetOwner() == ExpectedOwner;
	}

	bool Observe_Deactivate_Nominal(UActorComponent Component, AActor ExpectedOwner)
	{
		if (Component is null)
		{
			throw("TS_UActorComponent_Behavior_01 setup: required Component is null");
		}
		Component.Activate(true);
		Component.Deactivate();
		Component.Deactivate();
		return Component.GetOwner() == ExpectedOwner;
	}

	bool Observe_ComponentHasTag_Nominal(UActorComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UActorComponent_Behavior_01 setup: required Component is null");
		}
		bool bNoneTag = Component.ComponentHasTag(NAME_None);
		bool bMissing = Component.ComponentHasTag(n"Missing");
		Component.ComponentTags.Add(n"Probe");
		bool bHasProbe = Component.ComponentHasTag(n"Probe");
		Component.ComponentTags.Remove(n"Probe");
		return !bNoneTag && !bMissing && bHasProbe && !Component.ComponentHasTag(n"Probe");
	}

	bool Observe___Actor_GetComponentByClass_Nominal(AActor Actor, USceneComponent ExpectedAny, USceneComponent ExpectedRoot)
	{
		if (Actor is null)
		{
			throw("TS_UActorComponent_Behavior_01 setup: required Actor is null");
		}
		USceneComponent OutComponent;
		__Actor_GetComponentByClass(Actor, USceneComponent::StaticClass(), OutComponent, NAME_None);
		USceneComponent Named;
		__Actor_GetComponentByClass(Actor, USceneComponent::StaticClass(), Named, n"Root");
		return OutComponent == ExpectedAny && Named == ExpectedRoot;
	}

	bool Observe___Actor_GetOrCreateComponentByClass_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_UActorComponent_Behavior_01 setup: required Actor is null");
		}
		USceneComponent OutComponent;
		__Actor_GetOrCreateComponentByClass(Actor, USceneComponent::StaticClass(), OutComponent, NAME_None);
		USceneComponent Named;
		__Actor_GetOrCreateComponentByClass(Actor, USceneComponent::StaticClass(), Named, n"TS_HelperOrCreate");
		USceneComponent Again;
		__Actor_GetOrCreateComponentByClass(Actor, USceneComponent::StaticClass(), Again, n"TS_HelperOrCreate");
		bool bCreated = OutComponent != nullptr && Named != nullptr && Again == Named;
		if (Named != nullptr)
		{
			Named.DestroyComponent();
		}
		return bCreated;
	}

	bool Observe___Actor_GetAllComponentsByClass_Nominal(AActor Actor, USceneComponent Sentinel)
	{
		if (Actor is null)
		{
			throw("TS_UActorComponent_Behavior_01 setup: required Actor is null");
		}
		TArray<USceneComponent> OutComponents;
		OutComponents.Add(Sentinel);
		int32 SeededNum = OutComponents.Num();
		__Actor_GetAllComponentsByClass(Actor, USceneComponent::StaticClass(), OutComponents);
		return OutComponents.Num() >= SeededNum && OutComponents[0] == Sentinel;
	}

	bool Observe___Actor_CreateComponentByClass_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_UActorComponent_Behavior_01 setup: required Actor is null");
		}
		USceneComponent OutComponent;
		__Actor_CreateComponentByClass(Actor, USceneComponent::StaticClass(), OutComponent, NAME_None);
		USceneComponent Named;
		__Actor_CreateComponentByClass(Actor, USceneComponent::StaticClass(), Named, n"TS_HelperCreate");
		bool bCreated = OutComponent != nullptr && Named != nullptr;
		if (OutComponent != nullptr)
		{
			OutComponent.DestroyComponent();
		}
		if (Named != nullptr)
		{
			Named.DestroyComponent();
		}
		return bCreated;
	}

	bool Observe_Value_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_UActorComponent_Behavior_01 setup: required Actor is null");
		}
		USceneComponent Unnamed = USceneComponent(Actor);
		USceneComponent Named = USceneComponent(Actor, n"TS_Factory");
		USceneComponent NoneName = USceneComponent(Actor, NAME_None);
		bool bCreated = Unnamed != nullptr && Named != nullptr && NoneName != nullptr;
		if (Unnamed != nullptr)
		{
			Unnamed.DestroyComponent();
		}
		if (Named != nullptr)
		{
			Named.DestroyComponent();
		}
		if (NoneName != nullptr)
		{
			NoneName.DestroyComponent();
		}
		return bCreated;
	}
}
/** @end */
