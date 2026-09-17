/**
 * @version v1
 * @summary A script attribute set supplying Defense for the Target and not-snapshot CaptureGameplayAttribute call. C++ owns the capture; the observers cover the unset handle, the empty attribute data and copy independence.
 * @topic Optional
 */
/**
 * @version root
 * @summary A script attribute set supplying Defense for the Target and not-snapshot CaptureGameplayAttribute call. C++ owns the capture; the observers cover the unset handle, the empty attribute data and copy independence.
 * @topic Baseline
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
/** @end */
