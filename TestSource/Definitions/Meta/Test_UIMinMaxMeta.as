// Theme: Definitions.Meta. WorldStory: UIMin/UIMax (and combined Clamp) meta.
// C++: AngelscriptCoverageMetaSpecifierTests.cpp::UIMinMaxMeta
// Oracle defaults: UIRangedInt 50, UIRangedFloat 0.5, UIRangedDouble 0.0, ComboRangedInt 50.
// Extra: write 0; copy independence. FixtureIsolated.

UCLASS()
class ACoverageMetaUIRangeActor : AActor
{
	UPROPERTY(meta = (UIMin = "0", UIMax = "100"))
	int UIRangedInt = 50;

	UPROPERTY(meta = (UIMin = "0.0", UIMax = "1.0"))
	float UIRangedFloat = 0.5f;

	UPROPERTY(meta = (UIMin = "-180.0", UIMax = "180.0"))
	double UIRangedDouble = 0.0;

	UPROPERTY(meta = (ClampMin = "0", ClampMax = "255", UIMin = "0", UIMax = "100"))
	int ComboRangedInt = 50;
}

int Observe_UIRange_UIRangedIntDefault(ACoverageMetaUIRangeActor Actor)
{
	return Actor.UIRangedInt;
}

float Observe_UIRange_UIRangedFloatDefault(ACoverageMetaUIRangeActor Actor)
{
	return Actor.UIRangedFloat;
}

double Observe_UIRange_UIRangedDoubleDefault(ACoverageMetaUIRangeActor Actor)
{
	return Actor.UIRangedDouble;
}

int Observe_UIRange_ComboRangedIntDefault(ACoverageMetaUIRangeActor Actor)
{
	return Actor.ComboRangedInt;
}

int Observe_UIRange_ZeroBoundary(ACoverageMetaUIRangeActor Actor)
{
	Actor.UIRangedInt = 0;
	Actor.ComboRangedInt = 0;
	return Actor.UIRangedInt + Actor.ComboRangedInt;
}

bool Observe_UIRange_CopyIndependence(ACoverageMetaUIRangeActor First, ACoverageMetaUIRangeActor Second)
{
	First.UIRangedInt = 1;
	Second.UIRangedInt = 50;
	return First.UIRangedInt == 1 && Second.UIRangedInt == 50;
}
