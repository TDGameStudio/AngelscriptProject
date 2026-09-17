/**
 * @version v1
 * @summary OverrideComponent against ACharacter native components. C++ reads NativeOverridePropertiesAssigned and NativeOverrideTypesMaterialized after BeginPlay. The observers cover the CDO flags, the null-replacement boundary and.
 * @topic Feature
 */
/**
 * @version root
 * @summary OverrideComponent against ACharacter native components. C++ reads NativeOverridePropertiesAssigned and NativeOverrideTypesMaterialized after BeginPlay. The observers cover the CDO flags, the null-replacement boundary and.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: BeginPlay records whether the native capsule and mesh overrides
	 * materialized on this character.
	 *
	 * @Kind WorldStory
	 * @Covers Attach.UClassNativeParentOverrideComponentMatrix
	 * @Inputs ReplacementCapsule and ReplacementMesh override properties
	 * @Return NativeOverridePropertiesAssigned and NativeOverrideTypesMaterialized true after spawn
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		NativeOverridePropertiesAssigned =
			ReplacementCapsule != nullptr &&
			ReplacementMesh != nullptr;
		NativeOverrideTypesMaterialized =
			NativeOverridePropertiesAssigned;
	}

	/**
	 * Observe that a locally constructed character still holds the CDO flags.
	 *
	 * @Kind Observe
	 * @Covers Attach.UClassNativeParentOverrideComponentMatrix
	 * @Inputs a character that has not run BeginPlay
	 * @Return true when both flags are false
	 * @Boundary CDO defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (NativeOverridePropertiesAssigned)
		{
			return false;
		}
		return NativeOverrideTypesMaterialized == false;
	}

	/**
	 * Observe that a locally constructed character has not materialized the replacements.
	 *
	 * @Kind Observe
	 * @Covers Attach.UClassNativeParentOverrideComponentMatrix
	 * @Inputs a character that has not been spawned
	 * @Return true when ReplacementCapsule and ReplacementMesh are both null
	 * @Boundary null override components
	 */
	UFUNCTION()
	bool NullBoundary()
	{
		if (ReplacementCapsule != nullptr)
		{
			return false;
		}
		return ReplacementMesh == nullptr;
	}

	/**
	 * Observe that writing the second character leaves this character at its CDO flags.
	 *
	 * @Kind Observe
	 * @Covers Attach.UClassNativeParentOverrideComponentMatrix
	 * @Inputs this character plus a second character
	 * @Return true when this stays at CDO flags and Second holds the written flags
	 * @Param Second the other character, written then compared
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageUClassNativeOverrideCharacter Second)
	{
		if (Second is null)
		{
			throw("UClassNativeParentOverrideComponentMatrix setup: required Second is null");
		}
		Second.NativeOverridePropertiesAssigned = true;
		Second.NativeOverrideTypesMaterialized = true;
		if (NativeOverridePropertiesAssigned)
		{
			return false;
		}
		if (NativeOverrideTypesMaterialized)
		{
			return false;
		}
		if (!Second.NativeOverridePropertiesAssigned)
		{
			return false;
		}
		return Second.NativeOverrideTypesMaterialized;
	}
}
/** @end */
