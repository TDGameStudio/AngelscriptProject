#include "AngelscriptDebuggerClient.h"

#include "Debugging/AngelscriptDebugClientModel.h"
#include "Interfaces/IPv4/IPv4Address.h"
#include "IPAddress.h"
#include "Serialization/MemoryReader.h"
#include "Serialization/MemoryWriter.h"
#include "SocketSubsystem.h"
#include "Sockets.h"

namespace AngelscriptDebugger
{
namespace
{
	const TCHAR* DebugMessageTypeToString(const EDebugMessageType MessageType)
	{
		switch (MessageType)
		{
		case EDebugMessageType::Diagnostics: return TEXT("Diagnostics");
		case EDebugMessageType::DebugDatabase: return TEXT("DebugDatabase");
		case EDebugMessageType::CallStack: return TEXT("CallStack");
		case EDebugMessageType::SetBreakpoint: return TEXT("SetBreakpoint");
		case EDebugMessageType::HasStopped: return TEXT("HasStopped");
		case EDebugMessageType::HasContinued: return TEXT("HasContinued");
		case EDebugMessageType::Variables: return TEXT("Variables");
		case EDebugMessageType::Evaluate: return TEXT("Evaluate");
		case EDebugMessageType::BreakFilters: return TEXT("BreakFilters");
		case EDebugMessageType::ClearDataBreakpoints: return TEXT("ClearDataBreakpoints");
		case EDebugMessageType::DebugDatabaseFinished: return TEXT("DebugDatabaseFinished");
		case EDebugMessageType::AssetDatabaseInit: return TEXT("AssetDatabaseInit");
		case EDebugMessageType::AssetDatabase: return TEXT("AssetDatabase");
		case EDebugMessageType::AssetDatabaseFinished: return TEXT("AssetDatabaseFinished");
		case EDebugMessageType::DebugDatabaseSettings: return TEXT("DebugDatabaseSettings");
		case EDebugMessageType::PingAlive: return TEXT("PingAlive");
		case EDebugMessageType::DebugServerVersion: return TEXT("DebugServerVersion");
		default: return TEXT("DebuggerMessage");
		}
	}

	bool ParseHostAddress(const FString& Host, FIPv4Address& OutAddress)
	{
		if (Host.Equals(TEXT("localhost"), ESearchCase::IgnoreCase))
		{
			OutAddress = FIPv4Address(127, 0, 0, 1);
			return true;
		}
		return FIPv4Address::Parse(Host, OutAddress);
	}

	template <typename T>
	TOptional<T> DeserializeDebuggerMessage(const FAngelscriptDebugMessageEnvelope& Envelope)
	{
		T Message;
		TArray<uint8> Body = Envelope.Body;
		FMemoryReader Reader(Body);
		Reader << Message;
		if (Reader.IsError())
		{
			return {};
		}
		return Message;
	}
}

	class FClient::FImpl
	{
	public:
		~FImpl()
		{
			Disconnect();
		}

		bool Connect(const FString& InHost, const int32 InPort)
		{
			Disconnect();

			FIPv4Address Address;
			if (!ParseHostAddress(InHost, Address))
			{
				AddLog(FString::Printf(TEXT("Invalid host: %s"), *InHost));
				return false;
			}

			SocketSubsystem = ISocketSubsystem::Get(PLATFORM_SOCKETSUBSYSTEM);
			if (SocketSubsystem == nullptr)
			{
				AddLog(TEXT("Socket subsystem is unavailable."));
				return false;
			}

			Socket = SocketSubsystem->CreateSocket(NAME_Stream, TEXT("AngelscriptDebuggerClient"), false);
			if (Socket == nullptr)
			{
				AddLog(TEXT("Failed to create debugger socket."));
				return false;
			}

			Host = InHost;
			Port = InPort;
			Socket->SetNonBlocking(true);
			Socket->SetNoDelay(true);

			const TSharedRef<FInternetAddr> InternetAddr = SocketSubsystem->CreateInternetAddr();
			InternetAddr->SetIp(Address.Value);
			InternetAddr->SetPort(Port);

			const bool bConnectedImmediately = Socket->Connect(*InternetAddr);
			const ESocketErrors ErrorCode = SocketSubsystem->GetLastErrorCode();
			if (!bConnectedImmediately && ErrorCode != SE_NO_ERROR && ErrorCode != SE_EWOULDBLOCK && ErrorCode != SE_EINPROGRESS)
			{
				AddLog(FString::Printf(TEXT("Connect failed to %s:%d (socket error %d)."), *Host, Port, static_cast<int32>(ErrorCode)));
				Disconnect();
				return false;
			}

			ConnectionState = bConnectedImmediately ? EDebuggerConnectionState::Connected : EDebuggerConnectionState::Connecting;
			AddLog(FString::Printf(TEXT("Connecting to %s:%d"), *Host, Port));
			if (bConnectedImmediately)
			{
				OnConnected();
			}
			return true;
		}

