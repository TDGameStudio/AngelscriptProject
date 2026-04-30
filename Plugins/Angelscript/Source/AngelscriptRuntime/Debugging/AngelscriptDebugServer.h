#pragma once

#include "CoreMinimal.h"
#include "Containers/Queue.h"
#include "Sockets.h"

#include "AngelscriptType.h"
#include "Debugging/AngelscriptDebugProtocol.h"

struct FAngelscriptEngine;
#include "Common/TcpListener.h"
#include "Common/UdpSocketReceiver.h"
#include "Serialization/MemoryWriter.h"
#include "Serialization/MemoryReader.h"

// Intended to be called from the debugger Immediate window, to exit a softlock due to a spamming data breakpoint
ANGELSCRIPTRUNTIME_API void ClearAllAngelscriptDataBreakpointsFromHandler();

class ANGELSCRIPTRUNTIME_API FAngelscriptDebugServer
{
	FAngelscriptEngine* OwnerEngine;
	class FTcpListener* Listener;
	TQueue<class FSocket*, EQueueMode::Mpsc> PendingClients;
	TArray<class FSocket*> Clients;
	TArray<class FSocket*> ClientsThatWantDebugDatabase;
	TArray<class FSocket*> ClientsThatAreDebugging;
	double NextPingDebuggerAliveTime = 0.0;

	bool HandleConnectionAccepted(class FSocket* ClientSocket, const FIPv4Endpoint& ClientEndpoint);
	void RemoveClientState(class FSocket* Client, bool bResetDebugStateIfLastDebuggingClient);
	void CloseAndDestroyClient(class FSocket*& Client);
	void ResetClientStateForShutdown();

public:
	FAngelscriptEngine* GetOwnerEngine() const { return OwnerEngine; }

public:
	TAtomic<bool> bBreakNextScriptLine { false };
	bool bPauseRequested = false;
	bool bIsPaused = false;
	bool bIsEvaluatingDebuggerWatch = false;
	bool bIsDebugging = false;
	int32 PokeSocketCounter = 0;

	TArray<FName> BreakOptions;
	bool ShouldBreakOnActiveSide();

	bool HasAnyClients() const
	{
		return Clients.Num() != 0;
	}

	void ProcessScriptLine(class asCContext* Context);
	void ProcessScriptStackPop(class asCContext* Context, void* OldStackFrameStart, void* OldStackFrameEnd);
	void ProcessException(class asIScriptContext* Context);
	void PauseExecution(FStoppedMessage* StopMessage = nullptr);
	void SleepForCommunicate(float Duration);
	void ReapplyBreakpoints();

	// Maximum seconds PauseExecution will block before auto-resuming.
	// 0 = unlimited (production default). Set by test infrastructure to
	// prevent indefinite hangs in headless automation environments.
	float MaxPauseTimeoutSeconds = 0.0f;


public:


	/*
		Debugger paths are formatted as:

		{Frame}:Variable.Member.Member

		Example:

		0:Owner.Name
	*/

	bool GetDebuggerValue(const FString& Path, FDebuggerValue& Value, int32* InOutFrame = nullptr, TArray<FDebuggerValue>* OutInnerValues = nullptr);
	bool GetDebuggerScope(const FString& Path, FDebuggerScope& Scope);

	int ResolveDebuggerFrame(int DebuggerFrame);

	void GoToDefinition(const FAngelscriptGoToDefinition GoTo);

public:
	FAngelscriptDebugServer(FAngelscriptEngine* InOwnerEngine, int Port);
	~FAngelscriptDebugServer();

	void Tick();
	void ProcessMessages();

	void HandleMessage(EDebugMessageType MessageType, FArrayReaderPtr Datagram, class FSocket* Client);

	template<typename T>
	void SendMessageToAll(EDebugMessageType MessageType, T& Message)
	{
		TArray<uint8> Body;
		FMemoryWriter BodyWriter(Body);
		BodyWriter << Message;

		TArray<uint8> Buffer;
		if (!SerializeDebugMessageEnvelope(MessageType, Body, Buffer))
		{
			return;
		}

		for (auto* Client : Clients)
		{
			FQueuedMessage& Msg = QueuedSends.FindOrAdd(Client).Emplace_GetRef();
			Msg.Buffer = Buffer;

			TrySendingMessages(Client);
		}
	}

	template<typename T>
	void SendMessageToClient(FSocket* Client, EDebugMessageType MessageType, T& Message)
	{
		TArray<uint8> Body;
		FMemoryWriter BodyWriter(Body);
		BodyWriter << Message;

		TArray<uint8> Buffer;
		if (!SerializeDebugMessageEnvelope(MessageType, Body, Buffer))
		{
			return;
		}

		FQueuedMessage& Msg = QueuedSends.FindOrAdd(Client).Emplace_GetRef();
		Msg.Buffer = MoveTemp(Buffer);

		TrySendingMessages(Client);
	}

	/** Sends the debug database to all clients in ClientsThatWantDebugDatabase */
	void BroadcastDebugDatabase();
	void SendDebugDatabase(FSocket* Client);
	void SendAssetDatabase(FSocket* Client);
	void SendCallStack(FSocket* Client);

	struct FFileBreakpoints
	{
		TSharedPtr<struct FAngelscriptModuleDesc> Module;
		TSet<int32> Lines;
		TMap<int32, FString> Conditions;
	};

	FString CanonizeFilename(const FString& Filename);

	struct FQueuedMessage
	{
		TArray<uint8> Buffer;
		double FirstTry = -1.0;
	};

	TMap<FSocket*, TArray<FQueuedMessage>> QueuedSends;

	void TrySendingMessages(FSocket* Client);

	static constexpr int DATA_BREAKPOINT_HARDWARE_LIMIT = 4;
	TArray<FAngelscriptDataBreakpoint> DataBreakpoints;
	FAngelscriptActiveDataBreakpoint ActiveDataBreakpoints[DATA_BREAKPOINT_HARDWARE_LIMIT];
	TAtomic<int32> ActiveDataBreakpointCount { 0 };

	int32 BreakpointCount = 0;
	TMap<FString, TSharedPtr<FFileBreakpoints>> Breakpoints;
	TMap<const char*, TSharedPtr<FFileBreakpoints>> SectionBreakpoints;
	TArray<FSocket*> CallstackRequests;

	void ClearAllBreakpoints();
	void ClearAllDataBreakpoints();
	void UpdateDataBreakpoints();
	void RebuildActiveDataBreakpoints();
	void SyncActiveDataBreakpointsToAuthoritativeState();

	const char* IgnoreBreakSection = nullptr;
	int32 IgnoreBreakLine = -1;

	class asIScriptFunction* ConditionBreakFunction = nullptr;
	int32 ConditionBreakFrame = -1;

	TArray<void*> StackFrameThis;

	bool bAssetRegistryBound = false;
	TArray<FDelegateHandle> AssetRegistryDelegateHandles;
	void BindAssetRegistry();
	void UnbindAssetRegistry();
};
