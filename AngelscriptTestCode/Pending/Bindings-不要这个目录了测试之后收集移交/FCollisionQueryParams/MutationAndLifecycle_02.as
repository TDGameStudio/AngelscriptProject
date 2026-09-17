/**
 * @version v1
 * @summary Observe FComponentQueryParams ignore-list mutations, including actor/component array overloads and the duplicate-root helper.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FComponentQueryParams ignore-list mutations, including actor/component array overloads and the duplicate-root helper.
 * @topic Baseline
 */
// Runner owns Actor and IgnoreComponent. Null required fixtures are setup
// failure. The bool return is the runner-readable oracle.
// AS-facing API: void FComponentQueryParams.ClearIgnoredComponents();
// void FComponentQueryParams.ClearIgnoredActors();
// void FComponentQueryParams.SetNumIgnoredComponents(int32 NewNum);
// void FComponentQueryParams.AddIgnoredActor(const AActor InIgnoreActor);
// void FComponentQueryParams.AddIgnoredActor(const uint32 InIgnoreActorID);
// void FComponentQueryParams.AddIgnoredActors(const TArray<AActor>& InIgnoreActors);
// void FComponentQueryParams.AddIgnoredActors(const TArray<const AActor>& InIgnoreActors);
// void FComponentQueryParams.AddIgnoredComponent(const UPrimitiveComponent InIgnoreComponent);
// void FComponentQueryParams.AddIgnoredComponents(const TArray<UPrimitiveComponent>& InIgnoreComponents);
// void FComponentQueryParams.AddIgnoredComponent_LikelyDuplicatedRoot(const UPrimitiveComponent InIgnoreComponent);
// Inputs: Runner-owned AActor, runner-owned UPrimitiveComponent, uint32 42,
// null handles, NewNum 0 and 1, and arrays containing those handles.
// Expected observations: Clear drops Num to 0. SetNumIgnoredComponents(0)
// empties components. Valid actor/component handles increase Num. Null
// handles are ignored. uint32 42 is stored. Duplicate-root uses the engine
// duplicate-aware path.
// Boundary/ownership: Ignore lists store unique IDs, not object ownership.
// SetupOwner=Runner. CleanupOwner=Runner. FixtureIsolated.

namespace TS_FCollisionQueryParams_MutationAndLifecycle_02
{
	bool Observe_ClearIgnoredComponents_Nominal(UPrimitiveComponent IgnoreComponent)
	{
		if (IgnoreComponent is null)
		{
			throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required IgnoreComponent is null");
		}
		FComponentQueryParams Params;
		Params.AddIgnoredComponent(IgnoreComponent);
		Params.ClearIgnoredComponents();
		TArray<uint32> After = Params.GetIgnoredComponents();
		return After.Num() == 0;
	}

	bool Observe_ClearIgnoredActors_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required Actor is null");
		}
		FComponentQueryParams Params;
		Params.AddIgnoredActor(Actor);
		Params.ClearIgnoredActors();
		TArray<uint32> After = Params.GetIgnoredActors();
		return After.Num() == 0;
	}

	bool Observe_SetNumIgnoredComponents_Nominal(UPrimitiveComponent IgnoreComponent)
	{
		if (IgnoreComponent is null)
		{
			throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required IgnoreComponent is null");
		}
		FComponentQueryParams Params;
		Params.AddIgnoredComponent(IgnoreComponent);
		Params.SetNumIgnoredComponents(1);
		int32 One = Params.GetIgnoredComponents().Num();
		Params.SetNumIgnoredComponents(0);
		int32 Zero = Params.GetIgnoredComponents().Num();
		return One == 1 && Zero == 0;
	}

	bool Observe_AddIgnoredActor_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required Actor is null");
		}
		FComponentQueryParams Params;
		AActor NullActor;
		Params.AddIgnoredActor(NullActor);
		int32 AfterNull = Params.GetIgnoredActors().Num();
		Params.AddIgnoredActor(Actor);
		int32 AfterActor = Params.GetIgnoredActors().Num();
		uint32 ActorId = 42;
		Params.AddIgnoredActor(ActorId);
		TArray<uint32> Ids = Params.GetIgnoredActors();
		bool bIdStored = false;
		for (int32 Index = 0; Index < Ids.Num(); ++Index)
		{
			if (Ids[Index] == 42)
			{
				bIdStored = true;
			}
		}
		return AfterNull == 0 && AfterActor == 1 && bIdStored;
	}

	bool Observe_AddIgnoredActors_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required Actor is null");
		}
		FComponentQueryParams Params;
		TArray<AActor> Actors;
		Actors.Add(Actor);
		AActor NullActor;
		Actors.Add(NullActor);
		Params.AddIgnoredActors(Actors);
		int32 AfterActors = Params.GetIgnoredActors().Num();

		TArray<const AActor> ConstActors;
		ConstActors.Add(Actor);
		Params.AddIgnoredActors(ConstActors);
		int32 AfterConst = Params.GetIgnoredActors().Num();
		return AfterActors == 1 && AfterConst >= AfterActors;
	}

	bool Observe_AddIgnoredComponent_Nominal(UPrimitiveComponent IgnoreComponent)
	{
		if (IgnoreComponent is null)
		{
			throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required IgnoreComponent is null");
		}
		FComponentQueryParams Params;
		UPrimitiveComponent NullComponent;
		Params.AddIgnoredComponent(NullComponent);
		int32 AfterNull = Params.GetIgnoredComponents().Num();
		Params.AddIgnoredComponent(IgnoreComponent);
		int32 AfterComponent = Params.GetIgnoredComponents().Num();
		return AfterNull == 0 && AfterComponent == 1;
	}

	bool Observe_AddIgnoredComponents_Nominal(UPrimitiveComponent IgnoreComponent)
	{
		if (IgnoreComponent is null)
		{
			throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required IgnoreComponent is null");
		}
		FComponentQueryParams Params;
		TArray<UPrimitiveComponent> Components;
		Components.Add(IgnoreComponent);
		UPrimitiveComponent NullComponent;
		Components.Add(NullComponent);
		Params.AddIgnoredComponents(Components);
		int32 After = Params.GetIgnoredComponents().Num();
		return After == 1;
	}

	bool Observe_AddIgnoredComponent_LikelyDuplicatedRoot_Nominal(UPrimitiveComponent IgnoreComponent)
	{
		if (IgnoreComponent is null)
		{
			throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required IgnoreComponent is null");
		}
		FComponentQueryParams Params;
		UPrimitiveComponent NullComponent;
		Params.AddIgnoredComponent_LikelyDuplicatedRoot(NullComponent);
		int32 AfterNull = Params.GetIgnoredComponents().Num();
		Params.AddIgnoredComponent_LikelyDuplicatedRoot(IgnoreComponent);
		int32 AfterRoot = Params.GetIgnoredComponents().Num();
		Params.AddIgnoredComponent_LikelyDuplicatedRoot(IgnoreComponent);
		int32 AfterDuplicate = Params.GetIgnoredComponents().Num();
		return AfterNull == 0 && AfterRoot == 1 && AfterDuplicate >= AfterRoot;
	}
}
/** @end */