		void Disconnect()
		{
			if (Socket != nullptr)
			{
				Socket->Close();
				if (SocketSubsystem != nullptr)
				{
					SocketSubsystem->DestroySocket(Socket);
				}
			}

			Socket = nullptr;
			SocketSubsystem = nullptr;
			ConnectionState = EDebuggerConnectionState::Disconnected;
			ReceiveBuffer.Reset();
			PendingSendBuffer.Reset();
			PendingSendOffset = 0;
			PendingVariablePaths.Reset();
			PendingEvaluateExpressions.Reset();
			PendingEvents.Reset();
			bSentStartDebugging = false;
		}

		void Tick()
		{
			if (Socket == nullptr)
			{
				return;
			}

			if (ConnectionState == EDebuggerConnectionState::Connecting)
			{
				const ESocketConnectionState SocketState = Socket->GetConnectionState();
				if (SocketState == ESocketConnectionState::SCS_Connected)
				{
					ConnectionState = EDebuggerConnectionState::Connected;
					OnConnected();
				}
				else if (SocketState == ESocketConnectionState::SCS_ConnectionError)
				{
					AddLog(FString::Printf(TEXT("Connection failed to %s:%d."), *Host, Port));
					Disconnect();
					AddEvent(EDebuggerEventType::Closed, TEXT("Connection closed."));
					return;
				}
			}

			FlushPendingSend();
			ReceivePendingData();
		}

		bool IsConnected() const
		{
			return ConnectionState == EDebuggerConnectionState::Connected;
		}

		FText GetStatusText() const
		{
			switch (ConnectionState)
			{
			case EDebuggerConnectionState::Connecting:
				return FText::FromString(FString::Printf(TEXT("Connecting to %s:%d"), *Host, Port));
			case EDebuggerConnectionState::Connected:
				return FText::FromString(FString::Printf(TEXT("Connected to %s:%d"), *Host, Port));
			default:
				return FText::FromString(TEXT("Disconnected"));
			}
		}

		TArray<FDebuggerClientEvent> DrainEvents()
		{
			TArray<FDebuggerClientEvent> Result = MoveTemp(PendingEvents);
			PendingEvents.Reset();
			return Result;
		}

		void SendEmpty(const EDebugMessageType MessageType)
		{
			FEmptyMessage Message;
			SendTyped(MessageType, Message);
		}

		void SendRequestVariables(const FString& ScopePath)
		{
			FString Message = ScopePath;
			PendingVariablePaths.Add(ScopePath);
			SendTyped(EDebugMessageType::RequestVariables, Message);
		}

		void SendRequestEvaluate(const FString& Path, const int32 DefaultFrame)
		{
			TArray<uint8> Body;
			FMemoryWriter Writer(Body);
			FString MessagePath = Path;
			Writer << MessagePath;
			int32 MessageFrame = DefaultFrame;
			Writer << MessageFrame;
			PendingEvaluateExpressions.Add(Path);
			SendRaw(EDebugMessageType::RequestEvaluate, Body);
		}

		void SendSetBreakpoint(const int32 Id, const FString& Filename, const FString& ModuleName, const int32 LineNumber, const FString& Condition)
		{
			FAngelscriptBreakpoint Breakpoint;
			Breakpoint.Id = Id;
			Breakpoint.Filename = Filename;
			Breakpoint.ModuleName = ModuleName;
			Breakpoint.LineNumber = LineNumber;
			Breakpoint.Condition = Condition;
			SendTyped(EDebugMessageType::SetBreakpoint, Breakpoint);
		}

