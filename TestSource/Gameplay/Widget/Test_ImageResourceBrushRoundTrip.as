// Theme: Gameplay.Widget. Positive UImage texture brush resource round-trip.
// C++: AngelscriptCoverageWidgetTests.cpp::ImageResourceBrushRoundTrip
// Oracle: ImageResourceBrushRoundTrip(Texture) == 1.
// Extra: null Texture returns 0. DefaultSafe.

int ImageResourceBrushRoundTrip(UTexture2D Texture)
{
	UImage Image = Cast<UImage>(MakeWidget(UImage::StaticClass(), n"ImageResourceProbe"));
	if (Image == null || Texture == null)
	{
		return 0;
	}

	Image.SetBrushFromTexture(Texture, true);
	FSlateBrush TextureBrush(Texture, FVector2D(32.0f, 16.0f), FLinearColor(0.2f, 0.4f, 0.6f, 1.0f));
	Image.SetBrush(TextureBrush);
	return 1;
}

bool Observe_ImageResourceBrush_NullTexture()
{
	return ImageResourceBrushRoundTrip(nullptr) == 0;
}
