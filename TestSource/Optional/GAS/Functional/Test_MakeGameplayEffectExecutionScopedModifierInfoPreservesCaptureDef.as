// Theme: Optional.GAS. WorldStory: script attribute set supplies Damage for
// MakeGameplayEffectExecutionScopedModifierInfo.
// C++: AngelscriptGASGameplayCueUtilsTests.cpp::MakeGameplayEffectExecutionScopedModifierInfoPreservesCaptureDef
// sha256=acbf14fddfcad03114f896e56d606bd2d63ad0b6ddec73ae588e922e3ae3887c; lines 162-169.
// Oracle: C++ CaptureGameplayAttribute(Damage, Source, snapshot=true) then
// MakeGameplayEffectExecutionScopedModifierInfo; CapturedAttribute.bSnapshot is true.
// Extra: unset set handle is null; default FAngelscriptGameplayAttributeData AttributeName is None.
// FixtureIsolated. Runner owns module teardown. Do not spawn from script.

UCLASS()
class UTestScopedModAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Damage;
}

bool Observe_MakeGameplayEffectExecutionScopedModifierInfo_DefaultEmpty()
{
	UTestScopedModAttributes Unset;
	FAngelscriptGameplayAttributeData Empty;
	return Unset == nullptr && Empty.AttributeName.IsNone();
}

bool Observe_MakeGameplayEffectExecutionScopedModifierInfo_CopyIndependence()
{
	UTestScopedModAttributes First;
	UTestScopedModAttributes Second;
	FAngelscriptGameplayAttributeData Copied;
	First = Second;
	return First == Second
		&& First == nullptr
		&& Copied.AttributeName.IsNone();
}