		void SendClearBreakpoints(const FString& Filename, const FString& ModuleName)
		{
			FAngelscriptClearBreakpoints Breakpoints;
			Breakpoints.Filename = Filename;
			Breakpoints.ModuleName = ModuleName;
			SendTyped(EDebugMessageType::ClearBreakpoints, Breakpoints);
		}

		void SendBreakOptions(const TArray<FString>& Filters)
		{
			FAngelscriptBreakOptions Options;
			Options.Filters = Filters;
			SendTyped(EDebugMessageType::BreakOptions, Options);
		}

		void SendSetDataBreakpoints(const TArray<FDataBreakpointView>& Breakpoints)
		{
			FAngelscriptDataBreakpoints Message;
			for (const FDataBreakpointView& Entry : Breakpoints)
			{
				FAngelscriptDataBreakpoint Breakpoint;
				Breakpoint.Id = Entry.Id;
				Breakpoint.Address = Entry.Address;
				Breakpoint.AddressSize = Entry.ValueSize;
				Breakpoint.HitCount = Entry.HitCount;
				Breakpoint.bCppBreakpoint = Entry.bCppBreakpoint;
				Breakpoint.Name = Entry.Name;
				Message.Breakpoints.Add(Breakpoint);
			}
			SendTyped(EDebugMessageType::SetDataBreakpoints, Message);
		}

	private:
		template <typename T>
		void SendTyped(const EDebugMessageType MessageType, T& Message)
		{
			TArray<uint8> Body;
			FMemoryWriter Writer(Body);
			Writer << Message;
			SendRaw(MessageType, Body);
		}

		void SendRaw(const EDebugMessageType MessageType, const TArray<uint8>& Body)
		{
			if (ConnectionState != EDebuggerConnectionState::Connected)
			{
				AddLog(TEXT("Cannot send debugger message while disconnected."));
				return;
			}

			TArray<uint8> Buffer;
			if (!SerializeDebugMessageEnvelope(MessageType, Body, Buffer))
			{
				AddLog(FString::Printf(TEXT("Failed to serialize message %s."), DebugMessageTypeToString(MessageType)));
				return;
			}
			PendingSendBuffer.Append(Buffer);
		}

		void OnConnected()
		{
			AddEvent(EDebuggerEventType::Connected, FString::Printf(TEXT("Connected to %s:%d"), *Host, Port));

			FStartDebuggingMessage Message;
			Message.DebugAdapterVersion = DebugAdapterVersion;
			SendTyped(EDebugMessageType::StartDebugging, Message);
			SendEmpty(EDebugMessageType::RequestBreakFilters);
			SendEmpty(EDebugMessageType::RequestDebugDatabase);
			bSentStartDebugging = true;
		}

		void FlushPendingSend()
		{
			if (Socket == nullptr || PendingSendBuffer.Num() == 0)
			{
				return;
			}

			while (PendingSendOffset < PendingSendBuffer.Num())
			{
				int32 BytesSent = 0;
				if (!Socket->Send(PendingSendBuffer.GetData() + PendingSendOffset, PendingSendBuffer.Num() - PendingSendOffset, BytesSent) || BytesSent <= 0)
				{
					break;
				}
				PendingSendOffset += BytesSent;
			}

			if (PendingSendOffset >= PendingSendBuffer.Num())
			{
				PendingSendBuffer.Reset();
				PendingSendOffset = 0;
			}
		}

		void ReceivePendingData()
		{
			if (Socket == nullptr)
			{
				return;
			}

			uint32 PendingDataSize = 0;
			while (Socket->HasPendingData(PendingDataSize) && PendingDataSize > 0)
			{
				TArray<uint8> Chunk;
				Chunk.SetNumUninitialized(static_cast<int32>(PendingDataSize));
				int32 BytesRead = 0;
				if (!Socket->Recv(Chunk.GetData(), Chunk.Num(), BytesRead))
				{
					AddLog(TEXT("Failed receiving debugger bytes."));
					return;
				}
				if (BytesRead <= 0)
				{
					return;
				}
				Chunk.SetNum(BytesRead, EAllowShrinking::No);
				ReceiveBuffer.Append(Chunk);
			}

			while (true)
			{
				FAngelscriptDebugMessageEnvelope Envelope;
				bool bHasEnvelope = false;
				FString Error;
				if (!TryDeserializeDebugMessageEnvelope(ReceiveBuffer, Envelope, bHasEnvelope, &Error))
				{
					AddLog(Error);
					Disconnect();
					AddEvent(EDebuggerEventType::Closed, TEXT("Connection closed."));
					return;
				}
				if (!bHasEnvelope)
				{
					break;
				}
				HandleEnvelope(Envelope);
			}
		}

