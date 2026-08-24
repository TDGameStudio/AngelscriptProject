// Theme: Optional.GAS. WorldStory: script attribute set supplies AttackPower for
// MakeGameplayModifierEvaluationData.
// C++: AngelscriptGASGameplayEffectUtilsTests.cpp::MakeGameplayModifierEvaluationDataSetsFields
// sha256=ccd14de3a712484a262f178be5edf16a1888a9fef294fb1bde96678df1a946b5; lines 141-148.
// Oracle: C++ GetGameplayAttribute(AttackPower) is valid; MakeGameplayModifierEvaluationData
// sets Attribute valid, ModifierOp Additive, Magnitude 25.f.
// Extra: unset set handle is null; default FAngelscriptGameplayAttributeData AttributeName is None.
// FixtureIsolated. Runner owns module teardown. Do not spawn from script.

UCLASS()
class UEffUtilModEvalAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData AttackPower;
}

bool Observe_MakeGameplayModifierEvaluationDataSetsFields_DefaultEmpty()
{
	UEffUtilModEvalAttributes Unset;
	FAngelscriptGameplayAttributeData Empty;
	return Unset == nullptr && Empty.AttributeName.IsNone();
}

bool Observe_MakeGameplayModifierEvaluationDataSetsFields_CopyIndependence()
{
	UEffUtilModEvalAttributes First;
	UEffUtilModEvalAttributes Second;
	FAngelscriptGameplayAttributeData Copied;
	First = Second;
	return First == Second
		&& First == nullptr
		&& Copied.AttributeName.IsNone();
}
