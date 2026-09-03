/**
 * A script attribute set supplying Defense for the Target and not-snapshot
 * CaptureGameplayAttribute call. C++ owns the capture; the observers cover the
 * unset handle, the empty attribute data and copy independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.CaptureGameplayAttributeTarget
 * @Harness UClass
 * @Tag Optional.GAS.CaptureGameplayAttributeTargetNotSnapshot
 * @Provenance Theme: Optional.GAS. WorldStory: script attribute set supplies Defense for
 * @Provenance CaptureGameplayAttribute Target / not-snapshot.
 * @Provenance C++: AngelscriptGASGameplayEffectUtilsTests.cpp::CaptureGameplayAttributeTargetNotSnapshot
 * @Provenance sha256=231851370ea9dca316fa7258e82b41aabcb20de1a59e4ac8cba959c06b525944; lines 97-104.
 * @Provenance Oracle: C++ CaptureGameplayAttribute(Defense, Target, snapshot=false) returns a valid
 * @Provenance AttributeToCapture, AttributeSource Target, and bSnapshot false.
 * @Provenance Extra: unset set handle is null; default FAngelscriptGameplayAttributeData AttributeName is None.
 * @Provenance FixtureIsolated. Runner owns module teardown. Do not spawn from script.
 */

UCLASS()
class UEffUtilCaptureTargetAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Defense;

	/**
	 * Observe that an unset handle is null and empty data has no name.
	 *
	 * @Kind Observe
	 * @Covers GAS.CaptureGameplayAttributeTarget
	 * @Inputs an unset set handle and default attribute data
	 * @Return true when the handle is null and the name is none
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		UEffUtilCaptureTargetAttributes Unset;
		FAngelscriptGameplayAttributeData Empty;

		if (Unset != nullptr)
		{
			return false;
		}

		return Empty.AttributeName.IsNone();
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers GAS.CaptureGameplayAttributeTarget
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both are null and the copied data has no name
	 * @Boundary copy aliasing
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		UEffUtilCaptureTargetAttributes First;
		UEffUtilCaptureTargetAttributes Second;
		FAngelscriptGameplayAttributeData Copied;
		First = Second;

		if (First != Second)
		{
			return false;
		}

		if (First != nullptr)
		{
			return false;
		}

		return Copied.AttributeName.IsNone();
	}
}
