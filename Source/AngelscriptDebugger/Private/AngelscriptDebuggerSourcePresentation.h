#pragma once

#include "AngelscriptDebuggerViewModels.h"
#include "CoreMinimal.h"
#include "Layout/Visibility.h"
#include "Styling/SlateBrush.h"

namespace AngelscriptDebugger
{
	const FSlateBrush* GetSourceBreakpointGlyphBrush(const FBreakpointView* Breakpoint);
	FText GetSourceBreakpointTooltip(const FBreakpointView* Breakpoint);
	FSlateColor GetSourceLineNumberColor(bool bHasBreakpoint);
	FSlateColor GetSourceLineBackgroundColor(bool bIsExecutionLine, bool bIsSelectedLine);
	EVisibility GetSourceBreakpointGlyphVisibility(bool bHasBreakpoint);
}