		void HandleEnvelope(const FAngelscriptDebugMessageEnvelope& Envelope)
		{
			switch (Envelope.MessageType)
			{
			case EDebugMessageType::DebugServerVersion:
				HandleDebugServerVersion(Envelope);
				break;
			case EDebugMessageType::HasStopped:
				HandleStopped(Envelope);
				break;
			case EDebugMessageType::HasContinued:
				AddEvent(EDebuggerEventType::Continued, TEXT("Continued."));
				break;
			case EDebugMessageType::CallStack:
				HandleCallStack(Envelope);
				break;
			case EDebugMessageType::Variables:
				HandleVariables(Envelope);
				break;
			case EDebugMessageType::Evaluate:
				HandleEvaluate(Envelope);
				break;
			case EDebugMessageType::BreakFilters:
				HandleBreakFilters(Envelope);
				break;
			case EDebugMessageType::SetBreakpoint:
				HandleSetBreakpointAck(Envelope);
				break;
			case EDebugMessageType::ClearDataBreakpoints:
				HandleClearDataBreakpoints(Envelope);
				break;
			case EDebugMessageType::DebugDatabaseSettings:
				HandleDebugDatabaseSettings(Envelope);
				break;
			case EDebugMessageType::DebugDatabase:
				HandleDebugDatabase(Envelope);
				break;
			case EDebugMessageType::AssetDatabase:
				HandleAssetDatabase(Envelope);
				break;
			case EDebugMessageType::Diagnostics:
				HandleDiagnostics(Envelope);
				break;
			case EDebugMessageType::PingAlive:
				break;
			case EDebugMessageType::DebugDatabaseFinished:
			case EDebugMessageType::AssetDatabaseInit:
			case EDebugMessageType::AssetDatabaseFinished:
				AddLog(FString::Printf(TEXT("Received %s."), DebugMessageTypeToString(Envelope.MessageType)));
				break;
			default:
				AddLog(FString::Printf(TEXT("Received %s."), DebugMessageTypeToString(Envelope.MessageType)));
				break;
			}
		}

		void HandleDebugServerVersion(const FAngelscriptDebugMessageEnvelope& Envelope)
		{
			const TOptional<FDebugServerVersionMessage> Message = DeserializeDebuggerMessage<FDebugServerVersionMessage>(Envelope);
			FDebuggerClientEvent Event;
			Event.Type = EDebuggerEventType::DebugServerVersion;
			if (Message.IsSet())
			{
				Event.DebugServerVersion = Message->DebugServerVersion;
				Event.Summary = FString::Printf(TEXT("Debug server protocol version %d"), Message->DebugServerVersion);
			}
			else
			{
				Event.Summary = TEXT("Failed to parse DebugServerVersion.");
			}
			PendingEvents.Add(MoveTemp(Event));
		}

		void HandleStopped(const FAngelscriptDebugMessageEnvelope& Envelope)
		{
			const TOptional<FStoppedMessage> Message = DeserializeDebuggerMessage<FStoppedMessage>(Envelope);
			if (!Message.IsSet())
			{
				AddLog(TEXT("Failed to parse stop message."));
				return;
			}

			FDebuggerClientEvent Event;
			Event.Type = EDebuggerEventType::Stopped;
			Event.StopReason = Message->Reason;
			Event.StopText = Message->Text.IsEmpty() ? Message->Description : Message->Text;
			Event.Summary = FString::Printf(TEXT("Stopped: %s %s"), *Message->Reason, *Event.StopText);
			PendingEvents.Add(MoveTemp(Event));
			SendEmpty(EDebugMessageType::RequestCallStack);
		}

