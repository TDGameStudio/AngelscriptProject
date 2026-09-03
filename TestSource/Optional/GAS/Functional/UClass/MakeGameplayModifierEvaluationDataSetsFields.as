/**
 * A script attribute set supplying AttackPower for the modifier evaluation data
 * factory. C++ owns the lookup and factory call; the observers cover the unset
 * handle, the empty attribute data and copy independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.MakeGameplayModifierEvaluationData
 * @Harness UClass
 * @Tag Optional.GAS.MakeGameplayModifierEvaluationDataSetsFields
 * @Provenance Theme: Optional.GAS. WorldStory: script attribute set supplies AttackPower for
 * @Provenance MakeGameplayModifierEvaluationData.
 * @Provenance C++: AngelscriptGASGameplayEffectUtilsTests.cpp::MakeGameplayModifierEvaluationDataSetsFields
 * @Provenance sha256=ccd14de3a712484a262f178be5edf16a1888a9fef294fb1bde96678df1a946b5; lines 141-148.
 * @Provenance Oracle: C++ GetGameplayAttribute(AttackPower) is valid; MakeGameplayModifierEvaluationData
 * @Provenance sets Attribute valid, ModifierOp Additive, Magnitude 25.f.
 * @Provenance Extra: unset set handle is null; default FAngelscriptGameplayAttributeData AttributeName is None.
 * @Provenance FixtureIsolated. Runner owns module teardown. Do not spawn from script.
 */

UCLASS()
class UEffUtilModEvalAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData AttackPower;

	/**
	 * Observe that an unset handle is null and empty data has no name.
	 *
	 * @Kind Observe
	 * @Covers GAS.MakeGameplayModifierEvaluationData
	 * @Inputs an unset set handle and default attribute data
	 * @Return true when the handle is null and the name is none
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		UEffUtilModEvalAttributes Unset;
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
	 * @Covers GAS.MakeGameplayModifierEvaluationData
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both are null and the copied data has no name
	 * @Boundary copy aliasing
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		UEffUtilModEvalAttributes First;
		UEffUtilModEvalAttributes Second;
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
