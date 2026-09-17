/**
 * @version v1
 * @summary The compile surface for WidgetBlueprint::CreateWidget plus AddToViewport and RemoveFromViewport. C++ looks up both helpers by declaration and does not execute them, so those names are part of the contract and are kept.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The compile surface for WidgetBlueprint::CreateWidget plus AddToViewport and RemoveFromViewport. C++ looks up both helpers by declaration and does not execute them, so those names are part of the contract and are kept.
 * @topic Baseline
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
/** @end */