		void HandleCallStack(const FAngelscriptDebugMessageEnvelope& Envelope)
		{
			const TOptional<FAngelscriptCallStack> Message = DeserializeDebuggerMessage<FAngelscriptCallStack>(Envelope);
			if (!Message.IsSet())
			{
				AddLog(TEXT("Failed to parse call stack."));
				return;
			}

			FDebuggerClientEvent Event;
			Event.Type = EDebuggerEventType::CallStack;
			Event.Summary = FString::Printf(TEXT("Call stack updated (%d)."), Message->Frames.Num());
			for (const FAngelscriptCallFrame& Frame : Message->Frames)
			{
				FDebuggerFrameView View;
				View.Name = Frame.Name;
				View.Source = Frame.Source;
				View.LineNumber = Frame.LineNumber;
				View.ModuleName = Frame.ModuleName.IsSet() ? Frame.ModuleName.GetValue() : FString();
				Event.Frames.Add(MoveTemp(View));
			}
			PendingEvents.Add(MoveTemp(Event));
		}

		void HandleVariables(const FAngelscriptDebugMessageEnvelope& Envelope)
		{
			const TOptional<FAngelscriptVariables> Message = DeserializeDebuggerMessage<FAngelscriptVariables>(Envelope);
			if (!Message.IsSet())
			{
				AddLog(TEXT("Failed to parse variables."));
				return;
			}

			FDebuggerClientEvent Event;
			Event.Type = EDebuggerEventType::Variables;
			Event.Path = PendingVariablePaths.Num() > 0 ? PendingVariablePaths[0] : FString();
			if (PendingVariablePaths.Num() > 0)
			{
				PendingVariablePaths.RemoveAt(0);
			}

			Event.Summary = FString::Printf(TEXT("Variables updated (%d): %s"), Message->Variables.Num(), *Event.Path);
			for (const FAngelscriptVariable& Variable : Message->Variables)
			{
				FDebuggerVariableView View;
				View.Name = Variable.Name;
				View.Value = Variable.Value;
				View.Type = Variable.Type;
				View.Path = AngelscriptDebugClient::CombineDebuggerPath(Event.Path, Variable.Name);
				View.ValueAddress = Variable.ValueAddress;
				View.ValueSize = Variable.ValueSize;
				View.bHasMembers = Variable.bHasMembers;
				Event.Variables.Add(MoveTemp(View));
			}
			PendingEvents.Add(MoveTemp(Event));
		}

		void HandleEvaluate(const FAngelscriptDebugMessageEnvelope& Envelope)
		{
			const TOptional<FAngelscriptVariable> Message = DeserializeDebuggerMessage<FAngelscriptVariable>(Envelope);
			if (!Message.IsSet())
			{
				AddLog(TEXT("Failed to parse evaluation result."));
				return;
			}

			FDebuggerClientEvent Event;
			Event.Type = EDebuggerEventType::Evaluate;
			Event.Expression = PendingEvaluateExpressions.Num() > 0 ? PendingEvaluateExpressions[0] : Message->Name;
			if (PendingEvaluateExpressions.Num() > 0)
			{
				PendingEvaluateExpressions.RemoveAt(0);
			}

			FDebuggerVariableView View;
			View.Name = Message->Name;
			View.Value = Message->Value;
			View.Type = Message->Type;
			View.Path = Event.Expression;
			View.ValueAddress = Message->ValueAddress;
			View.ValueSize = Message->ValueSize;
			View.bHasMembers = Message->bHasMembers;
			Event.Variables.Add(MoveTemp(View));
			Event.Summary = FString::Printf(TEXT("Evaluate: %s = %s [%s]"), *Event.Expression, *Message->Value, *Message->Type);
			PendingEvents.Add(MoveTemp(Event));
		}

		void HandleBreakFilters(const FAngelscriptDebugMessageEnvelope& Envelope)
		{
			const TOptional<FAngelscriptBreakFilters> Message = DeserializeDebuggerMessage<FAngelscriptBreakFilters>(Envelope);
			if (!Message.IsSet())
			{
				AddLog(TEXT("Failed to parse break filters."));
				return;
			}

			FDebuggerClientEvent Event;
			Event.Type = EDebuggerEventType::BreakFilters;
			Event.Summary = FString::Printf(TEXT("Break filters updated (%d)."), Message->Filters.Num());
			for (int32 Index = 0; Index < Message->Filters.Num(); ++Index)
			{
				const FString Title = Message->FilterTitles.IsValidIndex(Index) ? Message->FilterTitles[Index] : FString();
				Event.Lines.Add(Message->Filters[Index] + TEXT("|") + Title);
			}
			PendingEvents.Add(MoveTemp(Event));
		}

