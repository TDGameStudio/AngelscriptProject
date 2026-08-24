// Purpose: Observe FPaintContext named/geometry/asset DrawBox overloads,
// DrawRotatedBox, and texture/material FSlateBrush constructors.
// Runner owns the brush-asset and texture fixtures used by those constructors.
// AS-facing API: void FPaintContext.DrawBox(const FVector2D& Position, const FVector2D& Size, const FName& BrushName, const FLinearColor& TintColor = FLinearColor::White);
// void FPaintContext.DrawBox(const FVector2D& Position, const FVector2D& Size, const FSlateBrush& Brush, const FLinearColor& TintColor = FLinearColor::White);
// void FPaintContext.DrawBox(const FGeometry& Geometry, const FSlateBrush& Brush, const FLinearColor& TintColor = FLinearColor::White);
// void FPaintContext.DrawBox(const FVector2D& Position, const FVector2D& Size, USlateBrushAsset Brush, const FLinearColor& TintColor = FLinearColor::White);
// void FPaintContext.DrawRotatedBox(const FVector2D& Position, const FVector2D& Size, float32 Angle, const FSlateBrush& Brush, const FLinearColor& TintColor = FLinearColor::White);
// FSlateBrush Brush(UTexture2D Texture, const FVector2D& ImageSize, const FLinearColor& Tint = FLinearColor::White);
// FSlateBrush Brush(UMaterialInterface Material, const FVector2D& ImageSize, const FLinearColor& Tint = FLinearColor::White);
// Inputs: Default FPaintContext, Position (0,0) and Size (10,20), n"WhiteBrush",
// a color brush, allotted geometry, runner-owned USlateBrushAsset plus null asset,
// Angle 0 and 45, runner-owned UTexture2D, a null UMaterialInterface, default tint
// omission and FLinearColor::Red.
// Expected observations: Allotted geometry local size stays non-negative after
// drawing. Texture-brush construction stores ImageSize 16. Material-brush
// construction accepts null as the empty resource and still stores ImageSize.
// Boundary/ownership: Draw helpers increment paint MaxLayer and borrow brushes.
// Null USlateBrushAsset is a no-op draw. SetupOwner=Runner for asset/texture.

namespace TS_UUserWidget_NamespaceAndGlobalFunctions_01
{
	bool Observe_DrawBox_Nominal(USlateBrushAsset BrushAsset)
	{
		if (BrushAsset is null)
		{
			throw("TS_UUserWidget_NamespaceAndGlobalFunctions_01 setup: required BrushAsset is null");
		}
		FPaintContext PaintContext;
		FVector2D Position;
		FVector2D Size(10.0, 20.0);
		FSlateBrush ColorBrush(FLinearColor::White);
		FGeometry Geometry;
		USlateBrushAsset NullAsset = nullptr;

		PaintContext.DrawBox(Position, Size, n"WhiteBrush");
		PaintContext.DrawBox(Position, Size, n"WhiteBrush", FLinearColor::Red);
		PaintContext.DrawBox(Position, Size, ColorBrush);
		PaintContext.DrawBox(Position, Size, ColorBrush, FLinearColor::Red);
		PaintContext.DrawBox(Geometry, ColorBrush);
		PaintContext.DrawBox(Geometry, ColorBrush, FLinearColor::White);
		PaintContext.DrawBox(Position, Size, BrushAsset);
		PaintContext.DrawBox(Position, Size, NullAsset, FLinearColor::White);

		FVector2D Local = PaintContext.GetAllottedGeometry().GetLocalSize();
		return Local.X >= 0.0 && Local.Y >= 0.0;
	}

	bool Observe_DrawRotatedBox_Nominal()
	{
		FPaintContext PaintContext;
		FVector2D Position;
		FVector2D Size(8.0, 8.0);
		FSlateBrush ColorBrush(FLinearColor::White);
		PaintContext.DrawRotatedBox(Position, Size, 0.0, ColorBrush);
		PaintContext.DrawRotatedBox(Position, Size, 45.0, ColorBrush, FLinearColor::Red);
		FVector2D Local = PaintContext.GetAllottedGeometry().GetLocalSize();
		return Local.X >= 0.0 && Local.Y >= 0.0;
	}

	bool Observe_Brush_Nominal(UTexture2D Texture)
	{
		if (Texture is null)
		{
			throw("TS_UUserWidget_NamespaceAndGlobalFunctions_01 setup: required Texture is null");
		}
		UMaterialInterface Material = nullptr;
		FVector2D ImageSize(16.0, 16.0);
		FSlateBrush TextureDefault(Texture, ImageSize);
		FSlateBrush TextureTinted(Texture, ImageSize, FLinearColor::Red);
		FSlateBrush MaterialDefault(Material, ImageSize);
		FSlateBrush MaterialTinted(Material, ImageSize, FLinearColor::White);
		FSlateBrush NullTexture(Cast<UTexture2D>(nullptr), ImageSize);
		return TextureDefault.ImageSize.X == 16.0 && TextureTinted.ImageSize.Y == 16.0 && MaterialDefault.ImageSize.X == 16.0 && MaterialTinted.ImageSize.Y == 16.0 && NullTexture.ImageSize.X == 16.0;
	}
}
