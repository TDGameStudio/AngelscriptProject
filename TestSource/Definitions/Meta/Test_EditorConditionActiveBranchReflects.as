// Theme: Definitions.Meta. WorldStory: #if EDITOR keeps ActiveBranchValue and GetBranchValue.
// C++: AngelscriptCoverageMacrosTests.cpp::EditorConditionActiveBranchReflects
// Oracle: GetBranchValue() == 57; InactiveBranchValue is not reflected.
// Extra: write ActiveBranchValue 0. FixtureIsolated.

UCLASS()
class ACoverageMacrosEditorConditionActor : AActor
{
	#if EDITOR
	UPROPERTY()
	int ActiveBranchValue = 57;

	UFUNCTION()
	int GetBranchValue() const
	{
		return ActiveBranchValue;
	}
	#else
	UPROPERTY()
	int InactiveBranchValue = -1;

	UFUNCTION()
	int GetBranchValue() const
	{
		return InactiveBranchValue;
	}
	#endif
}

int Observe_EditorCondition_GetBranchValue(ACoverageMacrosEditorConditionActor Actor)
{
	return Actor.GetBranchValue();
}

int Observe_EditorCondition_ZeroBoundary(ACoverageMacrosEditorConditionActor Actor)
{
	Actor.ActiveBranchValue = 0;
	return Actor.GetBranchValue();
}

int Observe_EditorCondition_EmptyDefaultIsNull()
{
	ACoverageMacrosEditorConditionActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
