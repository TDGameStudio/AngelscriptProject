/**
 * OverrideComponent on a script parent plus a child default. C++ reads the
 * replacement and child-default flags after BeginPlay. The observers cover the
 * CDO flags, the null Camera boundary and copy independence.
 *
 * @Theme Feature.Attach
 * @Subject Attach.UClassOverrideComponentSpecifierMatrix
 * @Harness UClass
 * @Tag Feature.Attach.UClassOverrideComponentSpecifierMatrix
 * @Provenance Theme: Feature.Attach. WorldStory: OverrideComponent on a script parent plus a child default.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassOverrideComponentSpecifierMatrix.
 * @Provenance Oracle after BeginPlay: ReplacementPropertiesAssigned true; ReplacementAttachmentPreserved true;
 * @Provenance ReplacementLogicAssigned true; ChildDefaultAttachedToInheritedRoot true (Camera script property remains null).
 * @Provenance Extra: CDO bools false; Camera default null.
 * @Provenance FixtureIsolated. Keep the C++ UPROPERTY names.
 */

UCLASS()
class UCoverageUClassOverrideRootComponent : USceneComponent
{
}

UCLASS()
class UCoverageUClassOverrideBaseSceneComponent : USceneComponent
{
}

UCLASS()
class UCoverageUClassOverrideDerivedSceneComponent : UCoverageUClassOverrideBaseSceneComponent
{
}

UCLASS()
class UCoverageUClassOverrideBaseLogicComponent : UActorComponent
{
}

UCLASS()
class UCoverageUClassOverrideDerivedLogicComponent : UCoverageUClassOverrideBaseLogicComponent
{
}

UCLASS()
class ACoverageUClassOverrideBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCoverageUClassOverrideRootComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root, AttachSocket="BaseSocket")
	UCoverageUClassOverrideBaseSceneComponent BaseScene;

	UPROPERTY(DefaultComponent)
	UCoverageUClassOverrideBaseLogicComponent BaseLogic;
}

UCLASS()
class ACoverageUClassOverrideChildActor : ACoverageUClassOverrideBaseActor
{
	UPROPERTY(OverrideComponent=BaseScene)
	UCoverageUClassOverrideDerivedSceneComponent ReplacementScene;

	UPROPERTY(OverrideComponent=BaseLogic)
	UCoverageUClassOverrideDerivedLogicComponent ReplacementLogic;

	UPROPERTY(DefaultComponent)
	UCameraComponent Camera;

	UPROPERTY()
	bool ReplacementPropertiesAssigned = false;

	UPROPERTY()
	bool ReplacementAttachmentPreserved = false;

	UPROPERTY()
	bool ReplacementLogicAssigned = false;

	UPROPERTY()
	bool ChildDefaultAttachedToInheritedRoot = false;

	/**
	 * WorldStory: BeginPlay records whether the override properties assigned, the
	 * BaseSocket attachment survived, the logic override owns this actor, and the
	 * Camera script property remains null.
	 *
	 * @Kind WorldStory
	 * @Covers Attach.UClassOverrideComponentSpecifierMatrix
	 * @Inputs ReplacementScene, ReplacementLogic, Root and Camera
	 * @Return all four flags true after spawn when Camera stays null
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (ReplacementScene == nullptr)
		{
			return;
		}
		if (ReplacementLogic == nullptr)
		{
			return;
		}
		if (Root == nullptr)
		{
			return;
		}

		ReplacementPropertiesAssigned =
			true;
		ReplacementAttachmentPreserved =
			ReplacementScene.GetAttachParent() == Root &&
			ReplacementScene.GetAttachSocketName() == n"BaseSocket";
		ReplacementLogicAssigned =
			ReplacementLogic.GetOwner() == this;
		ChildDefaultAttachedToInheritedRoot =
			Camera == nullptr;
	}

	/**
	 * Observe that a locally constructed child still holds the CDO flags.
	 *
	 * @Kind Observe
	 * @Covers Attach.UClassOverrideComponentSpecifierMatrix
	 * @Inputs a child actor that has not run BeginPlay
	 * @Return true when all four flags are false
	 * @Boundary CDO defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ReplacementPropertiesAssigned)
		{
			return false;
		}
		if (ReplacementAttachmentPreserved)
		{
			return false;
		}
		if (ReplacementLogicAssigned)
		{
			return false;
		}
		return ChildDefaultAttachedToInheritedRoot == false;
	}

	/**
	 * Observe that a locally constructed child has not materialized Camera.
	 *
	 * @Kind Observe
	 * @Covers Attach.UClassOverrideComponentSpecifierMatrix
	 * @Inputs a child actor that has not been spawned
	 * @Return true when Camera is null
	 * @Boundary null Camera default
	 */
	UFUNCTION()
	bool CameraNullBoundary()
	{
		return Camera == nullptr;
	}

	/**
	 * Observe that writing the second child leaves this child at its CDO flags.
	 *
	 * @Kind Observe
	 * @Covers Attach.UClassOverrideComponentSpecifierMatrix
	 * @Inputs this child plus a second child
	 * @Return true when this stays at CDO flags and Second holds the written flags
	 * @Param Second the other child, written then compared
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageUClassOverrideChildActor Second)
	{
		if (Second is null)
		{
			throw("UClassOverrideComponentSpecifierMatrix setup: required Second is null");
		}
		Second.ReplacementPropertiesAssigned = true;
		Second.ChildDefaultAttachedToInheritedRoot = true;
		if (ReplacementPropertiesAssigned)
		{
			return false;
		}
		if (ChildDefaultAttachedToInheritedRoot)
		{
			return false;
		}
		if (!Second.ReplacementPropertiesAssigned)
		{
			return false;
		}
		return Second.ChildDefaultAttachedToInheritedRoot;
	}
}
