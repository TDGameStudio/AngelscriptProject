#pragma once

#include "CoreMinimal.h"
#include "Debugging/AngelscriptDebugProtocol.h"
#include "Syntax/AngelscriptSyntaxTokenizer.h"

namespace AngelscriptDebugger
{
	constexpr int32 DebugAdapterVersion = 2;
	constexpr int32 MaxSessionLogLines = 300;
	constexpr int32 MaxDataBreakpoints = 4;

	enum class EDebuggerConnectionState : uint8
	{
		Disconnected,
		Connecting,
		Connected,
	};

	enum class EDebuggerEventType : uint8
	{
		Log,
		Connected,
		Closed,
		Stopped,
		Continued,
		CallStack,
		Variables,
		Evaluate,
		BreakFilters,
		BreakpointAck,
		ClearDataBreakpoints,
		DebugDatabase,
		AssetDatabase,
		Diagnostics,
		DebugServerVersion,
	};

	struct FDebuggerFrameView
	{
		FString Name;
		FString Source;
		FString ModuleName;
		int32 LineNumber = 0;
	};

	struct FDebuggerVariableView
	{
		FString Name;
		FString Value;
		FString Type;
		FString Path;
		uint64 ValueAddress = 0;
		uint8 ValueSize = 0;
		bool bHasMembers = false;
	};

	struct FDiagnosticView
	{
		FString Filename;
		FString Message;
		FString Severity;
		int32 Line = 0;
		int32 Character = 0;
		bool bIsError = false;
		bool bIsInfo = false;
	};

	struct FDebuggerClientEvent
	{
		EDebuggerEventType Type = EDebuggerEventType::Log;
		FString Summary;
		FString Path;
		FString Expression;
		FString StopReason;
		FString StopText;
		TArray<FDebuggerFrameView> Frames;
		TArray<FDebuggerVariableView> Variables;
		TArray<FDiagnosticView> Diagnostics;
		TArray<FString> Lines;
		FAngelscriptBreakpoint BreakpointAck;
		FAngelscriptClearDataBreakpoints ClearDataBreakpoints;
		FAngelscriptDebugDatabaseSettings DebugSettings;
		int32 DebugServerVersion = 0;
	};

	struct FBreakpointView
	{
		int32 Id = -1;
		FString Filename;
		FString ModuleName;
		int32 LineNumber = 0;
		int32 RequestedLineNumber = 0;
		FString Condition;
		bool bVerified = false;
	};

	struct FSourceLineView
	{
		int32 LineNumber = 0;
		FString Text;
		TArray<FAngelscriptSyntaxToken> Tokens;
		FBreakpointView Breakpoint;
		bool bHasBreakpoint = false;
	};

	struct FSectionView
	{
		FString Label;
		FString Filename;
	};

	struct FBreakFilterView
	{
		FString Filter;
		FString Title;
		bool bEnabled = true;
	};

	struct FDataBreakpointView
	{
		int32 Id = -1;
		FString Name;
		uint64 Address = 0;
		uint8 ValueSize = 0;
		int8 HitCount = 1;
		bool bCppBreakpoint = false;
	};

	struct FVariableNode : public TSharedFromThis<FVariableNode>
	{
		FDebuggerVariableView Value;
		TArray<TSharedPtr<FVariableNode>> Children;
		bool bChildrenRequested = false;
		bool bIsScopeRoot = false;
	};

	struct FWatchView
	{
		FString Expression;
		FString RequestExpression;
		FString Value;
		FString Type;
		FString Path;
		bool bHasMembers = false;
	};
}
