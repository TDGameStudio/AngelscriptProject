// Theme: Optional.GAS. WorldStory: UTestSnapshotAttributes Power capture with snapshot.
// C++: AngelscriptGASGameplayCueUtilsTests.cpp::CaptureGameplayAttributeWithSnapshotSetsFlag
// Oracle: CaptureGameplayAttribute(..., Source, true).bSnapshot is true.
// Extra: default capture def snapshot false; FName AttributeName None skips Capture ensure.
// Isolation=none. Optional GAS plugin fixture. Static capture; runner supplies names.

UCLASS()
class UTestSnapshotAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Power;
}

UCLASS()
class UTestSnapshotAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestSnapshotAttributes_NullDefault()
{
	UTestSnapshotAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestSnapshotAttributes_EmptyCaptureDef()
{
	FGameplayEffectAttributeCaptureDefinition EmptyDef;
	return !EmptyDef.bSnapshot;
}

bool Observe_UTestSnapshotAttributes_CaptureSnapshot(FName AttributeName)
{
	if (AttributeName.IsNone())
	{
		FGameplayEffectAttributeCaptureDefinition EmptyDef;
		return !EmptyDef.bSnapshot;
	}
	FGameplayEffectAttributeCaptureDefinition CaptureDef =
		UAngelscriptGameplayEffectUtils::CaptureGameplayAttribute(
			UTestSnapshotAttributes,
			AttributeName,
			EGameplayEffectAttributeCaptureSource::Source,
			true);
	return CaptureDef.bSnapshot;
}
