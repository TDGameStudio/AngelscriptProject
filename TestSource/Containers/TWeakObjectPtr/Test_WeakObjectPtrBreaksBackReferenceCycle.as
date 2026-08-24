// Theme: Containers.TWeakObjectPtr. WorldStory: strong child, weak parent back-reference.
// C++: AngelscriptCoverageWeakReferenceTests.cpp::WeakObjectPtrBreaksBackReferenceCycle
// CompileScriptModule + spawn + BeginPlay. Oracle: StrongForwardReferenceAlive and
// WeakBackReferenceDoesNotOwn true after CoverageGC::ForceGarbageCollectionNow.
// Extra: local construct leaves StrongChild/WeakParent null and flags false.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageWeakRefCycleChild : AActor
{
	UPROPERTY()
	TWeakObjectPtr<AActor> WeakParent;

	UFUNCTION()
	void SetParent(AActor Parent)
	{
		WeakParent = Parent;
	}

	UFUNCTION()
	bool HasWeakParent(AActor ExpectedParent)
	{
		return WeakParent.IsValid() && WeakParent.Get() == ExpectedParent;
	}
}

UCLASS()
class ACoverageWeakRefBreakCycleActor : AActor
{
	UPROPERTY()
	ACoverageWeakRefCycleChild StrongChild;

	UPROPERTY()
	TWeakObjectPtr<AActor> WeakParent;

	UPROPERTY()
	bool StrongForwardReferenceAlive = false;

	UPROPERTY()
	bool WeakBackReferenceDoesNotOwn = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StrongChild = Cast<ACoverageWeakRefCycleChild>(SpawnActor(ACoverageWeakRefCycleChild::StaticClass()));
		WeakParent = this;
		StrongChild.SetParent(this);

		TWeakObjectPtr<AActor> WeakChild = StrongChild;
		CoverageGC::ForceGarbageCollectionNow();

		StrongForwardReferenceAlive = WeakChild.IsValid() && IsValid(StrongChild);
		WeakBackReferenceDoesNotOwn = WeakParent.IsValid() && WeakParent.Get() == this && StrongChild.HasWeakParent(this);
	}
}

bool Observe_WeakBreakCycle_DefaultEmpty(ACoverageWeakRefBreakCycleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_WeakObjectPtrBreaksBackReferenceCycle setup: required Actor is null");
	}
	return Actor.StrongChild == nullptr
		&& Actor.WeakParent == nullptr
		&& Actor.WeakParent.Get() == nullptr
		&& Actor.StrongForwardReferenceAlive == false
		&& Actor.WeakBackReferenceDoesNotOwn == false;
}

bool Observe_WeakBreakCycle_ChildNullBoundary(ACoverageWeakRefCycleChild Child)
{
	if (Child is null)
	{
		throw("Test_WeakObjectPtrBreaksBackReferenceCycle setup: required Child is null");
	}
	Child.SetParent(nullptr);
	return Child.HasWeakParent(nullptr) == false;
}

bool Observe_WeakBreakCycle_CopyIndependence(ACoverageWeakRefBreakCycleActor First, ACoverageWeakRefBreakCycleActor Second)
{
	if (First is null)
	{
		throw("Test_WeakObjectPtrBreaksBackReferenceCycle setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_WeakObjectPtrBreaksBackReferenceCycle setup: required Second is null");
	}
	First.StrongForwardReferenceAlive = true;
	return First.StrongForwardReferenceAlive == true
		&& Second.StrongForwardReferenceAlive == false
		&& Second.StrongChild == nullptr
		&& Second.WeakBackReferenceDoesNotOwn == false;
}
