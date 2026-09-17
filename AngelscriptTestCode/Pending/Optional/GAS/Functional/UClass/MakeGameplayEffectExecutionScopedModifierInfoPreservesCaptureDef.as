/**
 * @version v1
 * @summary A script attribute set supplying Damage for the scoped-modifier info factory, which must preserve the snapshot flag from the capture. C++ owns the capture and factory call; the observers cover the unset handle, the empty.
 * @topic Optional
 */
/**
 * @version root
 * @summary A script attribute set supplying Damage for the scoped-modifier info factory, which must preserve the snapshot flag from the capture. C++ owns the capture and factory call; the observers cover the unset handle, the empty.
 * @topic Baseline
 */
UCLASS()
class UTestScopedModAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Damage;

	/**
	 * Observe that an unset handle is null and empty data has no name.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScopedModifierInfoPreservesCapture
	 * @Inputs an unset set handle and default attribute data
	 * @Return true when the handle is null and the name is none
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		UTestScopedModAttributes Unset;
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
	 * @Covers GAS.ScopedModifierInfoPreservesCapture
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both are null and the copied data has no name
	 * @Boundary copy aliasing
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		UTestScopedModAttributes First;
		UTestScopedModAttributes Second;
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
