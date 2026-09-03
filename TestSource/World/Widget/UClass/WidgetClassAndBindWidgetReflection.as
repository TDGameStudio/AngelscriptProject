/**
 * A user widget whose BindWidget UPROPERTYs are found by C++ through reflection,
 * alongside the Construct and Tick overrides. C++ compiles the widget class and
 * looks up the three bound widgets and both functions by name, so those names are
 * part of the contract and are kept verbatim. The observers cover the local-construct
 * default and copy independence.
 *
 * @Theme World.Widget
 * @Subject Widget.WidgetClassAndBindWidgetReflection
 * @Harness UClass
 * @Tag World.Widget.WidgetClassAndBindWidgetReflection
 * @Provenance Theme: World.Widget. WorldStory: BindWidget UPROPERTY reflection plus Construct/Tick.
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::WidgetClassAndBindWidgetReflection
 * @Provenance CompileWidgetClass then FindFProperty ScoreText/HealthBar/RestartButton (BindWidget)
 * @Provenance and FindFunction Construct/Tick. Keep those UPROPERTY names and bConstructCalled/LastTickDelta.
 * @Provenance sha256=eed17bb6ae79c0c03a81ad3473a9bf8fae7885ac4f56d86a5d9aeff899b48c7e; lines 324-355.
 * @Provenance Extra: local construct leaves BindWidget handles null, bConstructCalled false, LastTickDelta 0.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

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

	/**
	 * WorldStory: Construct records that the widget was built.
	 *
	 * @Kind WorldStory
	 * @Covers Widget.WidgetClassAndBindWidgetReflection
	 * @Inputs none
	 * @Return bConstructCalled == true
	 */
	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		bConstructCalled = true;
	}

	/**
	 * WorldStory: Tick keeps the delta it was given.
	 *
	 * @Kind WorldStory
	 * @Covers Widget.WidgetClassAndBindWidgetReflection
	 * @Inputs the widget geometry and the frame delta
	 * @Return LastTickDelta set to the frame delta
	 * @Param MyGeometry the widget geometry
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(FGeometry MyGeometry, float DeltaTime)
	{
		LastTickDelta = DeltaTime;
	}

	/**
	 * Observe that a locally constructed widget has no bound widgets and no state.
	 *
	 * @Kind Observe
	 * @Covers Widget.WidgetClassAndBindWidgetReflection
	 * @Inputs a widget that has not been constructed
	 * @Return true when all three bound widgets are null, the flag is clear and the delta is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ScoreText != nullptr)
		{
			return false;
		}
		if (HealthBar != nullptr)
		{
			return false;
		}
		if (RestartButton != nullptr)
		{
			return false;
		}
		if (bConstructCalled)
		{
			return false;
		}
		return LastTickDelta == 0.0f;
	}

	/**
	 * Observe that writing this widget leaves another widget untouched.
	 *
	 * @Kind Observe
	 * @Covers Widget.WidgetClassAndBindWidgetReflection
	 * @Inputs this widget plus a second widget
	 * @Return true when this holds the constructed state and the other stays at its defaults
	 * @Param Second the other widget, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UCoverageScoreWidget Second)
	{
		if (Second is null)
		{
			throw("WidgetClassAndBindWidgetReflection setup: required Second is null");
		}
		bConstructCalled = true;
		LastTickDelta = 0.016f;

		if (!bConstructCalled)
		{
			return false;
		}
		if (LastTickDelta != 0.016f)
		{
			return false;
		}
		if (Second.bConstructCalled)
		{
			return false;
		}
		if (Second.LastTickDelta != 0.0f)
		{
			return false;
		}
		return Second.ScoreText == nullptr;
	}
}
