// Theme: Feature.Inheritance. WorldStory Blueprint child inherits script BeginPlay.
// C++: AngelscriptBlueprintChildTests.cpp::InheritsBeginPlay
// Oracle after BP child BeginPlay: BeginPlayCount==1.
// Extra: empty handle null; pre-BeginPlay 0. FixtureIsolated. Keep BeginPlayCount.

UCLASS()
class ATestBPChildInheritsBeginPlayParent : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}
}

bool Observe_InheritsBeginPlay_EmptyHandleIsNull()
{
	ATestBPChildInheritsBeginPlayParent Actor;
	return Actor == nullptr;
}

int Observe_InheritsBeginPlay_BeforeBeginPlay(ATestBPChildInheritsBeginPlayParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0178 setup: required ATestBPChildInheritsBeginPlayParent is null");
	}
	return Actor.BeginPlayCount;
}

int Observe_InheritsBeginPlay_AfterBeginPlay(ATestBPChildInheritsBeginPlayParent Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0178 setup: required ATestBPChildInheritsBeginPlayParent is null");
	}
	return Actor.BeginPlayCount;
}
