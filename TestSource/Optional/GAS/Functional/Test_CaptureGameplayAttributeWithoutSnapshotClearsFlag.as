// Theme: Optional.GAS. WorldStory: UTestNoSnapshotAttributes Speed capture without snapshot.
// C++: AngelscriptGASGameplayCueUtilsTests.cpp::CaptureGameplayAttributeWithoutSnapshotClearsFlag
// Oracle: CaptureGameplayAttribute(..., Target, false).bSnapshot is false.
// Extra: default capture def snapshot false; FName AttributeName None skips Capture ensure.
// Isolation=none. Optional GAS plugin fixture. Static capture; runner supplies names.

UCLASS()
class UTestNoSnapshotAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Speed;
}

UCLASS()
class UTestNoSnapshotAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestNoSnapshotAttributes_NullDefault()
{
	UTestNoSnapshotAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestNoSnapshotAttributes_EmptyCaptureDef()
{
	FGameplayEffectAttributeCaptureDefinition EmptyDef;
	return !EmptyDef.bSnapshot;
}

bool Observe_UTestNoSnapshotAttributes_CaptureNoSnapshot(FName AttributeName)
{
	if (AttributeName.IsNone())
	{
		FGameplayEffectAttributeCaptureDefinition EmptyDef;
		return !EmptyDef.bSnapshot;
	}
	FGameplayEffectAttributeCaptureDefinition CaptureDef =
		UAngelscriptGameplayEffectUtils::CaptureGameplayAttribute(
			UTestNoSnapshotAttributes,
			AttributeName,
			EGameplayEffectAttributeCaptureSource::Target,
			false);
	return !CaptureDef.bSnapshot;
}
