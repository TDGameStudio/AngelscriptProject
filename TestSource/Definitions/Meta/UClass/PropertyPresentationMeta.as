/**
 * Category, DisplayName, ToolTip, ShortToolTip and AdvancedDisplay metadata. C++
 * reflects those keys on FProperty. The observers cover the declared defaults, a
 * zero health write and an empty label.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.PropertyPresentationMeta
 * @Harness UClass
 * @Tag Definitions.Meta.PropertyPresentationMeta
 * @Provenance Theme: Definitions.Meta. WorldStory: Category / DisplayName / ToolTip / ShortToolTip / AdvancedDisplay.
 * @Provenance C++: AngelscriptCoverageMetaSpecifierTests.cpp::PropertyPresentationMeta
 * @Provenance Oracle defaults: DetailedHealth 100, DisplayRatio 0.5, PresentationLabel "Ready".
 * @Provenance Extra: write 0 / empty label. FixtureIsolated.
 */

UCLASS()
class ACoverageMetaPropertyPresentationActor : AActor
{
	UPROPERTY(EditAnywhere, Category = "Coverage|Presentation", AdvancedDisplay, meta = (
		DisplayName = "Detailed Health",
		ToolTip = "Detailed health tooltip",
		ShortToolTip = "Health tip"))
	int DetailedHealth = 100;

	UPROPERTY(EditAnywhere, Category = "Coverage|Presentation", meta = (
		ToolTip = "Display-only ratio tooltip",
		ShortToolTip = "Ratio tip"))
	float DisplayRatio = 0.5f;

	UPROPERTY(Category = "Coverage|Nested|Presentation", meta = (
		DisplayName = "Presentation Label"))
	FString PresentationLabel = "Ready";

	/**
	 * Observe the DetailedHealth default.
	 *
	 * @Kind Observe
	 * @Covers Meta.PropertyPresentationMeta
	 * @Inputs none
	 * @Return 100
	 */
	UFUNCTION()
	int DetailedHealthDefault()
	{
		return DetailedHealth;
	}

	/**
	 * Observe the DisplayRatio default.
	 *
	 * @Kind Observe
	 * @Covers Meta.PropertyPresentationMeta
	 * @Inputs none
	 * @Return 0.5
	 */
	UFUNCTION()
	float DisplayRatioDefault()
	{
		return DisplayRatio;
	}

	/**
	 * Observe the PresentationLabel default.
	 *
	 * @Kind Observe
	 * @Covers Meta.PropertyPresentationMeta
	 * @Inputs none
	 * @Return "Ready"
	 */
	UFUNCTION()
	FString LabelDefault()
	{
		return PresentationLabel;
	}

	/**
	 * Observe that writing zero health is accepted.
	 *
	 * @Kind Observe
	 * @Covers Meta.PropertyPresentationMeta
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero health
	 */
	UFUNCTION()
	int ZeroHealthBoundary()
	{
		DetailedHealth = 0;
		return DetailedHealth;
	}

	/**
	 * Observe that an empty presentation label writes back.
	 *
	 * @Kind Observe
	 * @Covers Meta.PropertyPresentationMeta
	 * @Inputs none
	 * @Return 0
	 * @Boundary empty label
	 */
	UFUNCTION()
	int EmptyLabelLen()
	{
		PresentationLabel = "";
		return PresentationLabel.Len();
	}
}
