#pragma once

#include "CoreMinimal.h"

#define DEBUG_SERVER_VERSION 2

namespace AngelscriptDebugServer
{
	extern ANGELSCRIPTDEBUGPROTOCOL_API int32 DebugAdapterVersion;
}

enum class EDebugMessageType : uint8
{
	Diagnostics,
	RequestDebugDatabase,
	DebugDatabase,

	StartDebugging,
	StopDebugging,
	Pause,
	Continue,

	RequestCallStack,
	CallStack,

	ClearBreakpoints,
	SetBreakpoint,

	HasStopped,
	HasContinued,

	StepOver,
	StepIn,
	StepOut,

	EngineBreak,

	RequestVariables,
	Variables,

	RequestEvaluate,
	Evaluate,
	GoToDefinition,

	BreakOptions,
	RequestBreakFilters,
	BreakFilters,

	Disconnect,

	DebugDatabaseFinished,
	AssetDatabaseInit,
	AssetDatabase,
	AssetDatabaseFinished,
	FindAssets,
	DebugDatabaseSettings,

	PingAlive,

	DebugServerVersion,
	CreateBlueprint,

	ReplaceAssetDefinition,

	SetDataBreakpoints,
	ClearDataBreakpoints,
};

struct FDebugMessage
{
};

struct FAngelscriptDebugMessageEnvelope
{
	EDebugMessageType MessageType = EDebugMessageType::Disconnect;
	TArray<uint8> Body;
};

ANGELSCRIPTDEBUGPROTOCOL_API bool SerializeDebugMessageEnvelope(EDebugMessageType MessageType, const TArray<uint8>& Body, TArray<uint8>& OutBuffer);
ANGELSCRIPTDEBUGPROTOCOL_API bool TryDeserializeDebugMessageEnvelope(TArray<uint8>& InOutBuffer, FAngelscriptDebugMessageEnvelope& OutEnvelope, bool& bOutHasEnvelope, FString* OutError = nullptr);

struct FEmptyMessage : FDebugMessage
{
	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FEmptyMessage& Msg)
	{
		return Ar;
	}
};

struct FStartDebuggingMessage : FDebugMessage
{
	int32 DebugAdapterVersion = 0;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FStartDebuggingMessage& Msg)
	{
		if (Ar.IsSaving() || !Ar.AtEnd())
		{
			Ar << Msg.DebugAdapterVersion;
		}

		return Ar;
	}
};

struct FDebugServerVersionMessage : FDebugMessage
{
	int32 DebugServerVersion = 0;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FDebugServerVersionMessage& Msg)
	{
		Ar << Msg.DebugServerVersion;
		return Ar;
	}
};

struct FStoppedMessage : FDebugMessage
{
	FString Reason;
	FString Description;
	FString Text;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FStoppedMessage& Msg)
	{
		Ar << Msg.Reason;
		Ar << Msg.Description;
		Ar << Msg.Text;
		return Ar;
	}
};

struct FAngelscriptDiagnostic : FDebugMessage
{
	FString Message;
	int32 Line;
	int32 Character;
	bool bIsError;
	bool bIsInfo;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptDiagnostic& Diagnostic)
	{
		Ar << Diagnostic.Message;
		Ar << Diagnostic.Line;
		Ar << Diagnostic.Character;
		Ar << Diagnostic.bIsError;
		Ar << Diagnostic.bIsInfo;
		return Ar;
	}
};

struct FAngelscriptDiagnostics : FDebugMessage
{
	FString Filename;
	TArray<FAngelscriptDiagnostic> Diagnostics;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptDiagnostics& List)
	{
		Ar << List.Filename;
		Ar << List.Diagnostics;
		return Ar;
	}
};

struct FAngelscriptRequestDebugDatabase : FDebugMessage
{
	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptRequestDebugDatabase& DB)
	{
		return Ar;
	}
};

struct FAngelscriptDebugDatabase : FDebugMessage
{
	FString Database;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptDebugDatabase& DB)
	{
		Ar << DB.Database;
		return Ar;
	}
};

struct FAngelscriptCallFrame : FDebugMessage
{
	FString Name;
	FString Source;
	int32 LineNumber;
	TOptional<FString> ModuleName;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptCallFrame& Frame)
	{
		Ar << Frame.Name;
		Ar << Frame.Source;
		Ar << Frame.LineNumber;

		if (AngelscriptDebugServer::DebugAdapterVersion >= 1)
		{
			FString SerializedModuleName = Frame.ModuleName.IsSet() ? Frame.ModuleName.GetValue() : FString();
			Ar << SerializedModuleName;
			if (Ar.IsLoading())
			{
				Frame.ModuleName = MoveTemp(SerializedModuleName);
			}
		}
		return Ar;
	}
};

