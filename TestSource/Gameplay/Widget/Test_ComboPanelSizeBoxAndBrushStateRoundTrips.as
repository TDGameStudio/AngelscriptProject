// Theme: Gameplay.Widget. Positive ComboBoxString / PanelWidget / SizeBox / FSlateBrush.
// C++: AngelscriptCoverageWidgetTests.cpp::ComboPanelSizeBoxAndBrushStateRoundTrips
// Oracle ExecuteBatchAndExpectInt each helper == 1:
// ComboBoxStringOptions, PanelWidgetBaseOperations, SizeBoxOverrideAccessors,
// SlateBrushFieldRoundTrip.
// Extra: Combo RemoveOption Medium leaves count 2; empty panel after ClearChildren.
// DefaultSafe.

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

bool Observe_ComboBoxStringOptions_Nominal()
{
	return ComboBoxStringOptions() == 1;
}

bool Observe_PanelWidgetBaseOperations_Nominal()
{
	return PanelWidgetBaseOperations() == 1;
}

bool Observe_SizeBoxOverrideAccessors_Nominal()
{
	return SizeBoxOverrideAccessors() == 1;
}

bool Observe_SlateBrushFieldRoundTrip_Nominal()
{
	return SlateBrushFieldRoundTrip() == 1;
}
