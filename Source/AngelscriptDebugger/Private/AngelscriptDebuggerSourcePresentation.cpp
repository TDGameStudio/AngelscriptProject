#include "AngelscriptDebuggerSourcePresentation.h"

#include "AngelscriptDebuggerPresentation.h"
#include "Styling/CoreStyle.h"

namespace AngelscriptDebugger
{
	const FSlateBrush* GetSourceBreakpointGlyphBrush(const FBreakpointView* Breakpoint)
	{
		return Breakpoint != nullptr
			? GetBreakpointGlyphBrush(*Breakpoint)
			: FCoreStyle::Get().GetBrush("NoBrush");
	}

	FText GetSourceBreakpointTooltip(const FBreakpointView* Breakpoint)
	{
		return Breakpoint != nullptr
			? FText::FromString(DescribeBreakpointTooltip(*Breakpoint))
			: FText::FromString(TEXT("Toggle breakpoint"));
	}

	FSlateColor GetSourceLineNumberColor(const bool bHasBreakpoint)
	{
		return bHasBreakpoint
			? FSlateColor(FLinearColor(0.95f, 0.95f, 0.95f, 1.0f))
			: FSlateColor(FLinearColor(0.58f, 0.62f, 0.66f, 1.0f));
	}

	FSlateColor GetSourceLineBackgroundColor(const bool bIsExecutionLine, const bool bIsSelectedLine)
	{
		if (bIsExecutionLine)
		{
			return FSlateColor(FLinearColor(0.20f, 0.17f, 0.02f, 1.0f));
		}

		return bIsSelectedLine
			? FSlateColor(FLinearColor(0.06f, 0.08f, 0.11f, 1.0f))
			: FSlateColor(FLinearColor::Transparent);
	}

	EVisibility GetSourceBreakpointGlyphVisibility(const bool bHasBreakpoint)
	{
		return bHasBreakpoint ? EVisibility::HitTestInvisible : EVisibility::Hidden;
	}
}