struct FAngelscriptCallStack : FDebugMessage
{
	TArray<FAngelscriptCallFrame> Frames;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptCallStack& Stack)
	{
		Ar << Stack.Frames;
		return Ar;
	}
};

struct FAngelscriptBreakpoint : FDebugMessage
{
	FString Filename;
	int32 LineNumber;
	int32 Id = -1;
	FString ModuleName;
	FString Condition;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptBreakpoint& BP)
	{
		Ar << BP.Filename;
		Ar << BP.LineNumber;

		if (Ar.IsSaving() || !Ar.AtEnd())
		{
			Ar << BP.Id;
		}
		else
		{
			BP.Id = -1;
		}

		if (Ar.IsSaving() || !Ar.AtEnd())
		{
			Ar << BP.ModuleName;
		}

		if (Ar.IsSaving() || !Ar.AtEnd())
		{
			Ar << BP.Condition;
		}

		return Ar;
	}
};

struct FAngelscriptClearBreakpoints : FDebugMessage
{
	FString Filename;
	FString ModuleName;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptClearBreakpoints& BP)
	{
		Ar << BP.Filename;

		if (Ar.IsSaving() || !Ar.AtEnd())
		{
			Ar << BP.ModuleName;
		}

		return Ar;
	}
};

struct FAngelscriptClearDataBreakpoints : FDebugMessage
{
	TArray<int32> Ids;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptClearDataBreakpoints& Msg)
	{
		int32 IdCount = Msg.Ids.Num();
		Ar << IdCount;
		if (Ar.IsLoading())
		{
			Msg.Ids.SetNum(IdCount);
		}

		for (int32 Index = 0; Index < IdCount; ++Index)
		{
			Ar << Msg.Ids[Index];
		}

		return Ar;
	}
};

enum class EAngelscriptDataBreakpointStatus
{
	Keep,
	Remove_OutOfScope,
	Remove_ReachedHitCount
};

struct FAngelscriptDataBreakpoint
{
	int32 Id;
	uint64 Address;
	uint8 AddressSize;
	int8 HitCount;
	bool bCppBreakpoint = false;
	FString Name;
	class asCContext* Context = nullptr;
	bool bTriggered = false;
	EAngelscriptDataBreakpointStatus Status = EAngelscriptDataBreakpointStatus::Keep;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptDataBreakpoint& Msg)
	{
		Ar << Msg.Id;
		Ar << Msg.Address;
		Ar << Msg.AddressSize;
		Ar << Msg.HitCount;
		Ar << Msg.bCppBreakpoint;
		Ar << Msg.Name;

		return Ar;
	}
};

struct FAngelscriptActiveDataBreakpoint
{
	int32 Id = -1;
	uint64 Address = 0;
	uint8 AddressSize = 0;
	bool bCppBreakpoint = false;
	TAtomic<int32> HitCount { 0 };
	TAtomic<bool> bTriggered { false };
	TAtomic<int8> Status { static_cast<int8>(EAngelscriptDataBreakpointStatus::Keep) };
	TAtomic<UPTRINT> ContextPtr { 0 };

	void Reset()
	{
		Id = -1;
		Address = 0;
		AddressSize = 0;
		bCppBreakpoint = false;
		HitCount.Store(0);
		bTriggered.Store(false);
		Status.Store(static_cast<int8>(EAngelscriptDataBreakpointStatus::Keep));
		ContextPtr.Store(0);
	}

	EAngelscriptDataBreakpointStatus GetStatus() const
	{
		return static_cast<EAngelscriptDataBreakpointStatus>(Status.Load());
	}

	void SetStatus(EAngelscriptDataBreakpointStatus InStatus)
	{
		Status.Store(static_cast<int8>(InStatus));
	}

	class asCContext* GetContext() const
	{
		return reinterpret_cast<class asCContext*>(ContextPtr.Load());
	}

	void SetContext(class asCContext* InContext)
	{
		ContextPtr.Store(reinterpret_cast<UPTRINT>(InContext));
	}

	void CopyFrom(const FAngelscriptDataBreakpoint& Source)
	{
		Id = Source.Id;
		Address = Source.Address;
		AddressSize = Source.AddressSize;
		bCppBreakpoint = Source.bCppBreakpoint;
		HitCount.Store(Source.HitCount);
		bTriggered.Store(Source.bTriggered);
		SetStatus(Source.Status);
		SetContext(Source.Context);
	}

	void CopyTo(FAngelscriptDataBreakpoint& Destination) const
	{
		Destination.Id = Id;
		Destination.Address = Address;
		Destination.AddressSize = AddressSize;
		Destination.bCppBreakpoint = bCppBreakpoint;
		Destination.HitCount = static_cast<int8>(HitCount.Load());
		Destination.bTriggered = bTriggered.Load();
		Destination.Status = GetStatus();
		Destination.Context = GetContext();
	}
};

