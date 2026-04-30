#include "Debugging/AngelscriptDebugProtocol.h"

#include "Modules/ModuleManager.h"
#include "Serialization/MemoryReader.h"
#include "Serialization/MemoryWriter.h"

IMPLEMENT_MODULE(FDefaultModuleImpl, AngelscriptDebugProtocol);

int32 AngelscriptDebugServer::DebugAdapterVersion = 0;

namespace
{
	// RequestDebugDatabase can legitimately emit multi-megabyte envelopes on mature projects.
	constexpr int32 MaxDebuggerEnvelopeSizeBytes = 16 * 1024 * 1024;
}

bool SerializeDebugMessageEnvelope(EDebugMessageType MessageType, const TArray<uint8>& Body, TArray<uint8>& OutBuffer)
{
	OutBuffer.Reset();
	FMemoryWriter Writer(OutBuffer);
	const int32 MessageLength = static_cast<int32>(sizeof(uint8)) + Body.Num();
	const uint8 MessageTypeByte = static_cast<uint8>(MessageType);
	Writer << const_cast<int32&>(MessageLength);
	Writer << const_cast<uint8&>(MessageTypeByte);
	OutBuffer.Append(Body);
	return true;
}

bool TryDeserializeDebugMessageEnvelope(TArray<uint8>& InOutBuffer, FAngelscriptDebugMessageEnvelope& OutEnvelope, bool& bOutHasEnvelope, FString* OutError)
{
	bOutHasEnvelope = false;
	if (InOutBuffer.Num() < static_cast<int32>(sizeof(int32)))
	{
		return true;
	}

	TArray<uint8> HeaderBytes;
	HeaderBytes.Append(InOutBuffer.GetData(), sizeof(int32));
	FMemoryReader HeaderReader(HeaderBytes);
	int32 MessageLength = 0;
	HeaderReader << MessageLength;

	if (MessageLength <= 0 || MessageLength > MaxDebuggerEnvelopeSizeBytes)
	{
		if (OutError != nullptr)
		{
			*OutError = FString::Printf(TEXT("Received debugger envelope with invalid message length %d."), MessageLength);
		}
		return false;
	}

	const int32 TotalEnvelopeSize = static_cast<int32>(sizeof(int32)) + MessageLength;
	if (InOutBuffer.Num() < TotalEnvelopeSize)
	{
		return true;
	}

	TArray<uint8> PayloadBytes;
	PayloadBytes.Append(InOutBuffer.GetData() + sizeof(int32), MessageLength);
	FMemoryReader PayloadReader(PayloadBytes);
	uint8 MessageTypeByte = static_cast<uint8>(EDebugMessageType::Disconnect);
	PayloadReader << MessageTypeByte;

	OutEnvelope.MessageType = static_cast<EDebugMessageType>(MessageTypeByte);
	OutEnvelope.Body.Reset();
	if (MessageLength > static_cast<int32>(sizeof(uint8)))
	{
		OutEnvelope.Body.Append(PayloadBytes.GetData() + sizeof(uint8), MessageLength - static_cast<int32>(sizeof(uint8)));
	}

	InOutBuffer.RemoveAt(0, TotalEnvelopeSize, EAllowShrinking::No);
	bOutHasEnvelope = true;
	return true;
}
