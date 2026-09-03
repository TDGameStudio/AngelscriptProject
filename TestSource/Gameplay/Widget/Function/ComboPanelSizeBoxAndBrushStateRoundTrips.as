/**
 * ComboBoxString options, PanelWidget children, SizeBox overrides and an
 * FSlateBrush field write. C++ executes each helper and expects 1, so those
 * names are part of the contract and are kept verbatim. Removing Medium leaves
 * two options; ClearChildren empties the panel.
 *
 * @Theme Gameplay.Widget
 * @Subject Widget.ComboPanelSizeBoxAndBrushStateRoundTrips
 * @Harness Function
 * @Tag Gameplay.Widget.ComboPanelSizeBoxAndBrushStateRoundTrips
 * @Namespace WidgetTest
 * @Provenance Theme: Gameplay.Widget. Positive ComboBoxString / PanelWidget / SizeBox / FSlateBrush.
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::ComboPanelSizeBoxAndBrushStateRoundTrips
 * @Provenance Oracle ExecuteBatchAndExpectInt each helper == 1:
 * @Provenance ComboBoxStringOptions, PanelWidgetBaseOperations, SizeBoxOverrideAccessors,
 * @Provenance SlateBrushFieldRoundTrip.
 * @Provenance Extra: Combo RemoveOption Medium leaves count 2; empty panel after ClearChildren.
 * @Provenance DefaultSafe.
 */

namespace WidgetTest
{
	/**
	 * Add, select and remove combo-box string options.
	 *
	 * @Kind Observe
	 * @Covers Widget.ComboPanelSizeBoxAndBrushStateRoundTrips
	 * @Inputs a combo box from MakeWidget
	 * @Return 1 when High stays selected after Medium is removed; 0 on a missed MakeWidget; 10/20/30/40 on mismatch
	 */
	UFUNCTION()
	int ComboBoxStringOptions()
	{
		UComboBoxString Combo = Cast<UComboBoxString>(MakeWidget(UComboBoxString::StaticClass(), n"ComboProbe"));
		if (Combo == null)
		{
			return 0;
		}

		Combo.AddOption("Low");
		Combo.AddOption("Medium");
		Combo.AddOption("High");
		if (Combo.GetOptionCount() != 3 || Combo.FindOptionIndex("Medium") != 1)
		{
			return 10;
		}

		Combo.SetSelectedOption("High");
		if (Combo.GetSelectedOption() != "High")
		{
			return 20;
		}

		if (!Combo.RemoveOption("Medium"))
		{
			return 30;
		}
		if (Combo.GetOptionCount() != 2 || Combo.FindOptionIndex("Medium") != -1)
		{
			return 40;
		}

		return 1;
	}

	/**
	 * Add, remove and clear children on a panel widget.
	 *
	 * @Kind Observe
	 * @Covers Widget.ComboPanelSizeBoxAndBrushStateRoundTrips
	 * @Inputs a vertical box and two text children from MakeWidget
	 * @Return 1 when ClearChildren leaves no children; 0 on a missed MakeWidget; 10/20/30/40/50 on mismatch
	 */
	UFUNCTION()
	int PanelWidgetBaseOperations()
	{
		UPanelWidget Panel = Cast<UPanelWidget>(MakeWidget(UVerticalBox::StaticClass(), n"PanelBaseProbe"));
		UTextBlock First = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"PanelBaseFirst"));
		UTextBlock Second = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"PanelBaseSecond"));
		if (Panel == null || First == null || Second == null)
		{
			return 0;
		}

		if (Panel.AddChild(First) == null || Panel.AddChild(Second) == null)
		{
			return 10;
		}
		if (Panel.GetChildrenCount() != 2 || Panel.GetChildAt(1) != Second)
		{
			return 20;
		}
		if (!Panel.RemoveChild(First) || First.GetParent() != null)
		{
			return 30;
		}
		if (Panel.GetChildrenCount() != 1 || Panel.GetChildAt(0) != Second)
		{
			return 40;
		}

		Panel.ClearChildren();
		return !Panel.HasAnyChildren() && Second.GetParent() == null ? 1 : 50;
	}

	/**
	 * Write width, height and min-desired-width overrides onto a size box.
	 *
	 * @Kind Observe
	 * @Covers Widget.ComboPanelSizeBoxAndBrushStateRoundTrips
	 * @Inputs a size box from MakeWidget
	 * @Return 1 after the setters; 0 on a missed MakeWidget
	 */
	UFUNCTION()
	int SizeBoxOverrideAccessors()
	{
		USizeBox SizeBox = Cast<USizeBox>(MakeWidget(USizeBox::StaticClass(), n"SizeBoxRoundTripProbe"));
		if (SizeBox == null)
		{
			return 0;
		}

		SizeBox.SetWidthOverride(321.0f);
		SizeBox.SetHeightOverride(123.0f);
		SizeBox.SetMinDesiredWidth(222.0f);
		return 1;
	}

	/**
	 * Write an FSlateBrush onto an image.
	 *
	 * @Kind Observe
	 * @Covers Widget.ComboPanelSizeBoxAndBrushStateRoundTrips
	 * @Inputs an image from MakeWidget
	 * @Return 1 after SetBrush; 0 on a missed MakeWidget
	 */
	UFUNCTION()
	int SlateBrushFieldRoundTrip()
	{
		UImage Image = Cast<UImage>(MakeWidget(UImage::StaticClass(), n"BrushFieldProbe"));
		if (Image == null)
		{
			return 0;
		}

		FSlateBrush Brush = FSlateBrush(FLinearColor(0.15f, 0.25f, 0.35f, 1.0f));
		Brush.ImageSize = FVector2f(48.0f, 24.0f);
		Brush.DrawAs = ESlateBrushDrawType::Box;
		Brush.TintColor = FSlateColor(FLinearColor(0.45f, 0.55f, 0.65f, 1.0f));
		Image.SetBrush(Brush);
		return 1;
	}
}
