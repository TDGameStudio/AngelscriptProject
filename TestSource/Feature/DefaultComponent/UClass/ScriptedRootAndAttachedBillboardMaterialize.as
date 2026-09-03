/**
 * A scripted root plus an attached billboard. C++ checks ScriptedRoot ==
 * GetRootComponent() and AttachedBillboard.GetAttachParent() == ScriptedRoot.
 * The observers cover the local construct default, those instance links, and
 * copy independence.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.ScriptedRootAndAttachedBillboardMaterialize
 * @Harness UClass
 * @Tag Feature.DefaultComponent.ScriptedRootAndAttachedBillboardMaterialize
 * @Provenance Theme: Feature.DefaultComponent. WorldStory scripted root plus attached billboard.
 * @Provenance C++: AngelscriptComponentLifecycleExtendedTests.cpp::ScriptedRootAndAttachedBillboardMaterialize
 * @Provenance Oracle: ScriptedRoot == GetRootComponent(); AttachedBillboard.GetAttachParent() == ScriptedRoot.
 * @Provenance Extra: unset handle is null; two actors keep distinct ScriptedRoot instances.
 * @Provenance FixtureIsolated.
 */

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

	/**
	 * Observe that a locally constructed actor has neither scripted component.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.ScriptedRootAndAttachedBillboardMaterialize
	 * @Inputs an actor that has not been spawned
	 * @Return true when ScriptedRoot and AttachedBillboard are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ScriptedRoot != nullptr)
		{
			return false;
		}
		return AttachedBillboard == nullptr;
	}

	/**
	 * Observe that ScriptedRoot is the actor's root component.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.ScriptedRootAndAttachedBillboardMaterialize
	 * @Inputs a spawned actor whose ScriptedRoot has materialized
	 * @Return true when ScriptedRoot is non-null and equals GetRootComponent()
	 */
	UFUNCTION()
	bool ScriptedRootIsActorRoot()
	{
		if (ScriptedRoot == nullptr)
		{
			return false;
		}
		return ScriptedRoot == GetRootComponent();
	}

	/**
	 * Observe that AttachedBillboard is attached to ScriptedRoot.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.ScriptedRootAndAttachedBillboardMaterialize
	 * @Inputs a spawned actor whose billboard has materialized
	 * @Return true when AttachedBillboard's attach parent is ScriptedRoot
	 */
	UFUNCTION()
	bool BillboardAttached()
	{
		if (AttachedBillboard == nullptr)
		{
			return false;
		}
		if (ScriptedRoot == nullptr)
		{
			return false;
		}
		return AttachedBillboard.GetAttachParent() == ScriptedRoot;
	}

	/**
	 * Observe that a second instance keeps its own distinct ScriptedRoot.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.ScriptedRootAndAttachedBillboardMaterialize
	 * @Inputs this actor plus a second spawned actor
	 * @Return true when both ScriptedRoots are non-null and not the same instance
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestDefaultComponentCoverageHierarchy Second)
	{
		if (Second is null)
		{
			throw("ScriptedRootAndAttachedBillboardMaterialize setup: required Second is null");
		}
		if (ScriptedRoot == nullptr)
		{
			return false;
		}
		if (Second.ScriptedRoot == nullptr)
		{
			return false;
		}
		return ScriptedRoot != Second.ScriptedRoot;
	}
}
