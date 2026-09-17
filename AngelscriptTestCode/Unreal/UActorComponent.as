/**
 * @version v1
 * @summary UActorComponent host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic UActorComponent
 *
 * activate
 * deactivate
 * component-has-tag
 * actor-get-component-by-class
 * actor-get-or-create-component-by-class
 * actor-get-all-components-by-class
 * actor-create-component-by-class
 * treated-as-no-tag
 * destroy-component
 * setb-tick-in-editor
 * setb-is-editor-only
 * set-is-visualization-component
 * create-component
 * create
 * has-begun-play
 * get-owner
 * get-component-creation-method
 * is-visualization-component
 * get-component
 * get-or-create-component
 * get-all-components
 * get
 * get-or-create
 */
/**
 * @begin activate
 * @summary treated as no tag.
 * @topic Unreal
 */
/**
 * @function ObserveActivateNominal
 * @summary treated as no tag.
 * @covers UActorComponent.activate
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveActivateNominal(UActorComponent Component, AActor ExpectedOwner)
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
/** @end */
/**
 * @begin deactivate
 * @summary treated as no tag.
 * @topic Unreal
 */
/**
 * @function ObserveDeactivateNominal
 * @summary treated as no tag.
 * @covers UActorComponent.deactivate
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveDeactivateNominal(UActorComponent Component, AActor ExpectedOwner)
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
/** @end */
/**
 * @begin component-has-tag
 * @summary treated as no tag.
 * @topic Unreal
 */
/**
 * @function ObserveComponentHasTagNominal
 * @summary treated as no tag.
 * @covers UActorComponent.component-has-tag
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveComponentHasTagNominal(UActorComponent Component)
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
/** @end */
/**
 * @begin actor-get-component-by-class
 * @summary treated as no tag.
 * @topic Unreal
 */
/**
 * @function ObserveActorGetComponentByClassNominal
 * @summary treated as no tag.
 * @covers UActorComponent.actor-get-component-by-class
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveActorGetComponentByClassNominal(AActor Actor, USceneComponent ExpectedAny, USceneComponent ExpectedRoot)
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
/** @end */
/**
 * @begin actor-get-or-create-component-by-class
 * @summary treated as no tag.
 * @topic Unreal
 */
/**
 * @function ObserveActorGetOrCreateComponentByClassNominal
 * @summary treated as no tag.
 * @covers UActorComponent.actor-get-or-create-component-by-class
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveActorGetOrCreateComponentByClassNominal(AActor Actor)
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
/** @end */
/**
 * @begin actor-get-all-components-by-class
 * @summary treated as no tag.
 * @topic Unreal
 */
/**
 * @function ObserveActorGetAllComponentsByClassNominal
 * @summary treated as no tag.
 * @covers UActorComponent.actor-get-all-components-by-class
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveActorGetAllComponentsByClassNominal(AActor Actor, USceneComponent Sentinel)
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
/** @end */
/**
 * @begin actor-create-component-by-class
 * @summary treated as no tag.
 * @topic Unreal
 */
/**
 * @function ObserveActorCreateComponentByClassNominal
 * @summary treated as no tag.
 * @covers UActorComponent.actor-create-component-by-class
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveActorCreateComponentByClassNominal(AActor Actor)
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
/** @end */
/**
 * @begin treated-as-no-tag
 * @summary treated as no tag.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary treated as no tag.
 * @covers UActorComponent.treated-as-no-tag
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveValueNominal(AActor Actor)
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
/** @end */
/**
 * @begin destroy-component
 * @summary this file.
 * @topic Unreal
 */
/**
 * @function ObserveDestroyComponentNominal
 * @summary this file.
 * @covers UActorComponent.destroy-component
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDestroyComponentNominal(AActor Actor)
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
/** @end */
/**
 * @begin setb-tick-in-editor
 * @summary this file.
 * @topic Unreal
 */
/**
 * @function ObserveSetbTickInEditorNominal
 * @summary this file.
 * @covers UActorComponent.setb-tick-in-editor
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetbTickInEditorNominal(UActorComponent Component, AActor ExpectedOwner)
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
/** @end */
/**
 * @begin setb-is-editor-only
 * @summary this file.
 * @topic Unreal
 */
/**
 * @function ObserveSetbIsEditorOnlyNominal
 * @summary this file.
 * @covers UActorComponent.setb-is-editor-only
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetbIsEditorOnlyNominal(UActorComponent Component)
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
/** @end */
/**
 * @begin set-is-visualization-component
 * @summary this file.
 * @topic Unreal
 */
