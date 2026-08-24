// Theme: Gameplay.Widget. Positive compile surface for CreateWidget / viewport methods.
// C++: AngelscriptCoverageWidgetTests.cpp::CreateWidgetAndViewportSurface block 2.
// Oracle: CreateViaBlueprintNamespace and AddAndRemoveViaViewportMethods compile
// as callable helpers. C++ does not execute them. Extra: empty/default is the
// uncalled compile surface (ZOrder 7 is the C++ literal). DefaultSafe.

UUserWidget CreateViaBlueprintNamespace(const TSubclassOf<UUserWidget>& WidgetClass, APlayerController OwningPlayer)
{
	return WidgetBlueprint::CreateWidget(WidgetClass, OwningPlayer);
}

void AddAndRemoveViaViewportMethods(UUserWidget Widget)
{
	Widget.AddToViewport(7);
	Widget.RemoveFromViewport();
}
