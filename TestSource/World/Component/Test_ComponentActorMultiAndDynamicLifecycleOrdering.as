// Theme: World.Component. WorldStory: root/child/later default plus runtime dynamic component BeginPlay order.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentActorMultiAndDynamicLifecycleOrdering
// Oracle: CaptureDefaultOrders copies Root/Child/Later BeginPlayOrder; ActorBeginPlayOrder > 0;
// CreateRuntimeProbe sets DynamicCreated and DynamicBeginPlayOrder.
// Extra: orders 0, DynamicCreated false, DynamicProbe null until capture/create.
// Do not spawn from script. FixtureIsolated.

UCLASS()
class UCoverageRootLifecycleComponent : USceneComponent
{
	UPROPERTY()
	int BeginPlayOrder = 0;

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

UCLASS()
class UCoverageChildLifecycleComponent : USceneComponent
{
	UPROPERTY()
	int BeginPlayOrder = 0;

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

UCLASS()
class UCoverageLaterLifecycleComponent : UActorComponent
{
	UPROPERTY()
	int BeginPlayOrder = 0;

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

UCLASS()
class UCoverageDynamicLifecycleComponent : UActorComponent
{
	UPROPERTY()
	int BeginPlayOrder = 0;

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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Tags.Add(n"ActorBeginPlay");
		ActorBeginPlayOrder = Tags.Num();
	}

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

	UFUNCTION()
	void CaptureDefaultOrders()
	{
		RootBeginPlayOrder = Root.BeginPlayOrder;
		ChildBeginPlayOrder = ChildProbe.BeginPlayOrder;
		LaterBeginPlayOrder = LaterProbe.BeginPlayOrder;
	}
}