/**
 * @function ObserveSetIsVisualizationComponentNominal
 * @summary this file.
 * @covers UActorComponent.set-is-visualization-component
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetIsVisualizationComponentNominal(UActorComponent Component, bool bExpectVisualizationTrue)
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
/** @end */
/**
 * @begin create-component
 * @summary this file.
 * @topic Unreal
 */
/**
 * @function ObserveCreateComponentNominal
 * @summary this file.
 * @covers UActorComponent.create-component
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCreateComponentNominal(AActor Actor)
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
/** @end */
/**
 * @begin create
 * @summary this file.
 * @topic Unreal
 */
/**
 * @function ObserveCreateNominal
 * @summary this file.
 * @covers UActorComponent.create
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCreateNominal(AActor Actor)
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
/** @end */
/**
 * @begin has-begun-play
 * @summary clear.
 * @topic Unreal
 */
/**
 * @function ObserveHasBegunPlayNominal
 * @summary clear.
 * @covers UActorComponent.has-begun-play
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveHasBegunPlayNominal(UActorComponent Component, bool bExpectBegunPlay)
{
	if (Component is null)
	{
		throw("TS_UActorComponent_Queries_01 setup: required Component is null");
	}
	return Component.HasBegunPlay() == bExpectBegunPlay;
}
/** @end */
/**
 * @begin get-owner
 * @summary clear.
 * @topic Unreal
 */
/**
 * @function ObserveGetOwnerNominal
 * @summary clear.
 * @covers UActorComponent.get-owner
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetOwnerNominal(UActorComponent Component, AActor ExpectedOwner)
{
	if (Component is null)
	{
		throw("TS_UActorComponent_Queries_01 setup: required Component is null");
	}
	return Component.GetOwner() == ExpectedOwner;
}
/** @end */
/**
 * @begin get-component-creation-method
 * @summary clear.
 * @topic Unreal
 */
/**
 * @function ObserveGetComponentCreationMethodNominal
 * @summary clear.
 * @covers UActorComponent.get-component-creation-method
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetComponentCreationMethodNominal(UActorComponent Component, EComponentCreationMethod Expected)
{
	if (Component is null)
	{
		throw("TS_UActorComponent_Queries_01 setup: required Component is null");
	}
	return Component.GetComponentCreationMethod() == Expected;
}
/** @end */
/**
 * @begin is-visualization-component
 * @summary clear.
 * @topic Unreal
 */
/**
 * @function ObserveIsVisualizationComponentNominal
 * @summary clear.
 * @covers UActorComponent.is-visualization-component
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsVisualizationComponentNominal(UActorComponent Component, bool bExpectVisualization)
{
	if (Component is null)
	{
		throw("TS_UActorComponent_Queries_01 setup: required Component is null");
	}
	return Component.IsVisualizationComponent() == bExpectVisualization;
}
/** @end */
/**
 * @begin get-component
 * @summary clear.
 * @topic Unreal
 */
/**
 * @function ObserveGetComponentNominal
 * @summary clear.
 * @covers UActorComponent.get-component
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetComponentNominal(AActor Actor, UActorComponent ExpectedAny, UActorComponent ExpectedRoot)
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
/** @end */
/**
 * @begin get-or-create-component
 * @summary clear.
 * @topic Unreal
 */
/**
 * @function ObserveGetOrCreateComponentNominal
 * @summary clear.
 * @covers UActorComponent.get-or-create-component
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetOrCreateComponentNominal(AActor Actor)
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
/** @end */
/**
 * @begin get-all-components
 * @summary clear.
 * @topic Unreal
 */
/**
 * @function ObserveGetAllComponentsNominal
 * @summary clear.
 * @covers UActorComponent.get-all-components
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAllComponentsNominal(AActor Actor, UActorComponent Sentinel)
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
/** @end */
/**
 * @begin get
 * @summary clear.
 * @topic Unreal
 */
/**
 * @function ObserveGetNominal
 * @summary clear.
 * @covers UActorComponent.get
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNominal(AActor Actor, USceneComponent ExpectedAny, USceneComponent ExpectedRoot)
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
/** @end */
/**
 * @begin get-or-create
 * @summary clear.
 * @topic Unreal
 */
/**
 * @function ObserveGetOrCreateNominal
 * @summary clear.
 * @covers UActorComponent.get-or-create
 * @inputs UActorComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetOrCreateNominal(AActor Actor)
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
/** @end */
