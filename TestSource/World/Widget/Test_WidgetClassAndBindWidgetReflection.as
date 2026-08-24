// Theme: World.Widget. WorldStory: BindWidget UPROPERTY reflection plus Construct/Tick.
// C++: AngelscriptCoverageWidgetTests.cpp::WidgetClassAndBindWidgetReflection
// CompileWidgetClass then FindFProperty ScoreText/HealthBar/RestartButton (BindWidget)
// and FindFunction Construct/Tick. Keep those UPROPERTY names and bConstructCalled/LastTickDelta.
// sha256=eed17bb6ae79c0c03a81ad3473a9bf8fae7885ac4f56d86a5d9aeff899b48c7e; lines 324-355.
// Extra: local construct leaves BindWidget handles null, bConstructCalled false, LastTickDelta 0.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class UCoverageScoreWidget : UUserWidget
{
	UPROPERTY(BindWidget)
	UTextBlock ScoreText;

	UPROPERTY(BindWidget)
	UProgressBar HealthBar;

	UPROPERTY(BindWidget)
	UButton RestartButton;

	UPROPERTY()
	bool bConstructCalled = false;

	UPROPERTY()
	float LastTickDelta = 0.0f;

	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		bConstructCalled = true;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(FGeometry MyGeometry, float DeltaTime)
	{
		LastTickDelta = DeltaTime;
	}
}

bool Observe_ScoreWidget_DefaultEmpty(UCoverageScoreWidget Widget)
{
	if (Widget is null)
	{
		throw("Test_WidgetClassAndBindWidgetReflection setup: required Widget is null");
	}
	return Widget.ScoreText == nullptr
		&& Widget.HealthBar == nullptr
		&& Widget.RestartButton == nullptr
		&& Widget.bConstructCalled == false
		&& Widget.LastTickDelta == 0.0f;
}

bool Observe_ScoreWidget_CopyIndependence(UCoverageScoreWidget First, UCoverageScoreWidget Second)
{
	if (First is null)
	{
		throw("Test_WidgetClassAndBindWidgetReflection setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_WidgetClassAndBindWidgetReflection setup: required Second is null");
	}
	First.bConstructCalled = true;
	First.LastTickDelta = 0.016f;
	return First.bConstructCalled
		&& First.LastTickDelta == 0.016f
		&& Second.bConstructCalled == false
		&& Second.LastTickDelta == 0.0f
		&& Second.ScoreText == nullptr;
}
