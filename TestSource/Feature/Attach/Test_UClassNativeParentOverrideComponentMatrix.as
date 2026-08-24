// Theme: Feature.Attach. WorldStory: OverrideComponent against ACharacter native components.
// C++: AngelscriptCoverageUClassTests.cpp::UClassNativeParentOverrideComponentMatrix.
// Oracle after BeginPlay: NativeOverridePropertiesAssigned true; NativeOverrideTypesMaterialized true.
// Extra: CDO bools false; copy independence.
// FixtureIsolated. Keep NativeOverridePropertiesAssigned and NativeOverrideTypesMaterialized.

UCLASS()
class UCoverageUClassOverrideCapsuleComponent : UCapsuleComponent
{
}

UCLASS()
class UCoverageUClassOverrideMeshComponent : USkeletalMeshComponent
{
}

UCLASS()
class ACoverageUClassNativeOverrideCharacter : ACharacter
{
	UPROPERTY(OverrideComponent=CollisionCylinder)
	UCoverageUClassOverrideCapsuleComponent ReplacementCapsule;

	UPROPERTY(OverrideComponent=CharacterMesh0)
	UCoverageUClassOverrideMeshComponent ReplacementMesh;

	UPROPERTY()
	bool NativeOverridePropertiesAssigned = false;

	UPROPERTY()
	bool NativeOverrideTypesMaterialized = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		NativeOverridePropertiesAssigned =
			ReplacementCapsule != nullptr &&
			ReplacementMesh != nullptr;
		NativeOverrideTypesMaterialized =
			NativeOverridePropertiesAssigned;
	}
}

bool Observe_NativeOverride_CDODefaults(ACoverageUClassNativeOverrideCharacter Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassNativeParentOverrideComponentMatrix setup: required Actor is null");
	}
	return Actor.NativeOverridePropertiesAssigned == false
		&& Actor.NativeOverrideTypesMaterialized == false;
}

bool Observe_NativeOverride_NullBoundary(ACoverageUClassNativeOverrideCharacter Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassNativeParentOverrideComponentMatrix setup: required Actor is null");
	}
	return Actor.ReplacementCapsule == nullptr && Actor.ReplacementMesh == nullptr;
}

bool Observe_NativeOverride_CopyIndependence(ACoverageUClassNativeOverrideCharacter Original, ACoverageUClassNativeOverrideCharacter Copy)
{
	if (Original is null)
	{
		throw("Test_UClassNativeParentOverrideComponentMatrix setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_UClassNativeParentOverrideComponentMatrix setup: required Copy is null");
	}
	Copy.NativeOverridePropertiesAssigned = true;
	Copy.NativeOverrideTypesMaterialized = true;
	return Original.NativeOverridePropertiesAssigned == false
		&& Original.NativeOverrideTypesMaterialized == false
		&& Copy.NativeOverridePropertiesAssigned
		&& Copy.NativeOverrideTypesMaterialized;
}
