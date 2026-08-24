// Theme: Gameplay.Widget. Positive widget event harness; C++ compiles then Broadcasts.
// C++: AngelscriptCoverageEventTests.cpp::EventWidgetEventInstances
// Oracle after Bind + Broadcast: ClickCount 1, PressCount 1, ReleaseCount 1,
// SliderValue 0.75, LastText "Changed".
// Extra: defaults 0/empty; direct handlers with the C++ broadcast values.
// Keep UPROPERTY names. DefaultSafe.

UCLASS()
class UCoverageEventWidgetHarness : UObject
{
	UPROPERTY()
	int ClickCount = 0;

	UPROPERTY()
	int PressCount = 0;

	UPROPERTY()
	int ReleaseCount = 0;

	UPROPERTY()
	float SliderValue = 0.0f;

	UPROPERTY()
	FString LastText;

	UFUNCTION()
	void Bind(UButton Button, USlider Slider, UEditableText Text)
	{
		Button.OnClicked.AddUFunction(this, n"HandleClicked");
		Button.OnPressed.AddUFunction(this, n"HandlePressed");
		Button.OnReleased.AddUFunction(this, n"HandleReleased");
		Slider.OnValueChanged.AddUFunction(this, n"HandleSliderChanged");
		Text.OnTextChanged.AddUFunction(this, n"HandleTextChanged");
	}

	UFUNCTION()
	void HandleClicked()
	{
		ClickCount += 1;
	}

	UFUNCTION()
	void HandlePressed()
	{
		PressCount += 1;
	}

	UFUNCTION()
	void HandleReleased()
	{
		ReleaseCount += 1;
	}

	UFUNCTION()
	void HandleSliderChanged(float32 Value)
	{
		SliderValue = Value;
	}

	UFUNCTION()
	void HandleTextChanged(const FText&in Value)
	{
		LastText = Value.ToString();
	}
}

bool Observe_EventWidget_DefaultEmpty(UCoverageEventWidgetHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_EventWidgetEventInstances setup: required Harness is null");
	}
	return Harness.ClickCount == 0
		&& Harness.PressCount == 0
		&& Harness.ReleaseCount == 0
		&& Harness.SliderValue == 0.0f
		&& Harness.LastText.Len() == 0;
}

bool Observe_EventWidget_CppBroadcastValues(UCoverageEventWidgetHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_EventWidgetEventInstances setup: required Harness is null");
	}
	Harness.HandleClicked();
	Harness.HandlePressed();
	Harness.HandleReleased();
	Harness.HandleSliderChanged(0.75f);
	Harness.HandleTextChanged(FText::FromString("Changed"));
	return Harness.ClickCount == 1
		&& Harness.PressCount == 1
		&& Harness.ReleaseCount == 1
		&& Harness.SliderValue == 0.75f
		&& Harness.LastText == "Changed";
}

bool Observe_EventWidget_ZeroSliderBoundary(UCoverageEventWidgetHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_EventWidgetEventInstances setup: required Harness is null");
	}
	Harness.HandleSliderChanged(0.0f);
	return Harness.SliderValue == 0.0f && Harness.ClickCount == 0;
}
