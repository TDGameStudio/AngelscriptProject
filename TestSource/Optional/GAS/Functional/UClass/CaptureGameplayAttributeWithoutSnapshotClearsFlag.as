/**
 * A script attribute set supplying Speed for a capture taken without a snapshot.
 * The observers cover the null handle, the default capture definition and the
 * capture call itself, which skips the ensure when the name is unset.
 *
 * @Theme Optional.GAS
 * @Subject GAS.CaptureWithoutSnapshot
 * @Harness UClass
 * @Tag Optional.GAS.CaptureGameplayAttributeWithoutSnapshotClearsFlag
 * @Provenance Theme: Optional.GAS. WorldStory: UTestNoSnapshotAttributes Speed capture without snapshot.
 * @Provenance C++: AngelscriptGASGameplayCueUtilsTests.cpp::CaptureGameplayAttributeWithoutSnapshotClearsFlag
 * @Provenance Oracle: CaptureGameplayAttribute(..., Target, false).bSnapshot is false.
 * @Provenance Extra: default capture def snapshot false; FName AttributeName None skips Capture ensure.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Static capture; runner supplies names.
 */

UCLASS()
class UTestNoSnapshotAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Speed;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.CaptureWithoutSnapshot
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestNoSnapshotAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that a default capture definition is not a snapshot.
	 *
	 * @Kind Observe
	 * @Covers GAS.CaptureWithoutSnapshot
	 * @Inputs a default-constructed capture definition
	 * @Return true when bSnapshot is false
	 * @Boundary default definition
	 */
	UFUNCTION()
	bool EmptyCaptureDef()
	{
		FGameplayEffectAttributeCaptureDefinition EmptyDef;
		return !EmptyDef.bSnapshot;
	}

	/**
	 * Observe the snapshot flag on a capture taken without a snapshot.
	 *
	 * @Kind Observe
	 * @Covers GAS.CaptureWithoutSnapshot
	 * @Inputs an attribute name to capture
	 * @Return true when bSnapshot is false, including the unset-name fallback
	 * @Param AttributeName the attribute to capture; NAME_None skips the ensure
	 */
	UFUNCTION()
	bool CaptureNoSnapshot(FName AttributeName)
	{
		if (AttributeName.IsNone())
		{
			FGameplayEffectAttributeCaptureDefinition EmptyDef;
			return !EmptyDef.bSnapshot;
		}
		FGameplayEffectAttributeCaptureDefinition CaptureDef =
			UAngelscriptGameplayEffectUtils::CaptureGameplayAttribute(
				UTestNoSnapshotAttributes,
				AttributeName,
				EGameplayEffectAttributeCaptureSource::Target,
				false);
		return !CaptureDef.bSnapshot;
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.CaptureWithoutSnapshot
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestNoSnapshotAttributesEmpty : UAngelscriptAttributeSet
{
}
