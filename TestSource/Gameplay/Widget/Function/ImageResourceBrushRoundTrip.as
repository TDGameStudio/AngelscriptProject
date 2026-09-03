/**
 * UImage texture brush resource round-trip. C++ executes
 * ImageResourceBrushRoundTrip(Texture) and expects 1, so that name is part of
 * the contract and is kept verbatim. A null texture returns 0.
 *
 * @Theme Gameplay.Widget
 * @Subject Widget.ImageResourceBrushRoundTrip
 * @Harness Function
 * @Tag Gameplay.Widget.ImageResourceBrushRoundTrip
 * @Namespace WidgetTest
 * @Provenance Theme: Gameplay.Widget. Positive UImage texture brush resource round-trip.
 * @Provenance C++: AngelscriptCoverageWidgetTests.cpp::ImageResourceBrushRoundTrip
 * @Provenance Oracle: ImageResourceBrushRoundTrip(Texture) == 1.
 * @Provenance Extra: null Texture returns 0. DefaultSafe.
 */

namespace WidgetTest
{
	/**
	 * Assign a texture brush to an image, then overwrite it with a sized tinted brush.
	 *
	 * @Kind Observe
	 * @Covers Widget.ImageResourceBrushRoundTrip
	 * @Inputs a texture
	 * @Return 1 after both writes; 0 when the image or texture is null
	 * @Param Texture the texture to bind
	 */
	UFUNCTION()
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

	/**
	 * Observe that a null texture is refused.
	 *
	 * @Kind Observe
	 * @Covers Widget.ImageResourceBrushRoundTrip
	 * @Inputs a null texture
	 * @Return true when the entrypoint returns 0
	 * @Boundary null texture
	 */
	UFUNCTION()
	bool NullTexture()
	{
		return ImageResourceBrushRoundTrip(nullptr) == 0;
	}
}
