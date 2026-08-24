// Theme: Gameplay.FLinearColor. WorldStory class-member execution after BeginPlay.
// C++: AngelscriptCoverageFLinearColorPropertyTests.cpp::FLinearColorClassMemberExecution
// Oracle: EditableColor.R 0.2 A 0.8; ColorHistory Num 3; [0].G 0.4; [1].R 1; [2].B 1;
// ReadRuntimeTint Equals (0.2,1,1,1); ReadConstTint Yellow; BlendHistory (1,1,1,1).
// Extra: ColorHistory empty before BeginPlay. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFLinearColorClassMemberActor : AActor
{
	UPROPERTY()
	FLinearColor EditableColor = FLinearColor(0.2, 0.4, 0.6, 0.8);

	UPROPERTY()
	TArray<FLinearColor> ColorHistory;

	FLinearColor RuntimeTint = FLinearColor::LucBlue;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FLinearColor LocalTint = EditableColor + RuntimeTint.GetClamped(0.0, 1.0);
		RuntimeTint = LocalTint.GetClamped(0.0, 1.0);
		ColorHistory.Add(EditableColor);
		ColorHistory.Add(ReadConstTint());
		ColorHistory.Add(FLinearColor::MakeFromHex(0xFFFFFFFF, false));
	}

	UFUNCTION()
	FLinearColor ReadRuntimeTint()
	{
		return RuntimeTint;
	}

	UFUNCTION()
	FLinearColor ReadConstTint()
	{
		const FLinearColor ConstTint = FLinearColor::Yellow;
		return ConstTint;
	}

	UFUNCTION()
	FLinearColor BlendHistory()
	{
		FLinearColor Total = FLinearColor::Transparent;
		for (int Index = 0; Index < ColorHistory.Num(); ++Index)
		{
			Total += ColorHistory[Index];
		}
		return Total.GetClamped(0.0, 1.0);
	}
}

bool Observe_ColorHistory_DefaultEmpty(ACoverageFLinearColorClassMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorClassMemberExecution setup: required Actor is null");
	}
	return Actor.ColorHistory.Num() == 0
		&& Actor.EditableColor.R == 0.2
		&& Actor.EditableColor.A == 0.8;
}

bool Observe_ColorHistory_AfterBeginPlay(ACoverageFLinearColorClassMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorClassMemberExecution setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.ColorHistory.Num() == 3
		&& Actor.ColorHistory[0].G == 0.4
		&& Actor.ColorHistory[1].R == 1.0
		&& Actor.ColorHistory[2].B == 1.0;
}

bool Observe_ReadRuntimeTint_AfterBeginPlay(ACoverageFLinearColorClassMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorClassMemberExecution setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.ReadRuntimeTint().Equals(FLinearColor(0.2, 1.0, 1.0, 1.0), 0.001);
}

bool Observe_ReadConstTint(ACoverageFLinearColorClassMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorClassMemberExecution setup: required Actor is null");
	}
	return Actor.ReadConstTint().Equals(FLinearColor::Yellow, 0.001);
}

bool Observe_BlendHistory_AfterBeginPlay(ACoverageFLinearColorClassMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorClassMemberExecution setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.BlendHistory().Equals(FLinearColor(1.0, 1.0, 1.0, 1.0), 0.001);
}
