// Purpose: Observe component destroy, editor-only flags, visualization
// marking, and Create helpers on a runner-owned actor.
// AS-facing API: void UActorComponent.DestroyComponent(bool bPromoteChildren = false);
// void UActorComponent.SetbTickInEditor(bool Value);
// void UActorComponent.SetbIsEditorOnly(bool Value);
// void UActorComponent.SetIsVisualizationComponent(bool Value);
// UActorComponent AActor.CreateComponent(const TSubclassOf<UActorComponent>& ComponentClass, const FName& WithName = NAME_None);
// <ComponentType> <ComponentType>::Create(AActor Actor, const FName& WithName = NAME_None);
// Inputs: Runner-owned Actor/Component, USceneComponent class, unique create
// names, true/false editor flags, and DestroyComponent with default and
// explicit promote.
// Expected observations: CreateComponent returns a live specialized
// component. Typed Create returns USceneComponent. DestroyComponent unregisters
// the created component so GetComponent by that name is null. Visualization
// true then false is visible on IsVisualizationComponent when
// bExpectVisualizationTrue is true.
// Boundary/ownership: SetupOwner=Runner. Created components are destroyed in
// this file. bPromoteChildren reattaches scene children before destroy.

namespace TS_UActorComponent_MutationAndLifecycle_01
{
	bool Observe_DestroyComponent_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_UActorComponent_MutationAndLifecycle_01 setup: required Actor is null");
		}
		TSubclassOf<UActorComponent> SceneClass = USceneComponent::StaticClass();
		UActorComponent DefaultDestroy = Actor.CreateComponent(SceneClass, n"TS_DefaultDestroy");
		if (DefaultDestroy is null)
		{
			throw("TS_UActorComponent_MutationAndLifecycle_01 setup: CreateComponent DefaultDestroy returned null");
		}
		DefaultDestroy.DestroyComponent();

		UActorComponent Promoted = Actor.CreateComponent(SceneClass, n"TS_PromoteDestroy");
		if (Promoted is null)
		{
			throw("TS_UActorComponent_MutationAndLifecycle_01 setup: CreateComponent PromoteDestroy returned null");
		}
		Promoted.DestroyComponent(true);

		UActorComponent Unpromoted = Actor.CreateComponent(SceneClass, n"TS_UnpromoteDestroy");
		if (Unpromoted is null)
		{
			throw("TS_UActorComponent_MutationAndLifecycle_01 setup: CreateComponent UnpromoteDestroy returned null");
		}
		Unpromoted.DestroyComponent(false);

		return Actor.GetComponent(SceneClass, n"TS_DefaultDestroy") is null &&
			Actor.GetComponent(SceneClass, n"TS_PromoteDestroy") is null &&
			Actor.GetComponent(SceneClass, n"TS_UnpromoteDestroy") is null;
	}

	bool Observe_SetbTickInEditor_Nominal(UActorComponent Component, AActor ExpectedOwner)
	{
		if (Component is null)
		{
			throw("TS_UActorComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		Component.SetbTickInEditor(true);
		Component.SetbTickInEditor(true);
		Component.SetbTickInEditor(false);
		return Component.GetOwner() == ExpectedOwner;
	}

	bool Observe_SetbIsEditorOnly_Nominal(UActorComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UActorComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		bool bBefore = Component.IsEditorOnly();
		Component.SetbIsEditorOnly(true);
		bool bMarked = Component.IsEditorOnly();
		Component.SetbIsEditorOnly(true);
		bool bRepeated = Component.IsEditorOnly();
		Component.SetbIsEditorOnly(false);
		bool bCleared = Component.IsEditorOnly();
		Component.SetbIsEditorOnly(bBefore);
		return bMarked && bRepeated && !bCleared;
	}

	bool Observe_SetIsVisualizationComponent_Nominal(UActorComponent Component, bool bExpectVisualizationTrue)
	{
		if (Component is null)
		{
			throw("TS_UActorComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		bool bBefore = Component.IsVisualizationComponent();
		Component.SetIsVisualizationComponent(true);
		bool bMarked = Component.IsVisualizationComponent();
		Component.SetIsVisualizationComponent(false);
		bool bCleared = Component.IsVisualizationComponent();
		Component.SetIsVisualizationComponent(bBefore);
		return bMarked == bExpectVisualizationTrue && !bCleared;
	}

	bool Observe_CreateComponent_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_UActorComponent_MutationAndLifecycle_01 setup: required Actor is null");
		}
		TSubclassOf<UActorComponent> SceneClass = USceneComponent::StaticClass();
		UActorComponent Unnamed = Actor.CreateComponent(SceneClass);
		UActorComponent Named = Actor.CreateComponent(SceneClass, n"TS_Created");
		UActorComponent NoneName = Actor.CreateComponent(SceneClass, NAME_None);
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

	bool Observe_Create_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_UActorComponent_MutationAndLifecycle_01 setup: required Actor is null");
		}
		USceneComponent Unnamed = USceneComponent::Create(Actor);
		USceneComponent Named = USceneComponent::Create(Actor, n"TS_TypedCreate");
		USceneComponent NoneName = USceneComponent::Create(Actor, NAME_None);
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
