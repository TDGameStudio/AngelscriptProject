/**
 * @version v1
 * @summary Observe solid DrawBox, line/text paint helpers, and implicit FSlateColor / named or solid FSlateBrush constructors.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe solid DrawBox, line/text paint helpers, and implicit FSlateColor / named or solid FSlateBrush constructors.
 * @topic Baseline
 */
// void FPaintContext.DrawLine(const FVector2D& PositionA, const FVector2D& PositionB, const FLinearColor& Color, float32 Thickness = 1.f, bool bAntiAlias = true);
// void FPaintContext.DrawLines(const TArray<FVector2D>& Points, const FLinearColor& Color, float32 Thickness = 1.f, bool bAntiAlias = true);
// void FPaintContext.DrawText(const FString& Text, const FVector2D& Position, const FLinearColor& Color);
// void FPaintContext.DrawText(const FSlateFontInfo& Font, const FString& Text, const FVector2D& Position, const FLinearColor& Color);
// FSlateColor Color(const FLinearColor& InColor); FSlateColor Color(const FColor& InColor);
// FSlateColor Color(EStyleColor InColorTableId);
// FSlateBrush Brush(const FName& BrushStyleName); FSlateBrush Brush(const FLinearColor& Color);
// Inputs: Default FPaintContext, box at (0,0) size (10,20) in White and
// Transparent, line (0,0)-(10,20) with default thickness/antialias and explicit
// 2.0/false, empty and two-point line strips, text "TestSource" and "", font
// from GetStyleFont(12), FLinearColor::White, FColor::White, EStyleColor::Foreground,
// n"WhiteBrush", and FLinearColor::Red as a solid brush.
// Expected observations: Allotted geometry stays non-negative. Named WhiteBrush
// and solid-color brushes report non-negative ImageSize. Font size 12 is
// preserved. Two-point strips keep Num 2.
// Boundary/ownership: Draw helpers mutate paint layers, not geometry. Implicit
// color/brush constructors copy style data. DefaultSafe; FPaintContext is a
// value type.

namespace TS_UUserWidget_Behavior_01
{
	bool Observe_DrawBox_Nominal()
	{
		FPaintContext PaintContext;
		FVector2D Position;
		FVector2D Size(10.0, 20.0);
		PaintContext.DrawBox(Position, Size, FLinearColor::White);
		PaintContext.DrawBox(Position, Size, FLinearColor::Transparent);
		FVector2D Local = PaintContext.GetAllottedGeometry().GetLocalSize();
		return Local.X >= 0.0 && Local.Y >= 0.0;
	}

	bool Observe_DrawLine_Nominal()
	{
		FPaintContext PaintContext;
		FVector2D Start;
		FVector2D End(10.0, 20.0);
		PaintContext.DrawLine(Start, End, FLinearColor::White);
		PaintContext.DrawLine(Start, End, FLinearColor::White, 1.0);
		PaintContext.DrawLine(Start, End, FLinearColor::Red, 2.0, false);
		FVector2D Local = PaintContext.GetAllottedGeometry().GetLocalSize();
		return Local.X >= 0.0 && Local.Y >= 0.0;
	}

	bool Observe_DrawLines_Nominal()
	{
		FPaintContext PaintContext;
		TArray<FVector2D> EmptyPoints;
		PaintContext.DrawLines(EmptyPoints, FLinearColor::White);
		TArray<FVector2D> Points;
		Points.Add(FVector2D(0.0, 0.0));
		Points.Add(FVector2D(10.0, 20.0));
		PaintContext.DrawLines(Points, FLinearColor::White);
		PaintContext.DrawLines(Points, FLinearColor::Red, 2.0, false);
		FVector2D Local = PaintContext.GetAllottedGeometry().GetLocalSize();
		return Local.X >= 0.0 && Points.Num() == 2 && EmptyPoints.Num() == 0;
	}

	bool Observe_DrawText_Nominal()
	{
		FPaintContext PaintContext;
		FVector2D Position;
		PaintContext.DrawText("TestSource", Position, FLinearColor::White);
		PaintContext.DrawText("", Position, FLinearColor::White);
		FSlateFontInfo Font = PaintContext.GetStyleFont(12);
		PaintContext.DrawText(Font, "TestSource", Position, FLinearColor::White);
		PaintContext.DrawText(Font, "", Position, FLinearColor::Red);
		FVector2D Local = PaintContext.GetAllottedGeometry().GetLocalSize();
		return Local.X >= 0.0 && Font.Size == 12;
	}

	bool Observe_Color_Nominal()
	{
		FSlateColor Linear(FLinearColor::White);
		FSlateColor ByteColor(FColor::White);
		FSlateColor TableColor(EStyleColor::Foreground);
		FSlateColor EmptyLinear(FLinearColor::Transparent);
		FSlateBrush FromWhite(FLinearColor::White);
		FSlateBrush FromTransparent(FLinearColor::Transparent);
		return FromWhite.ImageSize.X >= 0.0 && FromTransparent.ImageSize.X >= 0.0 && FromWhite.ImageSize.Y >= 0.0;
	}

	bool Observe_Brush_Nominal()
	{
		FSlateBrush Named(n"WhiteBrush");
		FSlateBrush Missing(n"TestSource.MissingBrush");
		FSlateBrush Solid(FLinearColor::Red);
		FSlateBrush EmptyName(NAME_None);
		return Named.ImageSize.X >= 0.0 && Missing.ImageSize.X >= 0.0 && Solid.ImageSize.X >= 0.0 && EmptyName.ImageSize.X >= 0.0;
	}
}
/** @end */
