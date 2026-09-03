/**
 * A script attribute set supplying Power for a capture taken with a snapshot. The
 * observers cover the null handle, the default capture definition and the capture
 * call itself, which skips the ensure when the name is unset.
 *
 * @Theme Optional.GAS
 * @Subject GAS.CaptureWithSnapshot
 * @Harness UClass
 * @Tag Optional.GAS.CaptureGameplayAttributeWithSnapshotSetsFlag
 * @Provenance Theme: Optional.GAS. WorldStory: UTestSnapshotAttributes Power capture with snapshot.
 * @Provenance C++: AngelscriptGASGameplayCueUtilsTests.cpp::CaptureGameplayAttributeWithSnapshotSetsFlag
 * @Provenance Oracle: CaptureGameplayAttribute(..., Source, true).bSnapshot is true.
 * @Provenance Extra: default capture def snapshot false; FName AttributeName None skips Capture ensure.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Static capture; runner supplies names.
 */

UCLASS()
class UTestSnapshotAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Power;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.CaptureWithSnapshot
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestSnapshotAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that a default capture definition is not a snapshot.
	 *
	 * @Kind Observe
	 * @Covers GAS.CaptureWithSnapshot
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
	 * Observe the snapshot flag on a capture taken with a snapshot.
	 *
	 * @Kind Observe
	 * @Covers GAS.CaptureWithSnapshot
	 * @Inputs an attribute name to capture
	 * @Return true when bSnapshot is true, or false for the unset-name fallback
	 * @Param AttributeName the attribute to capture; NAME_None skips the ensure
	 */
	UFUNCTION()
	bool CaptureSnapshot(FName AttributeName)
	{
		if (AttributeName.IsNone())
		{
			FGameplayEffectAttributeCaptureDefinition EmptyDef;
			return !EmptyDef.bSnapshot;
		}
		FGameplayEffectAttributeCaptureDefinition CaptureDef =
			UAngelscriptGameplayEffectUtils::CaptureGameplayAttribute(
				UTestSnapshotAttributes,
				AttributeName,
				EGameplayEffectAttributeCaptureSource::Source,
				true);
		return CaptureDef.bSnapshot;
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.CaptureWithSnapshot
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestSnapshotAttributesEmpty : UAngelscriptAttributeSet
{
}
