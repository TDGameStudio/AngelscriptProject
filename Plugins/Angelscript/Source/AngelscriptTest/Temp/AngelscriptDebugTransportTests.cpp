#include "Debugging/AngelscriptDebugServer.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace
{
	TArray<uint8> MakeInvalidLengthEnvelope(int32 MessageLength)
	{
		TArray<uint8> Buffer;
		FMemoryWriter Writer(Buffer);
		Writer << MessageLength;
		return Buffer;
	}
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugTransportSingleEnvelopeTest,
	"Angelscript.TestModule.CppTests.Debug.Transport.SingleEnvelope",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugTransportMultipleEnvelopesTest,
	"Angelscript.TestModule.CppTests.Debug.Transport.MultipleEnvelopes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugTransportTruncatedEnvelopeTest,
	"Angelscript.TestModule.CppTests.Debug.Transport.TruncatedEnvelope",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugTransportInvalidLengthTest,
	"Angelscript.TestModule.CppTests.Debug.Transport.InvalidLength",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugTransportEmptyBodyEnvelopeTest,
	"Angelscript.TestModule.CppTests.Debug.Transport.EmptyBodyEnvelope",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebugTransportSingleEnvelopeTest::RunTest(const FString& Parameters)
{
	FDebugServerVersionMessage Message;
	Message.DebugServerVersion = DEBUG_SERVER_VERSION;

	TArray<uint8> Body;
	FMemoryWriter BodyWriter(Body);
	BodyWriter << Message;

	TArray<uint8> Buffer;
	if (!TestTrue(TEXT("Debug.Transport.SingleEnvelope should serialize a debugger envelope"), SerializeDebugMessageEnvelope(EDebugMessageType::DebugServerVersion, Body, Buffer)))
	{
		return false;
	}

	int32 MessageLength = 0;
	FMemoryReader HeaderReader(Buffer);
	HeaderReader << MessageLength;
	TestEqual(TEXT("Debug.Transport.SingleEnvelope should store the payload length as type-byte plus body"), MessageLength, static_cast<int32>(sizeof(uint8)) + Body.Num());

	FAngelscriptDebugMessageEnvelope Envelope;
	bool bHasEnvelope = false;
	FString Error;
	if (!TestTrue(TEXT("Debug.Transport.SingleEnvelope should deserialize the serialized envelope"), TryDeserializeDebugMessageEnvelope(Buffer, Envelope, bHasEnvelope, &Error)))
	{
		AddError(Error);
		return false;
	}

	if (!TestTrue(TEXT("Debug.Transport.SingleEnvelope should yield a complete envelope"), bHasEnvelope))
	{
		return false;
	}

	TestEqual(TEXT("Debug.Transport.SingleEnvelope should preserve the message type"), Envelope.MessageType, EDebugMessageType::DebugServerVersion);
	TestEqual(TEXT("Debug.Transport.SingleEnvelope should consume the serialized bytes"), Buffer.Num(), 0);

	const TOptional<FDebugServerVersionMessage> RoundTripped = [] (const FAngelscriptDebugMessageEnvelope& InEnvelope)
	{
		FDebugServerVersionMessage Parsed;
		TArray<uint8> ParsedBody = InEnvelope.Body;
		FMemoryReader Reader(ParsedBody);
		Reader << Parsed;
		return TOptional<FDebugServerVersionMessage>(Parsed);
	}(Envelope);

	if (!TestTrue(TEXT("Debug.Transport.SingleEnvelope should parse the payload body"), RoundTripped.IsSet()))
	{
		return false;
	}

	TestEqual(TEXT("Debug.Transport.SingleEnvelope should preserve the payload content"), RoundTripped->DebugServerVersion, DEBUG_SERVER_VERSION);
	return true;
}

bool FAngelscriptDebugTransportMultipleEnvelopesTest::RunTest(const FString& Parameters)
{
	FDebugServerVersionMessage First;
	First.DebugServerVersion = 7;
	FStoppedMessage Second;
	Second.Reason = TEXT("breakpoint");
	Second.Description = TEXT("hit line");
	Second.Text = TEXT("fixture stopped");

	TArray<uint8> FirstBody;
	FMemoryWriter FirstBodyWriter(FirstBody);
	FirstBodyWriter << First;

	TArray<uint8> SecondBody;
	FMemoryWriter SecondBodyWriter(SecondBody);
	SecondBodyWriter << Second;

	TArray<uint8> CombinedBuffer;
	TArray<uint8> Serialized;
	SerializeDebugMessageEnvelope(EDebugMessageType::DebugServerVersion, FirstBody, Serialized);
	CombinedBuffer.Append(Serialized);
	Serialized.Reset();
	SerializeDebugMessageEnvelope(EDebugMessageType::HasStopped, SecondBody, Serialized);
	CombinedBuffer.Append(Serialized);

	FAngelscriptDebugMessageEnvelope FirstEnvelope;
	bool bHasFirstEnvelope = false;
	FString Error;
	if (!TestTrue(TEXT("Debug.Transport.MultipleEnvelopes should decode the first envelope"), TryDeserializeDebugMessageEnvelope(CombinedBuffer, FirstEnvelope, bHasFirstEnvelope, &Error)))
	{
		AddError(Error);
		return false;
	}
	if (!TestTrue(TEXT("Debug.Transport.MultipleEnvelopes should produce the first envelope"), bHasFirstEnvelope))
	{
		return false;
	}
	TestEqual(TEXT("Debug.Transport.MultipleEnvelopes should decode the first message type in order"), FirstEnvelope.MessageType, EDebugMessageType::DebugServerVersion);

	FAngelscriptDebugMessageEnvelope SecondEnvelope;
	bool bHasSecondEnvelope = false;
	if (!TestTrue(TEXT("Debug.Transport.MultipleEnvelopes should decode the second envelope"), TryDeserializeDebugMessageEnvelope(CombinedBuffer, SecondEnvelope, bHasSecondEnvelope, &Error)))
	{
		AddError(Error);
		return false;
	}
	if (!TestTrue(TEXT("Debug.Transport.MultipleEnvelopes should produce the second envelope"), bHasSecondEnvelope))
	{
		return false;
	}
	TestEqual(TEXT("Debug.Transport.MultipleEnvelopes should decode the second message type in order"), SecondEnvelope.MessageType, EDebugMessageType::HasStopped);
	TestEqual(TEXT("Debug.Transport.MultipleEnvelopes should consume both envelopes"), CombinedBuffer.Num(), 0);
	return true;
}

bool FAngelscriptDebugTransportTruncatedEnvelopeTest::RunTest(const FString& Parameters)
{
	FStoppedMessage Message;
	Message.Reason = TEXT("pause");
	Message.Description = TEXT("waiting");
	Message.Text = TEXT("partial frame");

	TArray<uint8> Body;
	FMemoryWriter BodyWriter(Body);
	BodyWriter << Message;

	TArray<uint8> Buffer;
	SerializeDebugMessageEnvelope(EDebugMessageType::HasStopped, Body, Buffer);
	if (!TestTrue(TEXT("Debug.Transport.TruncatedEnvelope should create a large enough envelope to truncate"), Buffer.Num() > 3))
	{
		return false;
	}

	Buffer.SetNum(Buffer.Num() - 3, EAllowShrinking::No);

	FAngelscriptDebugMessageEnvelope Envelope;
	bool bHasEnvelope = false;
	FString Error;
	if (!TestTrue(TEXT("Debug.Transport.TruncatedEnvelope should not treat a partial packet as a protocol error"), TryDeserializeDebugMessageEnvelope(Buffer, Envelope, bHasEnvelope, &Error)))
	{
		AddError(Error);
		return false;
	}

	TestFalse(TEXT("Debug.Transport.TruncatedEnvelope should wait for more bytes instead of yielding an envelope"), bHasEnvelope);
	TestTrue(TEXT("Debug.Transport.TruncatedEnvelope should keep the partial bytes buffered"), Buffer.Num() > 0);
	return true;
}

bool FAngelscriptDebugTransportInvalidLengthTest::RunTest(const FString& Parameters)
{
	TArray<uint8> Buffer = MakeInvalidLengthEnvelope(0);
	FAngelscriptDebugMessageEnvelope Envelope;
	bool bHasEnvelope = false;
	FString Error;

	TestFalse(TEXT("Debug.Transport.InvalidLength should reject zero-length envelopes"), TryDeserializeDebugMessageEnvelope(Buffer, Envelope, bHasEnvelope, &Error));
	TestTrue(TEXT("Debug.Transport.InvalidLength should report the invalid length in the error message"), Error.Contains(TEXT("invalid message length")));
	return true;
}

bool FAngelscriptDebugTransportEmptyBodyEnvelopeTest::RunTest(const FString& Parameters)
{
	FEmptyMessage Message;
	TArray<uint8> Body;
	FMemoryWriter BodyWriter(Body);
	BodyWriter << Message;

	TArray<uint8> Buffer;
	SerializeDebugMessageEnvelope(EDebugMessageType::Pause, Body, Buffer);

	int32 MessageLength = 0;
	FMemoryReader HeaderReader(Buffer);
	HeaderReader << MessageLength;
	TestEqual(TEXT("Debug.Transport.EmptyBodyEnvelope should still account for the message type byte in the payload length"), MessageLength, static_cast<int32>(sizeof(uint8)));

	FAngelscriptDebugMessageEnvelope Envelope;
	bool bHasEnvelope = false;
	FString Error;
	if (!TestTrue(TEXT("Debug.Transport.EmptyBodyEnvelope should deserialize a type-only envelope"), TryDeserializeDebugMessageEnvelope(Buffer, Envelope, bHasEnvelope, &Error)))
	{
		AddError(Error);
		return false;
	}

	if (!TestTrue(TEXT("Debug.Transport.EmptyBodyEnvelope should yield an envelope for type-only messages"), bHasEnvelope))
	{
		return false;
	}

	TestEqual(TEXT("Debug.Transport.EmptyBodyEnvelope should preserve the message type"), Envelope.MessageType, EDebugMessageType::Pause);
	TestEqual(TEXT("Debug.Transport.EmptyBodyEnvelope should preserve an empty body"), Envelope.Body.Num(), 0);
	return true;
}

#endif
