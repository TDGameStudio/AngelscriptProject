// Theme: Definitions.UFunction. WorldStory DisplayName/Keywords/ToolTip/AdvancedDisplay/AutoCreateRefTerm.
// C++: AngelscriptCoverageMetaSpecifierTests.cpp::UFunctionDisplayAndParameterMeta
// Oracle: ApplyMetaValue(Input, Scale, Offset, Label) == Input*Scale + Offset + Label.Len(); metadata is C++ side.
// Extra: empty label Len=0; nullptr actor is the empty handle; Scale=0 is a zero-product boundary.
// FixtureIsolated.

UCLASS()
class ACoverageMetaUFunctionMetaActor : AActor
{
	UFUNCTION(BlueprintCallable, Category = "Coverage|Meta", meta = (
		DisplayName = "Apply Meta Value",
		Keywords = "coverage meta function",
		ToolTip = "Applies metadata",
		ShortToolTip = "Apply meta",
		CompactNodeTitle = "META",
		AdvancedDisplay = "Scale,Offset",
		AutoCreateRefTerm = "Label"))
	int ApplyMetaValue(
		int Input,
		int Scale,
		int Offset,
		const FString&in Label)
	{
		return Input * Scale + Offset + Label.Len();
	}
}

bool Observe_DisplayMeta_Nominal(ACoverageMetaUFunctionMetaActor Actor)
{
	return Actor.ApplyMetaValue(4, 5, 6, "ab") == 28;
}

bool Observe_DisplayMeta_EmptyLabel(ACoverageMetaUFunctionMetaActor Actor)
{
	return Actor.ApplyMetaValue(4, 5, 6, "") == 26;
}

bool Observe_DisplayMeta_NullDefault()
{
	ACoverageMetaUFunctionMetaActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_DisplayMeta_ZeroScaleBoundary(ACoverageMetaUFunctionMetaActor Actor)
{
	return Actor.ApplyMetaValue(4, 0, 6, "") == 6 && Actor.ApplyMetaValue(0, 5, 0, "") == 0;
}
