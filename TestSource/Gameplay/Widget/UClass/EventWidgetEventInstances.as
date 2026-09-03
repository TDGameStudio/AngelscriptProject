/**
 * A harness whose Bind attaches button, slider and editable-text handlers that
 * C++ then broadcasts. C++ compiles the class and looks up Bind plus the
 * UPROPERTY names, so those names are part of the contract and are kept
 * verbatim. The observers cover the empty default, the C++ broadcast values, a
 * zero slider and the independence of two instances.
 *
 * @Theme Gameplay.Widget
 * @Subject Widget.EventWidgetEventInstances
 * @Harness UClass
 * @Tag Gameplay.Widget.EventWidgetEventInstances
 * @Provenance Theme: Gameplay.Widget. Positive widget event harness; C++ compiles then Broadcasts.
 * @Provenance C++: AngelscriptCoverageEventTests.cpp::EventWidgetEventInstances
 * @Provenance Oracle after Bind + Broadcast: ClickCount 1, PressCount 1, ReleaseCount 1,
 * @Provenance SliderValue 0.75, LastText "Changed".
 * @Provenance Extra: defaults 0/empty; direct handlers with the C++ broadcast values.
 * @Provenance Keep UPROPERTY names. DefaultSafe.
 */

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

	/**
	 * Bind button, slider and text events onto this harness.
	 *
	 * @Kind Action
	 * @Covers Widget.EventWidgetEventInstances
	 * @Inputs a button, a slider and an editable text
	 * @Return none; AddUFunction on clicked, pressed, released, value-changed and text-changed
	 * @Param Button the button
	 * @Param Slider the slider
	 * @Param Text the editable text
	 */
	UFUNCTION()
	void Bind(UButton Button, USlider Slider, UEditableText Text)
	{
		Button.OnClicked.AddUFunction(this, n"HandleClicked");
		Button.OnPressed.AddUFunction(this, n"HandlePressed");
		Button.OnReleased.AddUFunction(this, n"HandleReleased");
		Slider.OnValueChanged.AddUFunction(this, n"HandleSliderChanged");
		Text.OnTextChanged.AddUFunction(this, n"HandleTextChanged");
	}

	/**
	 * Record a button clicked event.
	 *
	 * @Kind Action
	 * @Covers Widget.EventWidgetEventInstances
	 * @Inputs none
	 * @Return ClickCount incremented
	 */
	UFUNCTION()
	void HandleClicked()
	{
		ClickCount += 1;
	}

	/**
	 * Record a button pressed event.
	 *
	 * @Kind Action
	 * @Covers Widget.EventWidgetEventInstances
	 * @Inputs none
	 * @Return PressCount incremented
	 */
	UFUNCTION()
	void HandlePressed()
	{
		PressCount += 1;
	}

	/**
	 * Record a button released event.
	 *
	 * @Kind Action
	 * @Covers Widget.EventWidgetEventInstances
	 * @Inputs none
	 * @Return ReleaseCount incremented
	 */
	UFUNCTION()
	void HandleReleased()
	{
		ReleaseCount += 1;
	}

	/**
	 * Record a slider value-changed event.
	 *
	 * @Kind Action
	 * @Covers Widget.EventWidgetEventInstances
	 * @Inputs the new slider value
	 * @Return SliderValue updated
	 * @Param Value the new slider value
	 */
	UFUNCTION()
	void HandleSliderChanged(float32 Value)
	{
		SliderValue = Value;
	}

	/**
	 * Record an editable-text changed event.
	 *
	 * @Kind Action
	 * @Covers Widget.EventWidgetEventInstances
	 * @Inputs the new text
	 * @Return LastText updated
	 * @Param Value the new text
	 */
	UFUNCTION()
	void HandleTextChanged(const FText&in Value)
	{
		LastText = Value.ToString();
	}

	/**
	 * Observe that an untouched harness has no events.
	 *
	 * @Kind Observe
	 * @Covers Widget.EventWidgetEventInstances
	 * @Inputs none
	 * @Return true when all counts are 0, the slider is 0 and LastText is empty
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ClickCount != 0)
		{
			return false;
		}
		if (PressCount != 0)
		{
			return false;
		}
		if (ReleaseCount != 0)
		{
			return false;
		}
		if (SliderValue != 0.0f)
		{
			return false;
		}
		return LastText.Len() == 0;
	}

	/**
	 * Observe that the C++ broadcast values land on this harness.
	 *
	 * @Kind Observe
	 * @Covers Widget.EventWidgetEventInstances
	 * @Inputs the click, press, release, slider and text values C++ broadcasts
	 * @Return true when the counts are 1, the slider is 0.75 and LastText is Changed
	 */
	UFUNCTION()
	bool BroadcastValues()
	{
		HandleClicked();
		HandlePressed();
		HandleReleased();
		HandleSliderChanged(0.75f);
		HandleTextChanged(FText::FromString("Changed"));

		if (ClickCount != 1)
		{
			return false;
		}
		if (PressCount != 1)
		{
			return false;
		}
		if (ReleaseCount != 1)
		{
			return false;
		}
		if (SliderValue != 0.75f)
		{
			return false;
		}
		return LastText == "Changed";
	}

	/**
	 * Observe that a zero slider write leaves the click count at 0.
	 *
	 * @Kind Observe
	 * @Covers Widget.EventWidgetEventInstances
	 * @Inputs a zero slider value
	 * @Return true when the slider is 0 and ClickCount is 0
	 * @Boundary zero slider
	 */
	UFUNCTION()
	bool ZeroSliderBoundary()
	{
		HandleSliderChanged(0.0f);

		if (SliderValue != 0.0f)
		{
			return false;
		}
		return ClickCount == 0;
	}

	/**
	 * Observe that writing this harness leaves another harness at its defaults.
	 *
	 * @Kind Observe
	 * @Covers Widget.EventWidgetEventInstances
	 * @Inputs a second harness
	 * @Return true when this records a click and the other still reads 0
	 * @Param Second the other harness, expected to stay empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UCoverageEventWidgetHarness Second)
	{
		if (Second is null)
		{
			throw("EventWidgetEventInstances setup: required Second is null");
		}
		HandleClicked();

		if (ClickCount != 1)
		{
			return false;
		}
		return Second.ClickCount == 0;
	}
}
