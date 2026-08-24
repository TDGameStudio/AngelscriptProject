// Theme: Optional.GAS. WorldStory: script attribute set supplies Defense for
// CaptureGameplayAttribute Target / not-snapshot.
// C++: AngelscriptGASGameplayEffectUtilsTests.cpp::CaptureGameplayAttributeTargetNotSnapshot
// sha256=231851370ea9dca316fa7258e82b41aabcb20de1a59e4ac8cba959c06b525944; lines 97-104.
// Oracle: C++ CaptureGameplayAttribute(Defense, Target, snapshot=false) returns a valid
// AttributeToCapture, AttributeSource Target, and bSnapshot false.
// Extra: unset set handle is null; default FAngelscriptGameplayAttributeData AttributeName is None.
// FixtureIsolated. Runner owns module teardown. Do not spawn from script.

UCLASS()
class UEffUtilCaptureTargetAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Defense;
}

bool Observe_CaptureGameplayAttributeTargetNotSnapshot_DefaultEmpty()
{
	UEffUtilCaptureTargetAttributes Unset;
	FAngelscriptGameplayAttributeData Empty;
	return Unset == nullptr && Empty.AttributeName.IsNone();
}

bool Observe_CaptureGameplayAttributeTargetNotSnapshot_CopyIndependence()
{
	UEffUtilCaptureTargetAttributes First;
	UEffUtilCaptureTargetAttributes Second;
	FAngelscriptGameplayAttributeData Copied;
	First = Second;
	return First == Second
		&& First == nullptr
		&& Copied.AttributeName.IsNone();
}
