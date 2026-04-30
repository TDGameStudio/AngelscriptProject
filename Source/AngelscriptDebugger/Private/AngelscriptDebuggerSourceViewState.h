#pragma once

#include "AngelscriptDebuggerViewModels.h"
#include "CoreMinimal.h"
#include "Debugging/AngelscriptDebugClientModel.h"
#include "Templates/SharedPointer.h"

namespace AngelscriptDebugger
{
	FBreakpointView MakeBreakpointView(const AngelscriptDebugClient::FBreakpointEntry& Entry);

	TArray<TSharedPtr<FSourceLineView>> MakeSourceLineItems(const TArray<FString>& SourceLines);
	TArray<TSharedPtr<FSourceLineView>> MakeSourceLineItemsForMessage(const FString& Message);

	void ApplySourceBreakpointDecorations(
		TArray<TSharedPtr<FSourceLineView>>& SourceLineItems,
		const FString& CurrentSourcePath,
		const AngelscriptDebugClient::FBreakpointStore& BreakpointStore);

	bool TryGetSourceLineBreakpoint(
		const TSharedPtr<FSourceLineView>& Item,
		const FString& CurrentSourcePath,
		const AngelscriptDebugClient::FBreakpointStore& BreakpointStore,
		FBreakpointView& OutBreakpoint);

	bool IsSourceExecutionLine(
		const TSharedPtr<FSourceLineView>& Item,
		const FString& CurrentSourcePath,
		const FString& ExecutionSourcePath,
		int32 ExecutionSourceLine);

	TSharedPtr<FBreakpointView> FindBreakpointItemById(
		const TArray<TSharedPtr<FBreakpointView>>& BreakpointItems,
		int32 BreakpointId);

	bool TryGetBreakpointById(
		const AngelscriptDebugClient::FBreakpointStore& BreakpointStore,
		int32 BreakpointId,
		AngelscriptDebugClient::FBreakpointEntry& OutBreakpoint);

	bool TryGetBreakpointForSourceLine(
		const AngelscriptDebugClient::FBreakpointStore& BreakpointStore,
		const FString& CurrentSourcePath,
		int32 SourceLine,
		AngelscriptDebugClient::FBreakpointEntry& OutBreakpoint);
}
