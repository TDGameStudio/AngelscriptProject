/**
 * @version v1
 * @summary A query mixin and a mutating mixin compose on one actor. C++ expects after BeginPlay: bBelowBeforeClamp==false, Score==20, bWithinAfterClamp==true. The observers cover the empty handle, a default Score still below 30.
 * @topic Feature
 */
/**
 * @version root
 * @summary A query mixin and a mutating mixin compose on one actor. C++ expects after BeginPlay: bBelowBeforeClamp==false, Score==20, bWithinAfterClamp==true. The observers cover the empty handle, a default Score still below 30.
 * @topic Baseline
 */
/**
 * Mixin that asks whether Score is at least a threshold.
 *
 * @Kind Mixin
 * @Covers Mixin.MixinMethodsCanBeComposed
 * @Inputs the host actor and a threshold
 * @Param Self the mixin receiver
 * @Param Threshold the minimum Score
 * @Return true when Self.Score >= Threshold
 */
mixin bool IsScoreAtLeast(ACoverageMixinCompositionActor Self, int Threshold)
{
	return Self.Score >= Threshold;
}

/**
 * Mixin that clamps Score into [MinValue, MaxValue].
 *
 * @Kind Mixin
 * @Covers Mixin.MixinMethodsCanBeComposed
 * @Inputs the host actor and clamp bounds
 * @Param Self the mixin receiver
 * @Param MinValue the lower bound
 * @Param MaxValue the upper bound
 * @Return void; Self.Score is clamped
 */
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

	/**
	 * WorldStory: Score 25 is below 30, ClampScore(0, 20) leaves 20, then the score is at least 20.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.MixinMethodsCanBeComposed
	 * @Inputs none
	 * @Return bBelowBeforeClamp false, Score 20, bWithinAfterClamp true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Score = 25;
		bBelowBeforeClamp = this.IsScoreAtLeast(30);
		this.ClampScore(0, 20);
		bWithinAfterClamp = this.IsScoreAtLeast(20);
	}

	/**
	 * Observe that an unset host handle is null.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinMethodsCanBeComposed
	 * @Inputs an unset ACoverageMixinCompositionActor handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageMixinCompositionActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that default Score 0 is not at least 30.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinMethodsCanBeComposed
	 * @Inputs this actor before BeginPlay
	 * @Return true when IsScoreAtLeast(30) is false and Score is 0
	 * @Boundary default Score
	 */
	UFUNCTION()
	bool DefaultScoreNotAtLeast()
	{
		if (IsScoreAtLeast(30))
		{
			return false;
		}
		return Score == 0;
	}

	/**
	 * Observe the BeginPlay oracle: not below 30 after the query, Score 20, within after clamp.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinMethodsCanBeComposed
	 * @Inputs this actor after BeginPlay
	 * @Return true when bBelowBeforeClamp is false, Score is 20 and bWithinAfterClamp is true
	 */
	UFUNCTION()
	bool ClampedScoreAfterPlay()
	{
		if (bBelowBeforeClamp)
		{
			return false;
		}
		if (Score != 20)
		{
			return false;
		}
		return bWithinAfterClamp;
	}

	/**
	 * Observe that ClampScore raises a negative Score to the lower bound.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinMethodsCanBeComposed
	 * @Inputs Score set to -5 then ClampScore(0, 20)
	 * @Return Score after the clamp
	 * @Boundary negative Score
	 */
	UFUNCTION()
	int ClampLowBoundary()
	{
		Score = -5;
		ClampScore(0, 20);
		return Score;
	}
}
/** @end */
