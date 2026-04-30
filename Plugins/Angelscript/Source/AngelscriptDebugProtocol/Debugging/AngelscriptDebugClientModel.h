#pragma once

#include "CoreMinimal.h"
#include "Debugging/AngelscriptDebugProtocol.h"

namespace AngelscriptDebugClient
{
	enum class EScopeKind : uint8
	{
		Local,
		This,
		Module,
	};

	struct FBreakpointEntry
	{
		int32 Id = -1;
		FString Filename;
		FString ModuleName;
		int32 RequestedLineNumber = 0;
		int32 LineNumber = 0;
		FString Condition;
		bool bVerified = false;
	};

	class ANGELSCRIPTDEBUGPROTOCOL_API FBreakpointStore
	{
	public:
		int32 SetBreakpoint(const FString& Filename, const FString& ModuleName, int32 LineNumber, const FString& Condition);
		void ClearBreakpoints(const FString& Filename, const FString& ModuleName);
		bool RemoveBreakpointById(int32 Id, FBreakpointEntry* OutRemovedBreakpoint = nullptr);
		bool UpdateBreakpointCondition(int32 Id, const FString& Condition, FBreakpointEntry* OutUpdatedBreakpoint = nullptr);
		bool ApplyServerAck(const FAngelscriptBreakpoint& Ack);
		bool HasBreakpointAtLine(const FString& Filename, int32 LineNumber) const;
		bool TryGetBreakpointAtLine(const FString& Filename, int32 LineNumber, FBreakpointEntry& OutBreakpoint) const;
		TArray<FBreakpointEntry> GetBreakpoints() const;

	private:
		int32 NextBreakpointId = 1;
		TArray<FBreakpointEntry> Breakpoints;
	};

	ANGELSCRIPTDEBUGPROTOCOL_API FString NormalizeDebuggerFilename(const FString& Filename);
	ANGELSCRIPTDEBUGPROTOCOL_API FString CombineDebuggerPath(const FString& ParentPath, const FString& ChildName);
	ANGELSCRIPTDEBUGPROTOCOL_API FString MakeScopePath(int32 FrameIndex, EScopeKind ScopeKind);
	ANGELSCRIPTDEBUGPROTOCOL_API FString MakeModuleNameFromScriptPath(const FString& Filename, const TArray<FString>& ScriptRoots);
	ANGELSCRIPTDEBUGPROTOCOL_API FString ResolveSourcePath(const FString& SourcePath, const FString& ModuleName, const TArray<FString>& ScriptRoots);
}
