// Theme: Feature.Inheritance. Positive UUserWidget lifecycle/animation BlueprintOverride reflection.
// C++: AngelscriptCoverageWidgetTests.cpp::WidgetLifecycleAndAnimationOverrideReflection
// Compile + property/UFunction reflection. Oracle sentinels: bInitialized/bConstructed/bDestructed,
// TickCount, LastStartedAnimation, LastFinishedAnimation.
// Extra: default false/0/null; TickCount stays 0 until Tick. DefaultSafe.
// Keep bInitialized/bConstructed/bDestructed/TickCount/LastStartedAnimation/LastFinishedAnimation.

UCLASS()
class UCoverageLifecycleAnimationWidget : UUserWidget
{
	UPROPERTY()
	bool bInitialized = false;

	UPROPERTY()
	bool bConstructed = false;

	UPROPERTY()
	bool bDestructed = false;

	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	UWidgetAnimation LastStartedAnimation;

	UPROPERTY()
	UWidgetAnimation LastFinishedAnimation;

	UFUNCTION(BlueprintOverride)
	void OnInitialized()
	{
		bInitialized = true;
	}

	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		bConstructed = true;
	}

	UFUNCTION(BlueprintOverride)
	void Destruct()
	{
		bDestructed = true;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(FGeometry MyGeometry, float DeltaTime)
	{
		TickCount++;
	}

	UFUNCTION(BlueprintOverride)
	void OnAnimationStarted(const UWidgetAnimation Animation)
	{
		bInitialized = true;
	}

	UFUNCTION(BlueprintOverride)
	void OnAnimationFinished(const UWidgetAnimation Animation)
	{
		bConstructed = true;
	}
}

bool Observe_WidgetLifecycle_DefaultSentinels(UCoverageLifecycleAnimationWidget Widget)
{
	if (Widget == nullptr)
	{
		throw("TS-FEAT-0157 setup: required UCoverageLifecycleAnimationWidget is null");
	}
	return !Widget.bInitialized
		&& !Widget.bConstructed
		&& !Widget.bDestructed
		&& Widget.TickCount == 0
		&& Widget.LastStartedAnimation == nullptr
		&& Widget.LastFinishedAnimation == nullptr;
}

bool Observe_WidgetLifecycle_EmptyHandleIsNull()
{
	UCoverageLifecycleAnimationWidget Widget;
	return Widget == nullptr;
}

int Observe_WidgetLifecycle_OnInitializedBoundary(UCoverageLifecycleAnimationWidget Widget)
{
	if (Widget == nullptr)
	{
		throw("TS-FEAT-0157 setup: required UCoverageLifecycleAnimationWidget is null");
	}
	Widget.OnInitialized();
	return Widget.bInitialized ? 1 : 0;
}
