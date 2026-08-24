// Theme: Feature.Mixin. WorldStory composed query + mutating mixin.
// C++: AngelscriptCoverageMixinTests.cpp::MixinMethodsCanBeComposed
// Oracle after BeginPlay: bBelowBeforeClamp==false, Score==20, bWithinAfterClamp==true.
// Extra: empty handle null; Score 0 stays below 30. FixtureIsolated.
// Keep Score/bBelowBeforeClamp/bWithinAfterClamp.

mixin bool IsScoreAtLeast(ACoverageMixinCompositionActor Self, int Threshold)
{
	return Self.Score >= Threshold;
}

mixin void ClampScore(ACoverageMixinCompositionActor Self, int MinValue, int MaxValue)
{
	if (Self.Score < MinValue)
	{
		Self.Score = MinValue;
	}
	else if (Self.Score > MaxValue)
	{
		Self.Score = MaxValue;
	}
}

UCLASS()
class ACoverageMixinCompositionActor : AActor
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	bool bBelowBeforeClamp = false;

	UPROPERTY()
	bool bWithinAfterClamp = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Score = 25;
		bBelowBeforeClamp = this.IsScoreAtLeast(30);
		this.ClampScore(0, 20);
		bWithinAfterClamp = this.IsScoreAtLeast(20);
	}
}

bool Observe_MixinCompose_EmptyHandleIsNull()
{
	ACoverageMixinCompositionActor Actor;
	return Actor == nullptr;
}

bool Observe_MixinCompose_DefaultScoreNotAtLeast(ACoverageMixinCompositionActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0056 setup: required ACoverageMixinCompositionActor is null");
	}
	return !Actor.IsScoreAtLeast(30) && Actor.Score == 0;
}

bool Observe_MixinCompose_AfterBeginPlay(ACoverageMixinCompositionActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0056 setup: required ACoverageMixinCompositionActor is null");
	}
	return !Actor.bBelowBeforeClamp && Actor.Score == 20 && Actor.bWithinAfterClamp;
}

int Observe_MixinCompose_ClampLowBoundary(ACoverageMixinCompositionActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0056 setup: required ACoverageMixinCompositionActor is null");
	}
	Actor.Score = -5;
	Actor.ClampScore(0, 20);
	return Actor.Score;
}
