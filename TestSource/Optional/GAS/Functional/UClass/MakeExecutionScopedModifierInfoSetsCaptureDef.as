/**
 * A script attribute set supplying CritChance for the scoped-modifier info
 * factory. C++ owns the capture and factory call; the observers cover the unset
 * handle, the empty attribute data and copy independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.MakeExecutionScopedModifierInfo
 * @Harness UClass
 * @Tag Optional.GAS.MakeExecutionScopedModifierInfoSetsCaptureDef
 * @Provenance Theme: Optional.GAS. WorldStory: script attribute set supplies CritChance for
 * @Provenance MakeGameplayEffectExecutionScopedModifierInfo.
 * @Provenance C++: AngelscriptGASGameplayEffectUtilsTests.cpp::MakeExecutionScopedModifierInfoSetsCaptureDef
 * @Provenance sha256=1e841ca039e05da7e71f2d6903c4f6dc6bc45630d18bc1ea2fd93d4979998658; lines 232-239.
 * @Provenance Oracle: C++ CaptureGameplayAttribute(CritChance, Source, snapshot=true) then
 * @Provenance MakeGameplayEffectExecutionScopedModifierInfo; CapturedAttribute.AttributeToCapture is valid
 * @Provenance and AttributeSource is Source.
 * @Provenance Extra: unset set handle is null; default FAngelscriptGameplayAttributeData AttributeName is None.
 * @Provenance FixtureIsolated. Runner owns module teardown. Do not spawn from script.
 */

UCLASS()
class UEffUtilScopedModAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData CritChance;

	/**
	 * Observe that an unset handle is null and empty data has no name.
	 *
	 * @Kind Observe
	 * @Covers GAS.MakeExecutionScopedModifierInfo
	 * @Inputs an unset set handle and default attribute data
	 * @Return true when the handle is null and the name is none
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		UEffUtilScopedModAttributes Unset;
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
	 * @Covers GAS.MakeExecutionScopedModifierInfo
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both are null and the copied data has no name
	 * @Boundary copy aliasing
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		UEffUtilScopedModAttributes First;
		UEffUtilScopedModAttributes Second;
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
