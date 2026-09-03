/**
 * BindWidget object properties plus Construct and Tick overrides. Defaults leave
 * bConstructCalled false and LastTickDelta 0. BindWidget handles are null until
 * the widget tree is built.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.MetadataAndPropertyTypes
 * @Harness UClass
 * @Tag Definitions.Meta.MetadataAndPropertyTypes
 * @Provenance Theme: Definitions.Meta. Positive: BindWidget object properties plus Construct/Tick overrides.
 * @Provenance C++: AngelscriptWidgetBindWidgetTests.cpp::MetadataAndPropertyTypes
 * @Provenance Oracle defaults: bConstructCalled false, LastTickDelta 0.0. Extra: Construct sets true; Tick writes DeltaTime 0.
 * @Provenance DefaultSafe. Keep ScoreText / HealthBar / RestartButton names.
 */

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

	/**
	 * WorldStory: Construct flips bConstructCalled.
	 *
	 * @Kind WorldStory
	 * @Covers Meta.MetadataAndPropertyTypes
	 * @Inputs none
	 * @Return bConstructCalled true
	 */
	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		bConstructCalled = true;
	}

	/**
	 * WorldStory: Tick stores DeltaTime.
	 *
	 * @Kind WorldStory
	 * @Covers Meta.MetadataAndPropertyTypes
	 * @Inputs the widget geometry and delta time
	 * @Return LastTickDelta written
	 * @Param MyGeometry the widget geometry
	 * @Param DeltaTime the tick delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(FGeometry MyGeometry, float DeltaTime)
	{
		LastTickDelta = DeltaTime;
	}

	/**
	 * Observe the Construct default.
	 *
	 * @Kind Observe
	 * @Covers Meta.MetadataAndPropertyTypes
	 * @Inputs none
	 * @Return false
	 */
	UFUNCTION()
	bool ConstructDefault()
	{
		return bConstructCalled;
	}

	/**
	 * Observe the LastTickDelta default.
	 *
	 * @Kind Observe
	 * @Covers Meta.MetadataAndPropertyTypes
	 * @Inputs none
	 * @Return 0
	 */
	UFUNCTION()
	float LastTickDeltaDefault()
	{
		return LastTickDelta;
	}

	/**
	 * Observe that BindWidget handles default to null.
	 *
	 * @Kind Observe
	 * @Covers Meta.MetadataAndPropertyTypes
	 * @Inputs none
	 * @Return true when ScoreText, HealthBar and RestartButton are null
	 * @Boundary BindWidget defaults
	 */
	UFUNCTION()
	bool BindWidgetDefaultsNull()
	{
		if (ScoreText != nullptr)
		{
			return false;
		}
		if (HealthBar != nullptr)
		{
			return false;
		}
		return RestartButton == nullptr;
	}

	/**
	 * Observe that Tick with delta 0 writes LastTickDelta 0.
	 *
	 * @Kind Observe
	 * @Covers Meta.MetadataAndPropertyTypes
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero delta
	 */
	UFUNCTION()
	float TickZeroBoundary()
	{
		FGeometry Geometry;
		Tick(Geometry, 0.0f);
		return LastTickDelta;
	}

	/**
	 * Observe that Construct on this instance leaves another instance unconstructed.
	 *
	 * @Kind Observe
	 * @Covers Meta.MetadataAndPropertyTypes
	 * @Inputs a second widget
	 * @Return true when this is constructed and the other is not
	 * @Param Second the other widget, expected to stay unconstructed
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ConstructThenCopyIndependence(UFunctionalScoreWidget Second)
	{
		if (Second is null)
		{
			throw("MetadataAndPropertyTypes setup: required Second is null");
		}
		Construct();
		if (!bConstructCalled)
		{
			return false;
		}
		return !Second.bConstructCalled;
	}
}
