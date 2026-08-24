// Theme: Definitions.Meta. Positive: BindWidget object properties plus Construct/Tick overrides.
// C++: AngelscriptWidgetBindWidgetTests.cpp::MetadataAndPropertyTypes
// Oracle defaults: bConstructCalled false, LastTickDelta 0.0. Extra: Construct sets true; Tick writes DeltaTime 0.
// DefaultSafe. Keep ScoreText / HealthBar / RestartButton names.

UCLASS()
class UFunctionalScoreWidget : UUserWidget
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

bool Observe_ScoreWidget_ConstructDefault(UFunctionalScoreWidget Widget)
{
	return Widget.bConstructCalled;
}

float Observe_ScoreWidget_LastTickDeltaDefault(UFunctionalScoreWidget Widget)
{
	return Widget.LastTickDelta;
}

bool Observe_ScoreWidget_BindWidgetDefaultsNull(UFunctionalScoreWidget Widget)
{
	return Widget.ScoreText == nullptr && Widget.HealthBar == nullptr && Widget.RestartButton == nullptr;
}

float Observe_ScoreWidget_TickZeroBoundary(UFunctionalScoreWidget Widget)
{
	FGeometry Geometry;
	Widget.Tick(Geometry, 0.0f);
	return Widget.LastTickDelta;
}

bool Observe_ScoreWidget_ConstructThenCopyIndependence(UFunctionalScoreWidget First, UFunctionalScoreWidget Second)
{
	First.Construct();
	return First.bConstructCalled && !Second.bConstructCalled;
}
