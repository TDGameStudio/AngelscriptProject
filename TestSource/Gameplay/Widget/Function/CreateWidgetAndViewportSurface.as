/**
 * The compile surface for WidgetBlueprint::CreateWidget plus AddToViewport and
 * RemoveFromViewport. C++ looks up both helpers by declaration and does not
 * execute them, so those names are part of the contract and are kept verbatim.
 * ZOrder 7 is the C++ literal on the uncalled path.
 *
 * @Theme Gameplay.Widget
 * @Subject Widget.CreateWidgetAndViewportSurface
 * @Harness Function
 * @Tag Gameplay.Widget.CreateWidgetAndViewportSurface
 * @Namespace WidgetTest
 * @Provenance Theme: Gameplay.Widget. Positive compile surface for CreateWidget / viewport methods.
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::CreateWidgetAndViewportSurface block 2.
 * @Provenance Oracle: CreateViaBlueprintNamespace and AddAndRemoveViaViewportMethods compile
 * @Provenance as callable helpers. C++ does not execute them. Extra: empty/default is the
 * @Provenance uncalled compile surface (ZOrder 7 is the C++ literal). DefaultSafe.
 */

namespace WidgetTest
{
	/**
	 * Create a user widget through the WidgetBlueprint namespace helper.
	 *
	 * @Kind Observe
	 * @Covers Widget.CreateWidgetAndViewportSurface
	 * @Inputs a user-widget class and an owning player
	 * @Return the created widget
	 * @Param WidgetClass the widget class to instantiate
	 * @Param OwningPlayer the player that owns the widget
	 */
	UFUNCTION()
	UUserWidget CreateViaBlueprintNamespace(const TSubclassOf<UUserWidget>&in WidgetClass, APlayerController OwningPlayer)
	{
		return WidgetBlueprint::CreateWidget(WidgetClass, OwningPlayer);
	}

	/**
	 * Add a widget to the viewport at Z-order 7 and then remove it.
	 *
	 * @Kind Action
	 * @Covers Widget.CreateWidgetAndViewportSurface
	 * @Inputs a user widget
	 * @Return none; AddToViewport(7) then RemoveFromViewport
	 * @Param Widget the widget to add and remove
	 * @Boundary uncalled compile surface
	 */
	UFUNCTION()
	void AddAndRemoveViaViewportMethods(UUserWidget Widget)
	{
		Widget.AddToViewport(7);
		Widget.RemoveFromViewport();
	}
}
