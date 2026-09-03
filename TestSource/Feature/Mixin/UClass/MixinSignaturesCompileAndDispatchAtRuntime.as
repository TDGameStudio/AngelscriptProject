/**
 * Mixin signatures with defaults dispatch from BeginPlay. C++ expects after
 * BeginPlay: SimpleTagged==true, AccumulatedScore==12, PairResult==true. The
 * observers cover the empty handle, pre-BeginPlay false/0, and TagPairMixin of
 * a null other.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.MixinSignaturesCompileAndDispatchAtRuntime
 * @Harness UClass
 * @Tag Feature.Mixin.MixinSignaturesCompileAndDispatchAtRuntime
 * @Provenance Theme: Feature.Mixin. WorldStory mixin signatures with defaults dispatch from BeginPlay.
 * @Provenance C++: AngelscriptFunctionMixinReferenceMatrixTests.cpp::MixinSignaturesCompileAndDispatchAtRuntime
 * @Provenance Oracle after BeginPlay: SimpleTagged==true, AccumulatedScore==12, PairResult==true.
 * @Provenance Extra: empty handle null; pre-BeginPlay false/0; TagPairMixin(nullptr) is false.
 * @Provenance FixtureIsolated. Keep SimpleTagged/AccumulatedScore/PairResult.
 */

/**
 * Mixin that sets SimpleTagged on the host.
 *
 * @Kind Mixin
 * @Covers Mixin.MixinSignaturesCompileAndDispatchAtRuntime
 * @Inputs the host actor as Self
 * @Param Self the mixin receiver
 * @Return void; Self.SimpleTagged becomes true
 */
mixin void TagMixin(AFunctionalMixinHostActor Self)
{
	Self.SimpleTagged = true;
}

/**
 * Mixin that adds to AccumulatedScore, defaulting the increment to 5.
 *
 * @Kind Mixin
 * @Covers Mixin.MixinSignaturesCompileAndDispatchAtRuntime
 * @Inputs the host actor and an optional increment
 * @Param Self the mixin receiver
 * @Param Increment the score delta, default 5
 * @Return void; Self.AccumulatedScore increases by Increment
 */
mixin void TagDefaultedMixin(AFunctionalMixinHostActor Self, int Increment = 5)
{
	Self.AccumulatedScore += Increment;
}

/**
 * Mixin that records whether a positive threshold met a non-null other host.
 *
 * @Kind Mixin
 * @Covers Mixin.MixinSignaturesCompileAndDispatchAtRuntime
 * @Inputs the host, another host, and an optional threshold
 * @Param Self the mixin receiver
 * @Param Other the paired host
 * @Param Threshold must be > 0.0, default 500.0
 * @Return void; Self.PairResult is true only when Threshold > 0.0 and Other is non-null
 */
mixin void TagPairMixin(AFunctionalMixinHostActor Self, AFunctionalMixinHostActor Other, float Threshold = 500.0)
{
	Self.PairResult = (Threshold > 0.0 && Other != nullptr);
}

UCLASS()
class AFunctionalMixinHostActor : AActor
{
	UPROPERTY()
	bool SimpleTagged = false;

	UPROPERTY()
	int32 AccumulatedScore = 0;

	UPROPERTY()
	bool PairResult = false;

	/**
	 * WorldStory: TagMixin, TagDefaultedMixin default then 7, TagPairMixin(this).
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.MixinSignaturesCompileAndDispatchAtRuntime
	 * @Inputs this actor as the pair other
	 * @Return SimpleTagged true, AccumulatedScore 12, PairResult true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		this.TagMixin();
		this.TagDefaultedMixin();
		this.TagDefaultedMixin(7);

		AFunctionalMixinHostActor Other = this;
		this.TagPairMixin(Other);
	}

	/**
	 * Observe that an unset host handle is null.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinSignaturesCompileAndDispatchAtRuntime
	 * @Inputs an unset AFunctionalMixinHostActor handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		AFunctionalMixinHostActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that tags and score are unset before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinSignaturesCompileAndDispatchAtRuntime
	 * @Inputs this actor before BeginPlay
	 * @Return true when SimpleTagged is false, AccumulatedScore is 0 and PairResult is false
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	bool DefaultsAreUnset()
	{
		if (SimpleTagged)
		{
			return false;
		}
		if (AccumulatedScore != 0)
		{
			return false;
		}
		return !PairResult;
	}

	/**
	 * Observe the BeginPlay oracle: tagged, score 12, pair true.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinSignaturesCompileAndDispatchAtRuntime
	 * @Inputs this actor after BeginPlay
	 * @Return true when SimpleTagged is true, AccumulatedScore is 12 and PairResult is true
	 */
	UFUNCTION()
	bool TaggedScoreAfterPlay()
	{
		if (!SimpleTagged)
		{
			return false;
		}
		if (AccumulatedScore != 12)
		{
			return false;
		}
		return PairResult;
	}

	/**
	 * Observe that TagPairMixin(nullptr) clears PairResult.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinSignaturesCompileAndDispatchAtRuntime
	 * @Inputs this actor and a null other
	 * @Return true when PairResult is false
	 * @Boundary null other
	 */
	UFUNCTION()
	bool NullOtherPairIsFalse()
	{
		TagPairMixin(nullptr);
		return !PairResult;
	}
}
