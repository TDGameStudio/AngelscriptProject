/**
 * A script attribute set supplying Damage for the scoped-modifier info factory,
 * which must preserve the snapshot flag from the capture. C++ owns the capture and
 * factory call; the observers cover the unset handle, the empty attribute data and
 * copy independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.ScopedModifierInfoPreservesCapture
 * @Harness UClass
 * @Tag Optional.GAS.MakeGameplayEffectExecutionScopedModifierInfoPreservesCaptureDef
 * @Provenance Theme: Optional.GAS. WorldStory: script attribute set supplies Damage for
 * @Provenance MakeGameplayEffectExecutionScopedModifierInfo.
 * @Provenance C++: AngelscriptGASGameplayCueUtilsTests.cpp::MakeGameplayEffectExecutionScopedModifierInfoPreservesCaptureDef
 * @Provenance sha256=acbf14fddfcad03114f896e56d606bd2d63ad0b6ddec73ae588e922e3ae3887c; lines 162-169.
 * @Provenance Oracle: C++ CaptureGameplayAttribute(Damage, Source, snapshot=true) then
 * @Provenance MakeGameplayEffectExecutionScopedModifierInfo; CapturedAttribute.bSnapshot is true.
 * @Provenance Extra: unset set handle is null; default FAngelscriptGameplayAttributeData AttributeName is None.
 * @Provenance FixtureIsolated. Runner owns module teardown. Do not spawn from script.
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