struct FAngelscriptDataBreakpoints : FDebugMessage
{
	TArray<FAngelscriptDataBreakpoint> Breakpoints;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptDataBreakpoints& Msg)
	{
		uint8 BreakpointCount = Msg.Breakpoints.Num();
		Ar << BreakpointCount;
		if (Ar.IsLoading())
		{
			Msg.Breakpoints.SetNum(BreakpointCount);
		}

		for (int32 Index = 0; Index < BreakpointCount; ++Index)
		{
			Ar << Msg.Breakpoints[Index];
		}

		return Ar;
	}
};

struct FAngelscriptVariable : FDebugMessage
{
	FString Name;
	FString Value;
	FString Type;
	uint64 ValueAddress = 0;
	uint8 ValueSize = 0;

	bool bHasMembers = false;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptVariable& Msg)
	{
		Ar << Msg.Name;
		Ar << Msg.Value;
		Ar << Msg.Type;
		Ar << Msg.bHasMembers;

		if (AngelscriptDebugServer::DebugAdapterVersion >= 2)
		{
			Ar << Msg.ValueAddress;
			Ar << Msg.ValueSize;
		}
		return Ar;
	}
};

struct FAngelscriptVariables : FDebugMessage
{
	TArray<FAngelscriptVariable> Variables;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptVariables& Msg)
	{
		Ar << Msg.Variables;
		return Ar;
	}
};

struct FAngelscriptGoToDefinition : FDebugMessage
{
	FString TypeName;
	FString SymbolName;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptGoToDefinition& Msg)
	{
		Ar << Msg.TypeName;
		Ar << Msg.SymbolName;
		return Ar;
	}
};

struct FAngelscriptBreakOptions : FDebugMessage
{
	TArray<FString> Filters;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptBreakOptions& Msg)
	{
		int32 FilterCount = Msg.Filters.Num();
		Ar << FilterCount;
		if (Ar.IsLoading())
		{
			Msg.Filters.SetNum(FilterCount);
		}

		for (int32 Index = 0; Index < FilterCount; ++Index)
		{
			Ar << Msg.Filters[Index];
		}
		return Ar;
	}
};

struct FAngelscriptBreakFilters : FDebugMessage
{
	TArray<FString> Filters;
	TArray<FString> FilterTitles;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptBreakFilters& Msg)
	{
		int32 FilterCount = Msg.Filters.Num();
		Ar << FilterCount;
		if (Ar.IsLoading())
		{
			Msg.Filters.SetNum(FilterCount);
			Msg.FilterTitles.SetNum(FilterCount);
		}

		for (int32 Index = 0; Index < FilterCount; ++Index)
		{
			Ar << Msg.Filters[Index];
			Ar << Msg.FilterTitles[Index];
		}
		return Ar;
	}
};

struct FAngelscriptAssetDatabase : FDebugMessage
{
	TArray<FString> Assets;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptAssetDatabase& Msg)
	{
		int32 Version = 1;
		Ar << Version;
		Ar << Msg.Assets;
		return Ar;
	}
};

struct FAngelscriptFindAssets : FDebugMessage
{
	TArray<FString> Assets;
	FString ClassName;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptFindAssets& Msg)
	{
		int32 Version = 1;
		Ar << Version;
		Ar << Msg.Assets;
		if (Ar.IsSaving() || !Ar.AtEnd())
		{
			Ar << Msg.ClassName;
		}
		return Ar;
	}
};

struct FAngelscriptDebugDatabaseSettings : FDebugMessage
{
	bool bAutomaticImports = false;
	bool bFloatIsFloat64 = false;
	bool bUseAngelscriptHaze = false;
	bool bDeprecateStaticClass = false;
	bool bDisallowStaticClass = false;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptDebugDatabaseSettings& Msg)
	{
		int32 Version = 5;
		Ar << Version;
		Ar << Msg.bAutomaticImports;
		Ar << Msg.bFloatIsFloat64;
		Ar << Msg.bUseAngelscriptHaze;
		Ar << Msg.bDeprecateStaticClass;
		Ar << Msg.bDisallowStaticClass;
		return Ar;
	}
};

struct FAngelscriptCreateBlueprint : FDebugMessage
{
	FString ClassName;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptCreateBlueprint& Msg)
	{
		Ar << Msg.ClassName;
		return Ar;
	}
};

struct FAngelscriptReplaceAssetDefinition : FDebugMessage
{
	FString AssetName;
	TArray<FString> Lines;

	FORCEINLINE friend FArchive& operator<<(FArchive& Ar, FAngelscriptReplaceAssetDefinition& Msg)
	{
		Ar << Msg.AssetName;
		Ar << Msg.Lines;
		return Ar;
	}
};