		void HandleSetBreakpointAck(const FAngelscriptDebugMessageEnvelope& Envelope)
		{
			const TOptional<FAngelscriptBreakpoint> Message = DeserializeDebuggerMessage<FAngelscriptBreakpoint>(Envelope);
			if (!Message.IsSet())
			{
				AddLog(TEXT("Failed to parse breakpoint ack."));
				return;
			}

			FDebuggerClientEvent Event;
			Event.Type = EDebuggerEventType::BreakpointAck;
			Event.BreakpointAck = Message.GetValue();
			Event.Summary = Message->LineNumber == -1
				? FString::Printf(TEXT("Breakpoint %d is not on executable code."), Message->Id)
				: FString::Printf(TEXT("Breakpoint %d resolved to line %d."), Message->Id, Message->LineNumber);
			PendingEvents.Add(MoveTemp(Event));
		}

		void HandleClearDataBreakpoints(const FAngelscriptDebugMessageEnvelope& Envelope)
		{
			const TOptional<FAngelscriptClearDataBreakpoints> Message = DeserializeDebuggerMessage<FAngelscriptClearDataBreakpoints>(Envelope);
			if (!Message.IsSet())
			{
				AddLog(TEXT("Failed to parse ClearDataBreakpoints."));
				return;
			}

			FDebuggerClientEvent Event;
			Event.Type = EDebuggerEventType::ClearDataBreakpoints;
			Event.ClearDataBreakpoints = Message.GetValue();
			Event.Summary = FString::Printf(TEXT("Server cleared %d data breakpoint(s)."), Message->Ids.Num());
			PendingEvents.Add(MoveTemp(Event));
		}

		void HandleDebugDatabaseSettings(const FAngelscriptDebugMessageEnvelope& Envelope)
		{
			const TOptional<FAngelscriptDebugDatabaseSettings> Message = DeserializeDebuggerMessage<FAngelscriptDebugDatabaseSettings>(Envelope);
			if (!Message.IsSet())
			{
				AddLog(TEXT("Failed to parse DebugDatabaseSettings."));
				return;
			}

			FDebuggerClientEvent Event;
			Event.Type = EDebuggerEventType::DebugDatabase;
			Event.DebugSettings = Message.GetValue();
			Event.Summary = TEXT("Debug database settings received.");
			PendingEvents.Add(MoveTemp(Event));
		}

		void HandleDebugDatabase(const FAngelscriptDebugMessageEnvelope& Envelope)
		{
			const TOptional<FAngelscriptDebugDatabase> Message = DeserializeDebuggerMessage<FAngelscriptDebugDatabase>(Envelope);
			if (!Message.IsSet())
			{
				AddLog(TEXT("Failed to parse DebugDatabase."));
				return;
			}

			FDebuggerClientEvent Event;
			Event.Type = EDebuggerEventType::DebugDatabase;
			Event.Summary = FString::Printf(TEXT("Debug database chunk: %d chars."), Message->Database.Len());
			Event.Lines.Add(Message->Database.Left(2048));
			PendingEvents.Add(MoveTemp(Event));
		}

		void HandleAssetDatabase(const FAngelscriptDebugMessageEnvelope& Envelope)
		{
			const TOptional<FAngelscriptAssetDatabase> Message = DeserializeDebuggerMessage<FAngelscriptAssetDatabase>(Envelope);
			if (!Message.IsSet())
			{
				AddLog(TEXT("Failed to parse AssetDatabase."));
				return;
			}

			FDebuggerClientEvent Event;
			Event.Type = EDebuggerEventType::AssetDatabase;
			Event.Summary = FString::Printf(TEXT("Asset database chunk: %d entries."), Message->Assets.Num());
			Event.Lines = Message->Assets;
			PendingEvents.Add(MoveTemp(Event));
		}

