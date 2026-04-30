#include "AngelscriptDebuggerSourceViewState.h"

#include "Syntax/AngelscriptSyntaxTokenizer.h"

namespace AngelscriptDebugger
{
	namespace
	{
		TSharedPtr<FSourceLineView> MakeSourceLineView(
			const int32 LineNumber,
			const FString& Text,
			FAngelscriptSyntaxTokenizer::FState& SyntaxState)
		{
			TSharedPtr<FSourceLineView> Line = MakeShared<FSourceLineView>();
			Line->LineNumber = LineNumber;
			Line->Text = Text;
			Line->Tokens = FAngelscriptSyntaxTokenizer::TokenizeLine(Line->Text, SyntaxState);
			return Line;
		}
	}

	FBreakpointView MakeBreakpointView(const AngelscriptDebugClient::FBreakpointEntry& Entry)
	{
		FBreakpointView Item;
		Item.Id = Entry.Id;
		Item.Filename = Entry.Filename;
		Item.ModuleName = Entry.ModuleName;
		Item.LineNumber = Entry.LineNumber;
		Item.RequestedLineNumber = Entry.RequestedLineNumber;
		Item.Condition = Entry.Condition;
		Item.bVerified = Entry.bVerified;
		return Item;
	}

	TArray<TSharedPtr<FSourceLineView>> MakeSourceLineItems(const TArray<FString>& SourceLines)
	{
		TArray<TSharedPtr<FSourceLineView>> Items;
		FAngelscriptSyntaxTokenizer::FState SyntaxState;
		for (int32 Index = 0; Index < SourceLines.Num(); ++Index)
		{
			Items.Add(MakeSourceLineView(Index + 1, SourceLines[Index], SyntaxState));
		}
		return Items;
	}

	TArray<TSharedPtr<FSourceLineView>> MakeSourceLineItemsForMessage(const FString& Message)
	{
		TArray<FString> Lines;
		Lines.Add(Message);
		return MakeSourceLineItems(Lines);
	}

	void ApplySourceBreakpointDecorations(
		TArray<TSharedPtr<FSourceLineView>>& SourceLineItems,
		const FString& CurrentSourcePath,
		const AngelscriptDebugClient::FBreakpointStore& BreakpointStore)
	{
		for (TSharedPtr<FSourceLineView>& Line : SourceLineItems)
		{
			if (!Line.IsValid())
			{
				continue;
			}

			AngelscriptDebugClient::FBreakpointEntry Breakpoint;
			Line->bHasBreakpoint = !CurrentSourcePath.IsEmpty()
				&& BreakpointStore.TryGetBreakpointAtLine(CurrentSourcePath, Line->LineNumber, Breakpoint);
			Line->Breakpoint = Line->bHasBreakpoint ? MakeBreakpointView(Breakpoint) : FBreakpointView();
		}
	}

	bool TryGetSourceLineBreakpoint(
		const TSharedPtr<FSourceLineView>& Item,
		const FString& CurrentSourcePath,
		const AngelscriptDebugClient::FBreakpointStore& BreakpointStore,
		FBreakpointView& OutBreakpoint)
	{
		if (!Item.IsValid())
		{
			return false;
		}

		if (Item->bHasBreakpoint)
		{
			OutBreakpoint = Item->Breakpoint;
			return true;
		}

		AngelscriptDebugClient::FBreakpointEntry Breakpoint;
		if (!CurrentSourcePath.IsEmpty()
			&& BreakpointStore.TryGetBreakpointAtLine(CurrentSourcePath, Item->LineNumber, Breakpoint))
		{
			OutBreakpoint = MakeBreakpointView(Breakpoint);
			return true;
		}

		return false;
	}

	bool IsSourceExecutionLine(
		const TSharedPtr<FSourceLineView>& Item,
		const FString& CurrentSourcePath,
		const FString& ExecutionSourcePath,
		const int32 ExecutionSourceLine)
	{
		return Item.IsValid()
			&& Item->LineNumber == ExecutionSourceLine
			&& AngelscriptDebugClient::NormalizeDebuggerFilename(CurrentSourcePath).Equals(ExecutionSourcePath, ESearchCase::IgnoreCase);
	}

	TSharedPtr<FBreakpointView> FindBreakpointItemById(
		const TArray<TSharedPtr<FBreakpointView>>& BreakpointItems,
		const int32 BreakpointId)
	{
		for (const TSharedPtr<FBreakpointView>& Item : BreakpointItems)
		{
			if (Item.IsValid() && Item->Id == BreakpointId)
			{
				return Item;
			}
		}
		return nullptr;
	}

	bool TryGetBreakpointById(
		const AngelscriptDebugClient::FBreakpointStore& BreakpointStore,
		const int32 BreakpointId,
		AngelscriptDebugClient::FBreakpointEntry& OutBreakpoint)
	{
		for (const AngelscriptDebugClient::FBreakpointEntry& Entry : BreakpointStore.GetBreakpoints())
		{
			if (Entry.Id == BreakpointId)
			{
				OutBreakpoint = Entry;
				return true;
			}
		}
		return false;
	}

	bool TryGetBreakpointForSourceLine(
		const AngelscriptDebugClient::FBreakpointStore& BreakpointStore,
		const FString& CurrentSourcePath,
		const int32 SourceLine,
		AngelscriptDebugClient::FBreakpointEntry& OutBreakpoint)
	{
		return !CurrentSourcePath.IsEmpty()
			&& SourceLine > 0
			&& BreakpointStore.TryGetBreakpointAtLine(CurrentSourcePath, SourceLine, OutBreakpoint);
	}
}
