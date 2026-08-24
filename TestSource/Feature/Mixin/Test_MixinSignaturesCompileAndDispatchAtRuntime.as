// Theme: Feature.Mixin. WorldStory mixin signatures with defaults dispatch from BeginPlay.
// C++: AngelscriptFunctionMixinReferenceMatrixTests.cpp::MixinSignaturesCompileAndDispatchAtRuntime
// Oracle after BeginPlay: SimpleTagged==true, AccumulatedScore==12, PairResult==true.
// Extra: empty handle null; pre-BeginPlay false/0; TagPairMixin(nullptr) is false.
// FixtureIsolated. Keep SimpleTagged/AccumulatedScore/PairResult.

mixin void TagMixin(AFunctionalMixinHostActor Self)
{
	Self.SimpleTagged = true;
}

mixin void TagDefaultedMixin(AFunctionalMixinHostActor Self, int Increment = 5)
{
	Self.AccumulatedScore += Increment;
}

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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		this.TagMixin();
		this.TagDefaultedMixin();
		this.TagDefaultedMixin(7);

		AFunctionalMixinHostActor Other = this;
		this.TagPairMixin(Other);
	}
}

bool Observe_MixinSignatures_EmptyHandleIsNull()
{
	AFunctionalMixinHostActor Actor;
	return Actor == nullptr;
}

bool Observe_MixinSignatures_BeforeBeginPlay(AFunctionalMixinHostActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0210 setup: required AFunctionalMixinHostActor is null");
	}
	return !Actor.SimpleTagged && Actor.AccumulatedScore == 0 && !Actor.PairResult;
}

bool Observe_MixinSignatures_AfterBeginPlay(AFunctionalMixinHostActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0210 setup: required AFunctionalMixinHostActor is null");
	}
	return Actor.SimpleTagged && Actor.AccumulatedScore == 12 && Actor.PairResult;
}

bool Observe_MixinSignatures_NullOtherBoundary(AFunctionalMixinHostActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0210 setup: required AFunctionalMixinHostActor is null");
	}
	Actor.TagPairMixin(nullptr);
	return !Actor.PairResult;
}
