// Theme: Feature.DefaultComponent. WorldStory scripted root plus attached billboard.
// C++: AngelscriptComponentLifecycleExtendedTests.cpp::ScriptedRootAndAttachedBillboardMaterialize
// Oracle: ScriptedRoot == GetRootComponent(); AttachedBillboard.GetAttachParent() == ScriptedRoot.
// Extra: unset handle is null; two actors keep distinct ScriptedRoot instances.
// FixtureIsolated.

UCLASS()
class UTestCoverageRootComponent : USceneComponent
{
}

UCLASS()
class UTestCoverageBillboardComponent : UBillboardComponent
{
}

UCLASS()
class ATestDefaultComponentCoverageHierarchy : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestCoverageRootComponent ScriptedRoot;

	UPROPERTY(DefaultComponent, Attach = ScriptedRoot)
	UTestCoverageBillboardComponent AttachedBillboard;
}

bool Observe_CoverageHierarchy_EmptyDefaultIsNull()
{
	ATestDefaultComponentCoverageHierarchy Actor;
	return Actor == nullptr;
}

bool Observe_CoverageHierarchy_ScriptedRootIsActorRoot(ATestDefaultComponentCoverageHierarchy Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0185 setup: required ATestDefaultComponentCoverageHierarchy is null");
	}
	return Actor.ScriptedRoot != nullptr && Actor.ScriptedRoot == Actor.GetRootComponent();
}

bool Observe_CoverageHierarchy_BillboardAttached(ATestDefaultComponentCoverageHierarchy Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0185 setup: required ATestDefaultComponentCoverageHierarchy is null");
	}
	return Actor.AttachedBillboard != nullptr
		&& Actor.ScriptedRoot != nullptr
		&& Actor.AttachedBillboard.GetAttachParent() == Actor.ScriptedRoot;
}

bool Observe_CoverageHierarchy_CopyIndependent(
	ATestDefaultComponentCoverageHierarchy First,
	ATestDefaultComponentCoverageHierarchy Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0185 setup: required ATestDefaultComponentCoverageHierarchy pair is null");
	}
	return First.ScriptedRoot != nullptr
		&& Second.ScriptedRoot != nullptr
		&& First.ScriptedRoot != Second.ScriptedRoot;
}
