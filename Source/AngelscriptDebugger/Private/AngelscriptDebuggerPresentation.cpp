#include "AngelscriptDebuggerPresentation.h"

#include "Brushes/SlateRoundedBoxBrush.h"
#include "Misc/Paths.h"

namespace AngelscriptDebugger
{
	FString DescribeSection(const FSectionView& Item)
	{
		return Item.Label;
	}

	FString DescribeFrame(const FDebuggerFrameView& Item)
	{
		return FString::Printf(TEXT("%s  %s:%d"), *Item.Name, *Item.Source, Item.LineNumber);
	}

	FString DescribeBreakpoint(const FBreakpointView& Item)
	{
		const FString Status = Item.bVerified ? TEXT("verified") : TEXT("pending");
		const FString Location = Item.ModuleName.IsEmpty()
			? FString::Printf(TEXT("%s:%d"), *FPaths::GetCleanFilename(Item.Filename), Item.LineNumber)
			: FString::Printf(TEXT("%s:%d"), *Item.ModuleName, Item.LineNumber);
		return FString::Printf(TEXT("%s | %s%s%s"),
			*Status,
			*Location,
			Item.RequestedLineNumber != Item.LineNumber
				? *FString::Printf(TEXT(" | requested %d -> %d"), Item.RequestedLineNumber, Item.LineNumber)
				: TEXT(""),
			Item.Condition.IsEmpty() ? TEXT("") : *FString::Printf(TEXT(" | if %s"), *Item.Condition));
	}

	FString DescribeBreakpointTooltip(const FBreakpointView& Item)
	{
		return FString::Printf(TEXT("%s breakpoint\nFile: %s\nModule: %s\nRequested line: %d\nResolved line: %d%s"),
			Item.bVerified ? TEXT("Verified") : TEXT("Pending"),
			*Item.Filename,
			Item.ModuleName.IsEmpty() ? TEXT("<none>") : *Item.ModuleName,
			Item.RequestedLineNumber,
			Item.LineNumber,
			Item.Condition.IsEmpty() ? TEXT("") : *FString::Printf(TEXT("\nCondition: %s"), *Item.Condition));
	}

	const FSlateBrush* GetBreakpointGlyphBrush(const FBreakpointView& Item)
	{
		static const FSlateRoundedBoxBrush VerifiedBrush(
			FLinearColor(0.94f, 0.07f, 0.09f, 1.0f),
			6.0f,
			FVector2f(12.0f, 12.0f));
		static const FSlateRoundedBoxBrush ConditionalBrush(
			FLinearColor(0.94f, 0.07f, 0.09f, 1.0f),
			2.0f,
			FVector2f(12.0f, 12.0f));
		static const FSlateRoundedBoxBrush PendingBrush(
			FLinearColor::Transparent,
			6.0f,
			FLinearColor(1.0f, 0.42f, 0.16f, 1.0f),
			2.0f,
			FVector2f(12.0f, 12.0f));

		if (!Item.Condition.IsEmpty())
		{
			return &ConditionalBrush;
		}
		return Item.bVerified ? &VerifiedBrush : &PendingBrush;
	}

	FString DescribeDataBreakpoint(const FDataBreakpointView& Item)
	{
		return FString::Printf(TEXT("%s  %d bytes 0x%016llX"),
			*Item.Name,
			Item.ValueSize,
			static_cast<unsigned long long>(Item.Address));
	}

	FString DescribeDiagnostic(const FDiagnosticView& Item)
	{
		return FString::Printf(TEXT("%s  %s:%d:%d  %s"),
			*Item.Severity,
			*FPaths::GetCleanFilename(Item.Filename),
			Item.Line,
			Item.Character,
			*Item.Message);
	}

	FString DescribeVariable(const FVariableNode& Item)
	{
		return FString::Printf(TEXT("%s = %s  [%s]"), *Item.Value.Name, *Item.Value.Value, *Item.Value.Type);
	}

	FString DescribeWatch(const FWatchView& Item)
	{
		return FString::Printf(TEXT("%s = %s  [%s]"), *Item.Expression, *Item.Value, *Item.Type);
	}

	FText GetDebuggerCommandTooltip(const EDebugMessageType MessageType)
	{
		switch (MessageType)
		{
		case EDebugMessageType::Pause:
			return FText::FromString(TEXT("Request a pause on the next AngelScript line callback."));
		case EDebugMessageType::Continue:
			return FText::FromString(TEXT("Resume the paused AngelScript execution context. Shortcut: F5."));
		case EDebugMessageType::StepIn:
			return FText::FromString(TEXT("Step into the next AngelScript call. Shortcut: F11."));
		case EDebugMessageType::StepOver:
			return FText::FromString(TEXT("Step over the current AngelScript line. Shortcut: F10."));
		case EDebugMessageType::StepOut:
			return FText::FromString(TEXT("Run until the current AngelScript frame returns. Shortcut: Shift+F11."));
		case EDebugMessageType::StopDebugging:
			return FText::FromString(TEXT("Detach this debugger session from the connected Unreal process."));
		default:
			return FText::GetEmpty();
		}
	}
}
