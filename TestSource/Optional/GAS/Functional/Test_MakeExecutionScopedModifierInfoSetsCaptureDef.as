// Theme: Optional.GAS. WorldStory: script attribute set supplies CritChance for
// MakeGameplayEffectExecutionScopedModifierInfo.
// C++: AngelscriptGASGameplayEffectUtilsTests.cpp::MakeExecutionScopedModifierInfoSetsCaptureDef
// sha256=1e841ca039e05da7e71f2d6903c4f6dc6bc45630d18bc1ea2fd93d4979998658; lines 232-239.
// Oracle: C++ CaptureGameplayAttribute(CritChance, Source, snapshot=true) then
// MakeGameplayEffectExecutionScopedModifierInfo; CapturedAttribute.AttributeToCapture is valid
// and AttributeSource is Source.
// Extra: unset set handle is null; default FAngelscriptGameplayAttributeData AttributeName is None.
// FixtureIsolated. Runner owns module teardown. Do not spawn from script.

UCLASS()
class UEffUtilScopedModAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData CritChance;
}

bool Observe_MakeExecutionScopedModifierInfoSetsCaptureDef_DefaultEmpty()
{
	UEffUtilScopedModAttributes Unset;
	FAngelscriptGameplayAttributeData Empty;
	return Unset == nullptr && Empty.AttributeName.IsNone();
}

bool Observe_MakeExecutionScopedModifierInfoSetsCaptureDef_CopyIndependence()
{
	UEffUtilScopedModAttributes First;
	UEffUtilScopedModAttributes Second;
	FAngelscriptGameplayAttributeData Copied;
	First = Second;
	return First == Second
		&& First == nullptr
		&& Copied.AttributeName.IsNone();
}
