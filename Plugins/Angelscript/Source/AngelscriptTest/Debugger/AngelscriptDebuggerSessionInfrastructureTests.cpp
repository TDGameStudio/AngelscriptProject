#include "Shared/AngelscriptDebuggerTestClient.h"
#include "Shared/AngelscriptDebuggerTestSession.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Debugger_AngelscriptDebuggerSessionInfrastructureTests_Private
{
	TSharedRef<FFakeDebuggerClientSocket> MakePendingConnectSocket(
		const FString& Description,
		const TArray<ESocketConnectionState>& ConnectionStates)
	{
		TSharedRef<FFakeDebuggerClientSocket> Socket = MakeShared<FFakeDebuggerClientSocket>(Description);
		Socket->SetConnectResult(false, SE_EINPROGRESS);
		Socket->SetConnectionStates(ConnectionStates);
		return Socket;
	}

	bool WaitForDebugServerVersion(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		FAngelscriptDebuggerTestClient& Client)
	{
		TOptional<FAngelscriptDebugMessageEnvelope> VersionEnvelope;
		const bool bReceivedVersion = Session.PumpUntil(
			[&Client, &VersionEnvelope]()
			{
				if (VersionEnvelope.IsSet())
				{
					return true;
				}

				TOptional<FAngelscriptDebugMessageEnvelope> Envelope = Client.ReceiveEnvelope();
				if (Envelope.IsSet() && Envelope->MessageType == EDebugMessageType::DebugServerVersion)
				{
					VersionEnvelope = MoveTemp(Envelope);
					return true;
				}

				return false;
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion should receive DebugServerVersion after StartDebugging"), bReceivedVersion))
		{
			if (!Client.GetLastError().IsEmpty())
			{
				Test.AddError(Client.GetLastError());
			}
			return false;
		}

		const TOptional<FDebugServerVersionMessage> DebugServerVersion =
			FAngelscriptDebuggerTestClient::DeserializeMessage<FDebugServerVersionMessage>(VersionEnvelope.GetValue());
		if (!Test.TestTrue(TEXT("Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion should deserialize the DebugServerVersion payload"), DebugServerVersion.IsSet()))
		{
			return false;
		}

		return Test.TestEqual(
			TEXT("Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion should report the current debug server version"),
			DebugServerVersion->DebugServerVersion,
			DEBUG_SERVER_VERSION);
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerSessionInfrastructureTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerSessionInitializeDoesNotMutateAdapterVersionTest,
	"Angelscript.TestModule.Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerSessionInitializeDoesNotMutateAdapterVersionTest::RunTest(const FString& Parameters)
{
	constexpr int32 InitializeSentinelVersion = 7;
	constexpr int32 HandshakeAdapterVersion = 2;
	constexpr int32 FreshSessionSentinelVersion = 11;

	FAngelscriptDebuggerSessionConfig SessionConfig;
	// UE 5.7: headless has no production subsystem. Leave ExistingEngine null so
	// Initialize() spins up an isolated FAngelscriptEngine with its own
	// FAngelscriptDebugServer bound to a unique port.
	SessionConfig.DefaultTimeoutSeconds = 45.0f;

	FScopedDebugAdapterVersionSentinel AdapterVersionSentinel(InitializeSentinelVersion);
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	ON_SCOPE_EXIT
	{
		if (Client.IsConnected())
		{
			if (Session.IsInitialized() && Session.GetDebugServer().bIsDebugging)
			{
				Client.SendStopDebugging();
				Session.PumpUntil([&Session]() { return !Session.GetDebugServer().bIsDebugging; }, 1.0f);
			}

			Client.SendDisconnect();
			Client.Disconnect();
		}

		Session.Shutdown();
	};

	TestEqual(
		TEXT("Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion should start from the sentinel adapter version"),
		AdapterVersionSentinel.GetCurrent(),
		InitializeSentinelVersion);

	if (!TestTrue(TEXT("Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion should initialize the debugger session"), Session.Initialize(SessionConfig)))
	{
		return false;
	}

	TestEqual(
		TEXT("Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion should preserve the sentinel through Initialize before any handshake"),
		AdapterVersionSentinel.GetCurrent(),
		InitializeSentinelVersion);

	if (!TestTrue(TEXT("Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion should connect the debugger client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion should send StartDebugging"), Client.SendStartDebugging(HandshakeAdapterVersion)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForDebugServerVersion(*this, Session, Client))
	{
		return false;
	}

	TestEqual(
		TEXT("Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion should switch to the requested adapter version after StartDebugging"),
		AdapterVersionSentinel.GetCurrent(),
		HandshakeAdapterVersion);

	if (!TestTrue(TEXT("Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion should send StopDebugging"), Client.SendStopDebugging()))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!TestTrue(
			TEXT("Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion should leave debugging mode after StopDebugging"),
			Session.PumpUntil([&Session]() { return !Session.GetDebugServer().bIsDebugging; }, Session.GetDefaultTimeoutSeconds())))
	{
		return false;
	}

	Client.SendDisconnect();
	Client.Disconnect();

	Session.Shutdown();
	TestEqual(
		TEXT("Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion should restore the pre-handshake sentinel during Shutdown"),
		AdapterVersionSentinel.GetCurrent(),
		InitializeSentinelVersion);

	AdapterVersionSentinel.SetSentinel(FreshSessionSentinelVersion);

	{
		FAngelscriptDebuggerTestSession FreshSession;
	}

	TestEqual(
		TEXT("Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion should keep the sentinel when a never-initialized session is destroyed"),
		AdapterVersionSentinel.GetCurrent(),
		FreshSessionSentinelVersion);

	FAngelscriptDebuggerTestSession ExplicitShutdownSession;
	ExplicitShutdownSession.Shutdown();
	TestEqual(
		TEXT("Debugger.Shared.SessionInitializeDoesNotMutateAdapterVersion should keep the sentinel when Shutdown is called on a never-initialized session"),
		AdapterVersionSentinel.GetCurrent(),
		FreshSessionSentinelVersion);

	return !HasAnyErrors();
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerSessionPreservesDebugBreakStateTest,
	"Angelscript.TestModule.Debugger.Shared.SessionPreservesDebugBreakState",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerSessionPreservesDebugBreakStateTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerSessionConfig SessionConfig;
	SessionConfig.DefaultTimeoutSeconds = 45.0f;
	SessionConfig.bDisableDebugBreaks = true;

	TSharedPtr<FAngelscriptMockDebugServer> MockServer = MakeShared<FAngelscriptMockDebugServer>();
	SessionConfig.MockServer = MockServer;

	FScopedDebugBreakStateSentinel DebugBreakStateSentinel;

	auto RunScenario = [this, &SessionConfig, &DebugBreakStateSentinel](const bool bInitiallyEnabled, const TCHAR* ScenarioLabel) -> bool
	{
		DebugBreakStateSentinel.SetEnabled(bInitiallyEnabled);
		if (!TestEqual(
				*FString::Printf(TEXT("Debugger.Shared.SessionPreservesDebugBreakState should start %s from the requested debug-break state"), ScenarioLabel),
				DebugBreakStateSentinel.IsEnabled(),
				bInitiallyEnabled))
		{
			return false;
		}

		{
			FAngelscriptDebuggerTestSession Session;
			if (!TestTrue(
					*FString::Printf(TEXT("Debugger.Shared.SessionPreservesDebugBreakState should initialize the debugger session for the %s branch"), ScenarioLabel),
					Session.Initialize(SessionConfig)))
			{
				return false;
			}

			if (!TestFalse(
					*FString::Printf(TEXT("Debugger.Shared.SessionPreservesDebugBreakState should disable debug breaks while the %s session is active"), ScenarioLabel),
					DebugBreakStateSentinel.IsEnabled()))
			{
				return false;
			}
		}

		return TestEqual(
			*FString::Printf(TEXT("Debugger.Shared.SessionPreservesDebugBreakState should restore the %s debug-break state after session shutdown"), ScenarioLabel),
			DebugBreakStateSentinel.IsEnabled(),
			bInitiallyEnabled);
	};

	bool bPassed = true;
	bPassed &= RunScenario(true, TEXT("pre-enabled"));
	bPassed &= RunScenario(false, TEXT("pre-disabled"));
	return bPassed;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerClientConnectTimeoutReportsFailureTest,
	"Angelscript.TestModule.Debugger.Shared.ClientConnectTimeoutReportsFailure",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerClientConnectTimeoutReportsFailureTest::RunTest(const FString& Parameters)
{
	constexpr float FailureTimeoutSeconds = 0.01f;
	constexpr float SuccessTimeoutSeconds = 0.05f;

	bool bPassed = true;

	{
		TSharedRef<FFakeDebuggerClientSocket> TimeoutSocket = MakePendingConnectSocket(
			TEXT("TimeoutSocket"),
			{ESocketConnectionState::SCS_NotConnected, ESocketConnectionState::SCS_NotConnected, ESocketConnectionState::SCS_NotConnected});
		FAngelscriptDebuggerTestClient Client(MakeShared<FSingleDebuggerTestSocketFactory>(TimeoutSocket));

		bPassed &= TestFalse(
			TEXT("Debugger.Shared.ClientConnectTimeoutReportsFailure should fail the connect attempt when the socket never reaches SCS_Connected"),
			Client.Connect(TEXT("127.0.0.1"), 31337, FailureTimeoutSeconds));
		bPassed &= TestTrue(
			TEXT("Debugger.Shared.ClientConnectTimeoutReportsFailure should mention the host in the connect-timeout error"),
			Client.GetLastError().Contains(TEXT("127.0.0.1")));
		bPassed &= TestTrue(
			TEXT("Debugger.Shared.ClientConnectTimeoutReportsFailure should mention the port in the connect-timeout error"),
			Client.GetLastError().Contains(TEXT("31337")));
		bPassed &= TestTrue(
			TEXT("Debugger.Shared.ClientConnectTimeoutReportsFailure should report a connect-timeout instead of deferring the error to message wait helpers"),
			Client.GetLastError().Contains(TEXT("Timed out")));
		bPassed &= TestTrue(
			TEXT("Debugger.Shared.ClientConnectTimeoutReportsFailure should report the last connection state"),
			Client.GetLastError().Contains(TEXT("SCS_NotConnected")));
		bPassed &= TestFalse(
			TEXT("Debugger.Shared.ClientConnectTimeoutReportsFailure should leave the client disconnected after timeout"),
			Client.IsConnected());
		bPassed &= TestTrue(
			TEXT("Debugger.Shared.ClientConnectTimeoutReportsFailure should close the socket after a failed connect attempt"),
			TimeoutSocket->WasClosed());
		bPassed &= TestFalse(
			TEXT("Debugger.Shared.ClientConnectTimeoutReportsFailure should not permit StartDebugging after a failed connect attempt"),
			Client.SendStartDebugging(2));
		bPassed &= TestTrue(
			TEXT("Debugger.Shared.ClientConnectTimeoutReportsFailure should clear any half-connected socket before StartDebugging"),
			Client.GetLastError().Contains(TEXT("active socket connection")));
	}

	{
		TSharedRef<FFakeDebuggerClientSocket> SuccessSocket = MakePendingConnectSocket(
			TEXT("SuccessSocket"),
			{ESocketConnectionState::SCS_NotConnected, ESocketConnectionState::SCS_NotConnected, ESocketConnectionState::SCS_Connected});
		FAngelscriptDebuggerTestClient Client(MakeShared<FSingleDebuggerTestSocketFactory>(SuccessSocket));

		bPassed &= TestTrue(
			TEXT("Debugger.Shared.ClientConnectTimeoutReportsFailure should succeed when the same pending connect reaches SCS_Connected before the deadline"),
			Client.Connect(TEXT("127.0.0.1"), 31338, SuccessTimeoutSeconds));
		bPassed &= TestTrue(
			TEXT("Debugger.Shared.ClientConnectTimeoutReportsFailure should report the connected state after the pending connect succeeds"),
			Client.IsConnected());
		bPassed &= TestTrue(
			TEXT("Debugger.Shared.ClientConnectTimeoutReportsFailure should clear LastError after a successful pending connect"),
			Client.GetLastError().IsEmpty());

		Client.Disconnect();
		bPassed &= TestTrue(
			TEXT("Debugger.Shared.ClientConnectTimeoutReportsFailure should close the socket when the successfully connected client disconnects"),
			SuccessSocket->WasClosed());
	}

	return bPassed;
}

#endif

