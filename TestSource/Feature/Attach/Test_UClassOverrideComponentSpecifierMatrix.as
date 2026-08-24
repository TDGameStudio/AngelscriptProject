// Theme: Feature.Attach. WorldStory: OverrideComponent on a script parent plus a child default.
// C++: AngelscriptCoverageUClassTests.cpp::UClassOverrideComponentSpecifierMatrix.
// Oracle after BeginPlay: ReplacementPropertiesAssigned true; ReplacementAttachmentPreserved true;
// ReplacementLogicAssigned true; ChildDefaultAttachedToInheritedRoot true (Camera script property remains null).
// Extra: CDO bools false; Camera default null.
// FixtureIsolated. Keep the C++ UPROPERTY names.

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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (ReplacementScene == nullptr ||
			ReplacementLogic == nullptr ||
			Root == nullptr)
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
}

bool Observe_OverrideSpecifier_CDODefaults(ACoverageUClassOverrideChildActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassOverrideComponentSpecifierMatrix setup: required Actor is null");
	}
	return Actor.ReplacementPropertiesAssigned == false
		&& Actor.ReplacementAttachmentPreserved == false
		&& Actor.ReplacementLogicAssigned == false
		&& Actor.ChildDefaultAttachedToInheritedRoot == false;
}

bool Observe_OverrideSpecifier_CameraNullBoundary(ACoverageUClassOverrideChildActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassOverrideComponentSpecifierMatrix setup: required Actor is null");
	}
	return Actor.Camera == nullptr;
}

bool Observe_OverrideSpecifier_CopyIndependence(ACoverageUClassOverrideChildActor Original, ACoverageUClassOverrideChildActor Copy)
{
	if (Original is null)
	{
		throw("Test_UClassOverrideComponentSpecifierMatrix setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_UClassOverrideComponentSpecifierMatrix setup: required Copy is null");
	}
	Copy.ReplacementPropertiesAssigned = true;
	Copy.ChildDefaultAttachedToInheritedRoot = true;
	return Original.ReplacementPropertiesAssigned == false
		&& Original.ChildDefaultAttachedToInheritedRoot == false
		&& Copy.ReplacementPropertiesAssigned
		&& Copy.ChildDefaultAttachedToInheritedRoot;
}
