// Theme: Definitions.Meta. WorldStory: Category / DisplayName / ToolTip / ShortToolTip / AdvancedDisplay.
// C++: AngelscriptCoverageMetaSpecifierTests.cpp::PropertyPresentationMeta
// Oracle defaults: DetailedHealth 100, DisplayRatio 0.5, PresentationLabel "Ready".
// Extra: write 0 / empty label. FixtureIsolated.

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
}

int Observe_Presentation_DetailedHealthDefault(ACoverageMetaPropertyPresentationActor Actor)
{
	return Actor.DetailedHealth;
}

float Observe_Presentation_DisplayRatioDefault(ACoverageMetaPropertyPresentationActor Actor)
{
	return Actor.DisplayRatio;
}

FString Observe_Presentation_LabelDefault(ACoverageMetaPropertyPresentationActor Actor)
{
	return Actor.PresentationLabel;
}

int Observe_Presentation_ZeroHealthBoundary(ACoverageMetaPropertyPresentationActor Actor)
{
	Actor.DetailedHealth = 0;
	return Actor.DetailedHealth;
}

int Observe_Presentation_EmptyLabelLen(ACoverageMetaPropertyPresentationActor Actor)
{
	Actor.PresentationLabel = "";
	return Actor.PresentationLabel.Len();
}
