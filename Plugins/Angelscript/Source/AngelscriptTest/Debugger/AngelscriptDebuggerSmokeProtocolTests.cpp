#include "Shared/AngelscriptDebuggerTestClient.h"
#include "Shared/AngelscriptDebuggerTestSession.h"

#include "Core/AngelscriptRuntimeModule.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Debugger_AngelscriptDebuggerSmokeProtocolTests_Private
{
	class FScopedDebugBreakFiltersBinding
	{
	public:
		explicit FScopedDebugBreakFiltersBinding(TFunction<void(FAngelscriptDebugBreakFilters&)> InPopulateFilters)
			: TargetDelegate(FAngelscriptRuntimeModule::GetDebugBreakFilters())
			, PreviousDelegate(TargetDelegate)
			, PopulateFilters(MoveTemp(InPopulateFilters))
		{
			TargetDelegate.BindLambda([this](FAngelscriptDebugBreakFilters& OutFilters)
			{
				PopulateFilters(OutFilters);
			});
		}

		~FScopedDebugBreakFiltersBinding()
		{
			TargetDelegate = MoveTemp(PreviousDelegate);
		}

	private:
		FAngelscriptGetDebugBreakFilters& TargetDelegate;
		FAngelscriptGetDebugBreakFilters PreviousDelegate;
		TFunction<void(FAngelscriptDebugBreakFilters&)> PopulateFilters;
	};

	bool StartSmokeProtocolDebuggerSession(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		FAngelscriptDebuggerTestClient& Client)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.

		if (!Test.TestTrue(TEXT("Debugger smoke protocol should initialize the debugger session"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger smoke protocol should connect the debugger client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger smoke protocol should send StartDebugging"), Client.SendStartDebugging(2)))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

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

		if (!Test.TestTrue(TEXT("Debugger smoke protocol should receive the DebugServerVersion response"), bReceivedVersion))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		return true;
	}

	bool WaitForDebuggerEnvelopeType(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		FAngelscriptDebuggerTestClient& Client,
		EDebugMessageType ExpectedType,
		TOptional<FAngelscriptDebugMessageEnvelope>& OutEnvelope,
		const TCHAR* Context)
	{
		const bool bReceivedEnvelope = Session.PumpUntil(
			[&Client, &OutEnvelope, ExpectedType]()
			{
				if (OutEnvelope.IsSet())
				{
					return true;
				}

				TOptional<FAngelscriptDebugMessageEnvelope> Envelope = Client.ReceiveEnvelope();
				if (Envelope.IsSet() && Envelope->MessageType == ExpectedType)
				{
					OutEnvelope = MoveTemp(Envelope);
					return true;
				}

				return false;
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(Context, bReceivedEnvelope))
		{
			if (!Client.GetLastError().IsEmpty())
			{
				Test.AddError(Client.GetLastError());
			}
			return false;
		}

		return true;
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerSmokeProtocolTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerSmokeBreakFiltersRoundtripTest,
	"Angelscript.TestModule.Debugger.Smoke.BreakFiltersRoundtrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerSmokeBreakFiltersRoundtripTest::RunTest(const FString& Parameters)
{
	FScopedDebugBreakFiltersBinding ScopedBinding(
		[](FAngelscriptDebugBreakFilters& OutFilters)
		{
			OutFilters.Add(FName(TEXT("break:ensure")), TEXT("Ensure"));
			OutFilters.Add(FName(TEXT("break:script")), TEXT("Script"));
		});

	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartSmokeProtocolDebuggerSession(*this, Session, Client))
	{
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

	TestTrue(TEXT("Debugger smoke protocol should enter debugging mode after StartDebugging"), Session.GetDebugServer().bIsDebugging);

	if (!TestTrue(TEXT("Debugger smoke protocol should request break filters"), Client.SendRequestBreakFilters()))
	{
		AddError(Client.GetLastError());
		return false;
	}

	TOptional<FAngelscriptDebugMessageEnvelope> BreakFiltersEnvelope;
	if (!WaitForDebuggerEnvelopeType(
		*this,
		Session,
		Client,
		EDebugMessageType::BreakFilters,
		BreakFiltersEnvelope,
		TEXT("Debugger smoke protocol should receive a BreakFilters response")))
	{
		return false;
	}

	const TOptional<FAngelscriptBreakFilters> BreakFilters = FAngelscriptDebuggerTestClient::DeserializeMessage<FAngelscriptBreakFilters>(BreakFiltersEnvelope.GetValue());
	if (!TestTrue(TEXT("Debugger smoke protocol should deserialize the BreakFilters payload"), BreakFilters.IsSet()))
	{
		return false;
	}

	TestTrue(TEXT("Debugger smoke protocol should stay in debugging mode after querying break filters"), Session.GetDebugServer().bIsDebugging);
	TestEqual(TEXT("Debugger smoke protocol should report two break filters"), BreakFilters->Filters.Num(), 2);
	TestEqual(TEXT("Debugger smoke protocol should report two filter titles"), BreakFilters->FilterTitles.Num(), 2);

	TMap<FString, FString> ActualPairs;
	for (int32 Index = 0; Index < BreakFilters->Filters.Num() && Index < BreakFilters->FilterTitles.Num(); ++Index)
	{
		ActualPairs.Add(BreakFilters->Filters[Index], BreakFilters->FilterTitles[Index]);
	}

	TestEqual(TEXT("Debugger smoke protocol should preserve two unique filter/title pairs"), ActualPairs.Num(), 2);

	const FString* EnsureTitle = ActualPairs.Find(TEXT("break:ensure"));
	if (!TestNotNull(TEXT("Debugger smoke protocol should include the break:ensure filter"), EnsureTitle))
	{
		return false;
	}
	TestEqual(TEXT("Debugger smoke protocol should preserve the break:ensure title"), *EnsureTitle, FString(TEXT("Ensure")));

	const FString* ScriptTitle = ActualPairs.Find(TEXT("break:script"));
	if (!TestNotNull(TEXT("Debugger smoke protocol should include the break:script filter"), ScriptTitle))
	{
		return false;
	}
	TestEqual(TEXT("Debugger smoke protocol should preserve the break:script title"), *ScriptTitle, FString(TEXT("Script")));
	return !HasAnyErrors();
}

#endif

