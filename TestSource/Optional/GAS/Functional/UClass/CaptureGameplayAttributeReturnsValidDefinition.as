/**
 * A script attribute set supplying Damage for CaptureGameplayAttribute. C++ owns
 * the capture call; the observers cover the unset handle, the empty attribute data
 * and copy independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.CaptureGameplayAttribute
 * @Harness UClass
 * @Tag Optional.GAS.CaptureGameplayAttributeReturnsValidDefinition
 * @Provenance Theme: Optional.GAS. WorldStory: script attribute set supplies Damage for
 * @Provenance CaptureGameplayAttribute.
 * @Provenance C++: AngelscriptGASGameplayEffectUtilsTests.cpp::CaptureGameplayAttributeReturnsValidDefinition
 * @Provenance sha256=dc0bd82118741260bf7ce4f45459e1617b158272fb66cb24f7031a2a366f5356; lines 53-60.
 * @Provenance Oracle: C++ CaptureGameplayAttribute(Damage, Source, snapshot=true) returns a valid
 * @Provenance AttributeToCapture, AttributeSource Source, and bSnapshot true.
 * @Provenance Extra: unset set handle is null; default FAngelscriptGameplayAttributeData AttributeName is None.
 * @Provenance FixtureIsolated. Runner owns module teardown. Do not spawn from script.
 */

UCLASS()
class UEffUtilCaptureAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Damage;

	/**
	 * Observe that an unset handle is null and empty data has no name.
	 *
	 * @Kind Observe
	 * @Covers GAS.CaptureGameplayAttribute
	 * @Inputs an unset set handle and default attribute data
	 * @Return true when the handle is null and the name is none
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		UEffUtilCaptureAttributes Unset;
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
	 * @Covers GAS.CaptureGameplayAttribute
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both are null and the copied data has no name
	 * @Boundary copy aliasing
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		UEffUtilCaptureAttributes First;
		UEffUtilCaptureAttributes Second;
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
