// Theme: Feature.Inheritance. WorldStory parent+child BeginPlay/Tick step chain.
// C++: AngelscriptBlueprintChildTests.cpp::OverrideChain
// Oracle after BeginPlay: ParentBeginPlayCount==1, ChildBeginPlayCount==1;
// after ticks ParentTickCount/ChildTickCount each >= OverrideChainTickCount.
// Extra: empty handle null; pre-lifecycle 0; Tick(0.0) increments both steps.
// FixtureIsolated. Keep ParentBeginPlayCount/ParentTickCount/ChildBeginPlayCount/ChildTickCount.

UCLASS()
class ATestBPChildOverrideChainParent : AActor
{
	UPROPERTY()
	int ParentBeginPlayCount = 0;

	UPROPERTY()
	int ParentTickCount = 0;

	UFUNCTION()
	void ParentBeginPlayStep()
	{
		ParentBeginPlayCount += 1;
	}

	UFUNCTION()
	void ParentTickStep()
	{
		ParentTickCount += 1;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ParentBeginPlayStep();
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		ParentTickStep();
	}
}

UCLASS()
class ATestBPChildOverrideChainScriptChild : ATestBPChildOverrideChainParent
{
	UPROPERTY()
	int ChildBeginPlayCount = 0;

	UPROPERTY()
	int ChildTickCount = 0;

	UFUNCTION()
	void ChildBeginPlayStep()
	{
		ChildBeginPlayCount += 1;
	}

	UFUNCTION()
	void ChildTickStep()
	{
		ChildTickCount += 1;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ParentBeginPlayStep();
		ChildBeginPlayStep();
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		ParentTickStep();
		ChildTickStep();
	}
}

bool Observe_OverrideChain_EmptyHandleIsNull()
{
	ATestBPChildOverrideChainScriptChild Actor;
	return Actor == nullptr;
}

int Observe_OverrideChain_BeforeLifecycle(ATestBPChildOverrideChainScriptChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0180 setup: required ATestBPChildOverrideChainScriptChild is null");
	}
	return Actor.ParentBeginPlayCount + Actor.ChildBeginPlayCount + Actor.ParentTickCount + Actor.ChildTickCount;
}

int Observe_OverrideChain_ZeroDeltaTick(ATestBPChildOverrideChainScriptChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0180 setup: required ATestBPChildOverrideChainScriptChild is null");
	}
	Actor.Tick(0.0f);
	return Actor.ParentTickCount + Actor.ChildTickCount;
}

bool Observe_OverrideChain_AfterBeginPlay(ATestBPChildOverrideChainScriptChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0180 setup: required ATestBPChildOverrideChainScriptChild is null");
	}
	return Actor.ParentBeginPlayCount == 1 && Actor.ChildBeginPlayCount == 1;
}
