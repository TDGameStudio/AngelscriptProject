/**
 * @version v1
 * @summary Observe palette, root-widget, tree-removal, viewport, and WidgetBlueprint::CreateWidget lifecycle mutation.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe palette, root-widget, tree-removal, viewport, and WidgetBlueprint::CreateWidget lifecycle mutation.
 * @topic Baseline
 */
// Runner owns the user-widget and player-controller fixtures.
// AS-facing API: void UUserWidget.SetPaletteCategory(const FText& InPaletteCategory);
// void UUserWidget.SetRootWidget(UWidget NewRootWidget);
// bool UUserWidget.RemoveWidget(UWidget WidgetToRemove);
// void UUserWidget.AddToViewport(int32 ZOrder = 0);
// UUserWidget WidgetBlueprint::CreateWidget(const TSubclassOf<UUserWidget>& WidgetClass, APlayerController OwningPlayer);
// Inputs: Runner-owned UUserWidget, FText::FromString("TestSource.Palette"), a
// constructed UTextBlock root, null root restoration, RemoveWidget on the
// child then on null, AddToViewport default and ZOrder 1, TSubclassOf of the
// probe class, and runner-owned OwningPlayer.
// Expected observations: SetPaletteCategory is visible through GetPaletteCategory
// ToString. SetRootWidget updates GetRootWidget identity. RemoveWidget returns
// true for the live child and false for null/already-removed. CreateWidget
// returns a non-null widget; empty class returns null.
// Boundary/ownership: The widget tree owns constructed children. CreateWidget
// borrows WorldContext and OwningPlayer. SetupOwner=Runner.

UCLASS()
class UTSUserWidgetMutationProbe : UUserWidget
{
}

namespace TS_UUserWidget_MutationAndLifecycle_01
{
	bool Observe_SetPaletteCategory_Nominal(UUserWidget Widget)
	{
		if (Widget is null)
		{
			throw("TS_UUserWidget_MutationAndLifecycle_01 setup: required Widget is null");
		}
		FText Category = FText::FromString("TestSource.Palette");
		Widget.SetPaletteCategory(Category);
		FText AfterFirst = Widget.GetPaletteCategory();
		Widget.SetPaletteCategory(Category);
		FText AfterRepeat = Widget.GetPaletteCategory();
		FText Empty;
		Widget.SetPaletteCategory(Empty);
		FText Restored = Widget.GetPaletteCategory();
		return AfterFirst.ToString() == "TestSource.Palette" && AfterRepeat.ToString() == "TestSource.Palette" && Restored.ToString() != "TestSource.Palette";
	}

	bool Observe_SetRootWidget_Nominal(UUserWidget Widget)
	{
		if (Widget is null)
		{
			throw("TS_UUserWidget_MutationAndLifecycle_01 setup: required Widget is null");
		}
		UWidget Child = Widget.ConstructWidget(UTextBlock::StaticClass(), n"TestSource.MutationRoot");
		if (Child is null)
		{
			throw("TS_UUserWidget_MutationAndLifecycle_01 setup: ConstructWidget returned null");
		}
		Widget.SetRootWidget(Child);
		UWidget AfterFirst = Widget.GetRootWidget();
		Widget.SetRootWidget(Child);
		UWidget AfterRepeat = Widget.GetRootWidget();
		Widget.SetRootWidget(nullptr);
		UWidget AfterNull = Widget.GetRootWidget();
		return AfterFirst == Child && AfterRepeat == Child && AfterNull is null;
	}

	bool Observe_RemoveWidget_Nominal(UUserWidget Widget)
	{
		if (Widget is null)
		{
			throw("TS_UUserWidget_MutationAndLifecycle_01 setup: required Widget is null");
		}
		UWidget Child = Widget.ConstructWidget(UTextBlock::StaticClass(), n"TestSource.MutationChild");
		if (Child is null)
		{
			throw("TS_UUserWidget_MutationAndLifecycle_01 setup: ConstructWidget returned null");
		}
		Widget.SetRootWidget(Child);
		bool bRemoved = Widget.RemoveWidget(Child);
		bool bRemovedAgain = Widget.RemoveWidget(Child);
		UWidget NullWidget = nullptr;
		bool bRemovedNull = Widget.RemoveWidget(NullWidget);
		return bRemoved && !bRemovedAgain && !bRemovedNull;
	}

	bool Observe_AddToViewport_Nominal(UUserWidget Widget)
	{
		if (Widget is null)
		{
			throw("TS_UUserWidget_MutationAndLifecycle_01 setup: required Widget is null");
		}
		Widget.AddToViewport();
		Widget.AddToViewport(0);
		Widget.AddToViewport(1);
		return IsValid(Widget);
	}

	bool Observe_CreateWidget_Nominal(APlayerController OwningPlayer)
	{
		if (OwningPlayer is null)
		{
			throw("TS_UUserWidget_MutationAndLifecycle_01 setup: required OwningPlayer is null");
		}
		TSubclassOf<UUserWidget> ProbeClass = UTSUserWidgetMutationProbe::StaticClass();
		UUserWidget Created = WidgetBlueprint::CreateWidget(ProbeClass, OwningPlayer);
		TSubclassOf<UUserWidget> EmptyClass;
		UUserWidget EmptyCreated = WidgetBlueprint::CreateWidget(EmptyClass, OwningPlayer);
		UUserWidget BaseCreated = WidgetBlueprint::CreateWidget(UUserWidget::StaticClass(), OwningPlayer);
		return Created != nullptr && EmptyCreated is null && BaseCreated != nullptr;
	}
}
/** @end */
