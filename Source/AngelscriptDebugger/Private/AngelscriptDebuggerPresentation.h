#pragma once

#include "AngelscriptDebuggerViewModels.h"
#include "CoreMinimal.h"
#include "Styling/SlateBrush.h"

namespace AngelscriptDebugger
{
	FString DescribeSection(const FSectionView& Item);
	FString DescribeFrame(const FDebuggerFrameView& Item);
	FString DescribeBreakpoint(const FBreakpointView& Item);
	FString DescribeBreakpointTooltip(const FBreakpointView& Item);
	const FSlateBrush* GetBreakpointGlyphBrush(const FBreakpointView& Item);
	FString DescribeDataBreakpoint(const FDataBreakpointView& Item);
	FString DescribeDiagnostic(const FDiagnosticView& Item);
	FString DescribeVariable(const FVariableNode& Item);
	FString DescribeWatch(const FWatchView& Item);
	FText GetDebuggerCommandTooltip(EDebugMessageType MessageType);
}
