/**
 * @version v1
 * @summary FSlateColor and FSlateBrush constructors applied to an image and a text block. C++ executes SlateColorAndBrushConstructors and expects 1, so that name is part of the contract and is kept verbatim. A missed MakeWidget.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary FSlateColor and FSlateBrush constructors applied to an image and a text block. C++ executes SlateColorAndBrushConstructors and expects 1, so that name is part of the contract and is kept verbatim. A missed MakeWidget.
 * @topic Baseline
 */
namespace WidgetTest
{
	/**
	 * Construct linear and table slate colors plus color and style brushes, then apply them.
	 *
	 * @Kind Observe
	 * @Covers Widget.SlateStyleValueTypes
	 * @Inputs an image and a text block from MakeWidget
	 * @Return 1 after the setters; 0 on a missed MakeWidget
	 */
	UFUNCTION()
	int SlateColorAndBrushConstructors()
	{
		FSlateColor LinearColor = FSlateColor(FLinearColor(0.2f, 0.4f, 0.6f, 1.0f));
		FSlateColor TableColor = FSlateColor(EStyleColor::Foreground);
		FSlateBrush ColorBrush = FSlateBrush(FLinearColor(0.9f, 0.1f, 0.2f, 1.0f));
		FSlateBrush StyleBrush = FSlateBrush(n"WhiteBrush");

		UImage Image = Cast<UImage>(MakeWidget(UImage::StaticClass(), n"SlateStyleImageProbe"));
		UTextBlock Text = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"SlateStyleTextProbe"));
		if (Image == null || Text == null)
		{
			return 0;
		}

		Image.SetBrush(ColorBrush);
		Image.SetBrushTintColor(LinearColor);
		Text.SetColorAndOpacity(TableColor);
		Text.SetFontSize(18);
		return 1;
	}
}
/** @end */