		void HandleDiagnostics(const FAngelscriptDebugMessageEnvelope& Envelope)
		{
			const TOptional<FAngelscriptDiagnostics> Message = DeserializeDebuggerMessage<FAngelscriptDiagnostics>(Envelope);
			if (!Message.IsSet())
			{
				AddLog(TEXT("Failed to parse diagnostics."));
				return;
			}

			FDebuggerClientEvent Event;
			Event.Type = EDebuggerEventType::Diagnostics;
			Event.Path = Message->Filename;
			Event.Summary = FString::Printf(TEXT("Diagnostics for %s: %d"), *Message->Filename, Message->Diagnostics.Num());
			for (const FAngelscriptDiagnostic& Diagnostic : Message->Diagnostics)
			{
				FDiagnosticView View;
				View.Filename = Message->Filename;
				View.Message = Diagnostic.Message;
				View.Line = Diagnostic.Line;
				View.Character = Diagnostic.Character;
				View.bIsError = Diagnostic.bIsError;
				View.bIsInfo = Diagnostic.bIsInfo;
				View.Severity = Diagnostic.bIsError ? TEXT("Error") : (Diagnostic.bIsInfo ? TEXT("Info") : TEXT("Warning"));
				Event.Diagnostics.Add(MoveTemp(View));
			}
			PendingEvents.Add(MoveTemp(Event));
		}

		void AddEvent(const EDebuggerEventType Type, const FString& Text)
		{
			FDebuggerClientEvent Event;
			Event.Type = Type;
			Event.Summary = Text;
			PendingEvents.Add(MoveTemp(Event));
		}

		void AddLog(const FString& Text)
		{
			AddEvent(EDebuggerEventType::Log, Text);
		}

		ISocketSubsystem* SocketSubsystem = nullptr;
		FSocket* Socket = nullptr;
		EDebuggerConnectionState ConnectionState = EDebuggerConnectionState::Disconnected;
		FString Host = TEXT("127.0.0.1");
		int32 Port = 27099;
		TArray<uint8> ReceiveBuffer;
		TArray<uint8> PendingSendBuffer;
		int32 PendingSendOffset = 0;
		bool bSentStartDebugging = false;
		TArray<FString> PendingVariablePaths;
		TArray<FString> PendingEvaluateExpressions;
		TArray<FDebuggerClientEvent> PendingEvents;
	};

FClient::FClient()
	: Impl(MakeUnique<FImpl>())
{
}

FClient::~FClient() = default;

bool FClient::Connect(const FString& InHost, const int32 InPort)
{
	return Impl->Connect(InHost, InPort);
}

void FClient::Disconnect()
{
	Impl->Disconnect();
}

void FClient::Tick()
{
	Impl->Tick();
}

bool FClient::IsConnected() const
{
	return Impl->IsConnected();
}

FText FClient::GetStatusText() const
{
	return Impl->GetStatusText();
}

TArray<FDebuggerClientEvent> FClient::DrainEvents()
{
	return Impl->DrainEvents();
}

void FClient::SendEmpty(const EDebugMessageType MessageType)
{
	Impl->SendEmpty(MessageType);
}

void FClient::SendRequestVariables(const FString& ScopePath)
{
	Impl->SendRequestVariables(ScopePath);
}

void FClient::SendRequestEvaluate(const FString& Path, const int32 DefaultFrame)
{
	Impl->SendRequestEvaluate(Path, DefaultFrame);
}

void FClient::SendSetBreakpoint(const int32 Id, const FString& Filename, const FString& ModuleName, const int32 LineNumber, const FString& Condition)
{
	Impl->SendSetBreakpoint(Id, Filename, ModuleName, LineNumber, Condition);
}

void FClient::SendClearBreakpoints(const FString& Filename, const FString& ModuleName)
{
	Impl->SendClearBreakpoints(Filename, ModuleName);
}

void FClient::SendBreakOptions(const TArray<FString>& Filters)
{
	Impl->SendBreakOptions(Filters);
}

void FClient::SendSetDataBreakpoints(const TArray<FDataBreakpointView>& Breakpoints)
{
	Impl->SendSetDataBreakpoints(Breakpoints);
}
}
