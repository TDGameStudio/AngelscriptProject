// Theme: Optional.GAS. WorldStory: script attribute set supplies Damage for
// CaptureGameplayAttribute.
// C++: AngelscriptGASGameplayEffectUtilsTests.cpp::CaptureGameplayAttributeReturnsValidDefinition
// sha256=dc0bd82118741260bf7ce4f45459e1617b158272fb66cb24f7031a2a366f5356; lines 53-60.
// Oracle: C++ CaptureGameplayAttribute(Damage, Source, snapshot=true) returns a valid
// AttributeToCapture, AttributeSource Source, and bSnapshot true.
// Extra: unset set handle is null; default FAngelscriptGameplayAttributeData AttributeName is None.
// FixtureIsolated. Runner owns module teardown. Do not spawn from script.

UCLASS()
class UEffUtilCaptureAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Damage;
}

bool Observe_CaptureGameplayAttributeReturnsValidDefinition_DefaultEmpty()
{
	UEffUtilCaptureAttributes Unset;
	FAngelscriptGameplayAttributeData Empty;
	return Unset == nullptr && Empty.AttributeName.IsNone();
}

bool Observe_CaptureGameplayAttributeReturnsValidDefinition_CopyIndependence()
{
	UEffUtilCaptureAttributes First;
	UEffUtilCaptureAttributes Second;
	FAngelscriptGameplayAttributeData Copied;
	First = Second;
	return First == Second
		&& First == nullptr
		&& Copied.AttributeName.IsNone();
}
