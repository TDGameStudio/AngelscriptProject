#include "Shared/AngelscriptDebuggerTestClient.h"
#include "Shared/AngelscriptDebuggerTestSession.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerSmokeHandshakeTest,
	"Angelscript.TestModule.Debugger.Smoke.Handshake",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerSmokeHandshakeTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerSessionConfig SessionConfig;
	// UE 5.7: TryGetRunningProductionDebuggerEngine() returns null in headless
	// automation (no UAngelscriptGameInstanceSubsystem). Leaving ExistingEngine
	// null lets Initialize() build an isolated FAngelscriptEngine whose
	// FAngelscriptDebugServer binds to a unique port — the session then owns
	// full engine + server lifecycle for the test.
	if (!TestTrue(TEXT("Debugger.Smoke.Handshake should initialize a debugger test session"), Session.Initialize(SessionConfig)))
	{
		return false;
	}

	FAngelscriptDebuggerTestClient Client;
	if (!TestTrue(TEXT("Debugger.Smoke.Handshake should connect a debugger test client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
	{
		AddError(Client.GetLastError());
		return false;
	}

	ON_SCOPE_EXIT
	{
		if (Client.IsConnected())
		{
			Client.SendStopDebugging();
			Session.PumpUntil([&Session]() { return !Session.GetDebugServer().bIsDebugging; }, 1.0f);
			Client.SendDisconnect();
			Client.Disconnect();
		}
	};

	if (!TestTrue(TEXT("Debugger.Smoke.Handshake should send StartDebugging"), Client.SendStartDebugging(2)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	TOptional<FAngelscriptDebugMessageEnvelope> DebugVersionEnvelope;
	const bool bReceivedDebugVersion = Session.PumpUntil(
		[&Client, &DebugVersionEnvelope]()
		{
			if (DebugVersionEnvelope.IsSet())
			{
				return true;
			}

			TOptional<FAngelscriptDebugMessageEnvelope> Envelope = Client.ReceiveEnvelope();
			if (Envelope.IsSet() && Envelope->MessageType == EDebugMessageType::DebugServerVersion)
			{
				DebugVersionEnvelope = MoveTemp(Envelope);
				return true;
			}

			return false;
		},
		Session.GetDefaultTimeoutSeconds());

	if (!TestTrue(TEXT("Debugger.Smoke.Handshake should receive the DebugServerVersion response"), bReceivedDebugVersion))
	{
		AddError(Client.GetLastError());
		return false;
	}

	const TOptional<FDebugServerVersionMessage> DebugServerVersion = FAngelscriptDebuggerTestClient::DeserializeMessage<FDebugServerVersionMessage>(DebugVersionEnvelope.GetValue());
	if (!TestTrue(TEXT("Debugger.Smoke.Handshake should deserialize the debug server version payload"), DebugServerVersion.IsSet()))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Smoke.Handshake should report the current debug server version"), DebugServerVersion->DebugServerVersion, DEBUG_SERVER_VERSION);
	TestTrue(TEXT("Debugger.Smoke.Handshake should put the session in debugging mode after StartDebugging"), Session.GetDebugServer().bIsDebugging);

	if (!TestTrue(TEXT("Debugger.Smoke.Handshake should request debugger break filters"), Client.SendRequestBreakFilters()))
	{
		AddError(Client.GetLastError());
		return false;
	}

	TOptional<FAngelscriptDebugMessageEnvelope> BreakFiltersEnvelope;
	const bool bReceivedBreakFilters = Session.PumpUntil(
		[&Client, &BreakFiltersEnvelope]()
		{
			if (BreakFiltersEnvelope.IsSet())
			{
				return true;
			}

			TOptional<FAngelscriptDebugMessageEnvelope> Envelope = Client.ReceiveEnvelope();
			if (Envelope.IsSet() && Envelope->MessageType == EDebugMessageType::BreakFilters)
			{
				BreakFiltersEnvelope = MoveTemp(Envelope);
				return true;
			}

			return false;
		},
		Session.GetDefaultTimeoutSeconds());

	if (!TestTrue(TEXT("Debugger.Smoke.Handshake should receive a BreakFilters response"), bReceivedBreakFilters))
	{
		AddError(Client.GetLastError());
		return false;
	}

	const TOptional<FAngelscriptBreakFilters> BreakFilters = FAngelscriptDebuggerTestClient::DeserializeMessage<FAngelscriptBreakFilters>(BreakFiltersEnvelope.GetValue());
	TestTrue(TEXT("Debugger.Smoke.Handshake should deserialize the BreakFilters payload"), BreakFilters.IsSet());

	if (!TestTrue(TEXT("Debugger.Smoke.Handshake should send StopDebugging"), Client.SendStopDebugging()))
	{
		AddError(Client.GetLastError());
		return false;
	}

	const bool bStoppedDebugging = Session.PumpUntil([&Session]() { return !Session.GetDebugServer().bIsDebugging; }, Session.GetDefaultTimeoutSeconds());
	TestTrue(TEXT("Debugger.Smoke.Handshake should leave debugging mode after StopDebugging"), bStoppedDebugging);
	return !HasAnyErrors();
}

#endif

