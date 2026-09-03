/**
 * Root, child and later default components plus one runtime-created component,
 * each recording the position at which its BeginPlay ran. C++ captures the
 * default orders and creates the runtime probe, then compares the recorded
 * positions.
 *
 * @Theme World.Component
 * @Subject Component.LifecycleOrdering
 * @Harness UClass
 * @Tag World.Component.ComponentActorMultiAndDynamicLifecycleOrdering
 * @Provenance Theme: World.Component. WorldStory: root/child/later default plus runtime dynamic component BeginPlay order.
 * @Provenance C++: AngelscriptCoverageComponentTests.cpp::ComponentActorMultiAndDynamicLifecycleOrdering
 * @Provenance Oracle: CaptureDefaultOrders copies Root/Child/Later BeginPlayOrder; ActorBeginPlayOrder > 0;
 * @Provenance CreateRuntimeProbe sets DynamicCreated and DynamicBeginPlayOrder.
 * @Provenance Extra: orders 0, DynamicCreated false, DynamicProbe null until capture/create.
 * @Provenance Do not spawn from script. FixtureIsolated.
 */

/**
 * The root scene component, which records its BeginPlay position in the owner tag
 * order.
 *
 * @Covers Component.LifecycleOrdering
 * @Inputs none
 * @Return a scene component tagging "RootBeginPlay" on its owner
 */
UCLASS()
class UCoverageRootLifecycleComponent : USceneComponent
{
	UPROPERTY()
	int BeginPlayOrder = 0;

	/**
	 * WorldStory: tag the owner and record the position this BeginPlay took.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs the owning actor
	 * @Return BeginPlayOrder set to the owner tag count after appending
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AActor Owner = GetOwner();
		if (Owner != nullptr)
		{
			Owner.Tags.Add(n"RootBeginPlay");
			BeginPlayOrder = Owner.Tags.Num();
		}
	}
}

/**
 * The child scene component, attached under the root.
 *
 * @Covers Component.LifecycleOrdering
 * @Inputs none
 * @Return a scene component tagging "ChildBeginPlay" on its owner
 */
UCLASS()
class UCoverageChildLifecycleComponent : USceneComponent
{
	UPROPERTY()
	int BeginPlayOrder = 0;

	/**
	 * WorldStory: tag the owner and record the position this BeginPlay took.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs the owning actor
	 * @Return BeginPlayOrder set to the owner tag count after appending
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AActor Owner = GetOwner();
		if (Owner != nullptr)
		{
			Owner.Tags.Add(n"ChildBeginPlay");
			BeginPlayOrder = Owner.Tags.Num();
		}
	}
}

/**
 * A non-scene default component declared after the scene components.
 *
 * @Covers Component.LifecycleOrdering
 * @Inputs none
 * @Return an actor component tagging "LaterBeginPlay" on its owner
 */
UCLASS()
class UCoverageLaterLifecycleComponent : UActorComponent
{
	UPROPERTY()
	int BeginPlayOrder = 0;

	/**
	 * WorldStory: tag the owner and record the position this BeginPlay took.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs the owning actor
	 * @Return BeginPlayOrder set to the owner tag count after appending
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AActor Owner = GetOwner();
		if (Owner != nullptr)
		{
			Owner.Tags.Add(n"LaterBeginPlay");
			BeginPlayOrder = Owner.Tags.Num();
		}
	}
}

/**
 * The component created at runtime rather than declared as a default component.
 *
 * @Covers Component.LifecycleOrdering
 * @Inputs none
 * @Return an actor component tagging "DynamicBeginPlay" on its owner
 */
UCLASS()
class UCoverageDynamicLifecycleComponent : UActorComponent
{
	UPROPERTY()
	int BeginPlayOrder = 0;

	/**
	 * WorldStory: tag the owner and record the position this BeginPlay took.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs the owning actor
	 * @Return BeginPlayOrder set to the owner tag count after appending
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AActor Owner = GetOwner();
		if (Owner != nullptr)
		{
			Owner.Tags.Add(n"DynamicBeginPlay");
			BeginPlayOrder = Owner.Tags.Num();
		}
	}
}

UCLASS()
class ACoverageComponentMultiDynamicLifecycleActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCoverageRootLifecycleComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCoverageChildLifecycleComponent ChildProbe;

	UPROPERTY(DefaultComponent)
	UCoverageLaterLifecycleComponent LaterProbe;

	UPROPERTY()
	UCoverageDynamicLifecycleComponent DynamicProbe;

	UPROPERTY()
	int ActorBeginPlayOrder = 0;

	UPROPERTY()
	int RootBeginPlayOrder = 0;

	UPROPERTY()
	int ChildBeginPlayOrder = 0;

	UPROPERTY()
	int LaterBeginPlayOrder = 0;

	UPROPERTY()
	int DynamicBeginPlayOrder = 0;

	UPROPERTY()
	bool DynamicCreated = false;

	/**
	 * WorldStory: the actor tags itself last and records its own position.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs none
	 * @Return ActorBeginPlayOrder greater than 0
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Tags.Add(n"ActorBeginPlay");
		ActorBeginPlayOrder = Tags.Num();
	}

	/**
	 * Create the runtime probe component and record the BeginPlay position it took.
	 *
	 * @Kind Action
	 * @Covers Component.LifecycleOrdering
	 * @Inputs none
	 * @Return DynamicCreated set and DynamicBeginPlayOrder copied off the new probe
	 */
	UFUNCTION()
	void CreateRuntimeProbe()
	{
		DynamicProbe = UCoverageDynamicLifecycleComponent::Create(this, n"DynamicProbe");
		if (DynamicProbe == nullptr)
		{
			return;
		}

		DynamicCreated = true;
		DynamicBeginPlayOrder = DynamicProbe.BeginPlayOrder;
	}

	/**
	 * Copy the BeginPlay positions recorded by the three default components.
	 *
	 * @Kind Action
	 * @Covers Component.LifecycleOrdering
	 * @Inputs none
	 * @Return Root/Child/LaterBeginPlayOrder copied off their components
	 */
	UFUNCTION()
	void CaptureDefaultOrders()
	{
		RootBeginPlayOrder = Root.BeginPlayOrder;
		ChildBeginPlayOrder = ChildProbe.BeginPlayOrder;
		LaterBeginPlayOrder = LaterProbe.BeginPlayOrder;
	}
}
