#include "Shared/AngelscriptDebuggerScriptFixture.h"
#include "Shared/AngelscriptDebuggerTestClient.h"
#include "Shared/AngelscriptDebuggerTestSession.h"
#include "Shared/AngelscriptTestEngineHelper.h"

#include "Async/Async.h"
#include "HAL/PlatformProcess.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Debugger_AngelscriptDebuggerDataBreakpointTests_Private
{
	FAngelscriptDebuggerScriptFixture CreateDataBreakpointFixture()
	{
		FAngelscriptDebuggerScriptFixture Fixture;
		Fixture.ModuleName = TEXT("DebuggerDataBreakpointFixture");
		Fixture.GeneratedClassName = NAME_None;
		Fixture.EntryFunctionName = NAME_None;
		Fixture.EntryFunctionDeclaration = TEXT("int RunScenario()");
		Fixture.Filename = TEXT("DebuggerDataBreakpointFixture.as");
		Fixture.ScriptSource = TEXT(R"AS(int Inner(int Value)
{
	int StoredValue = 9;

	int InnerValue = Value + StoredValue;
	return InnerValue;
}

int RunScenario()
{
	int Result = Inner(4);
	/*MARK:StepAfterCallLine*/ Result += 1;
	/*MARK:PostMutationLine*/ int Snapshot = Result;
	return Snapshot;
}
)AS");
		Fixture.LineMarkers.Add(TEXT("StepAfterCallLine"), 12);
		Fixture.LineMarkers.Add(TEXT("PostMutationLine"), 13);
		Fixture.EvalPaths.Add(TEXT("ResultPath"), TEXT("0:Result"));
		Fixture.bUseAnnotatedCompilation = false;
		return Fixture;
	}

	bool StartDataBreakpointDebuggerSession(FAutomationTestBase& Test, FAngelscriptDebuggerTestSession& Session, FAngelscriptDebuggerTestClient& Client)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.
		SessionConfig.DefaultTimeoutSeconds = 45.0f;

		if (!Test.TestTrue(TEXT("Debugger data breakpoint should initialize the debugger session"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger data breakpoint should connect the control client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		bool bSentStartDebugging = false;
		const bool bStartMessageSent = Session.PumpUntil(
			[&Client, &bSentStartDebugging]()
			{
				if (bSentStartDebugging)
				{
					return true;
				}

				bSentStartDebugging = Client.SendStartDebugging(2);
				return bSentStartDebugging;
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Debugger data breakpoint should send StartDebugging"), bStartMessageSent))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		TOptional<FAngelscriptDebugMessageEnvelope> VersionEnvelope;
		const bool bReceivedVersion = Session.PumpUntil(
			[&Client, &VersionEnvelope]()
			{
				TOptional<FAngelscriptDebugMessageEnvelope> Envelope = Client.ReceiveEnvelope();
				if (Envelope.IsSet() && Envelope->MessageType == EDebugMessageType::DebugServerVersion)
				{
					VersionEnvelope = MoveTemp(Envelope);
					return true;
				}

				return false;
			},
			Session.GetDefaultTimeoutSeconds());

		if (!Test.TestTrue(TEXT("Debugger data breakpoint should receive DebugServerVersion"), bReceivedVersion))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		return true;
	}

	bool WaitForDebuggerBreakpointCount(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		int32 ExpectedCount,
		const TCHAR* Context)
	{
		const bool bReachedCount = Session.PumpUntil(
			[&Session, ExpectedCount]()
			{
				return Session.GetDebugServer().BreakpointCount == ExpectedCount;
			},
			Session.GetDefaultTimeoutSeconds());

		if (!bReachedCount)
		{
			Test.AddError(FString::Printf(TEXT("%s (actual breakpoint count: %d)."), Context, Session.GetDebugServer().BreakpointCount));
		}

		return bReachedCount;
	}

	struct FAsyncDataBreakpointInvocationState : public TSharedFromThis<FAsyncDataBreakpointInvocationState>
	{
		TAtomic<bool> bCompleted = false;
		bool bSucceeded = false;
		int32 Result = 0;
	};

	TSharedRef<FAsyncDataBreakpointInvocationState> DispatchDataBreakpointInvocation(
		FAngelscriptEngine& Engine,
		const FString& Filename,
		FName ModuleName,
		const FString& Declaration)
	{
		TSharedRef<FAsyncDataBreakpointInvocationState> State = MakeShared<FAsyncDataBreakpointInvocationState>();

		AsyncTask(ENamedThreads::GameThread, [&Engine, Filename, ModuleName, Declaration, State]()
		{
			int32 InvocationResult = 0;
			State->bSucceeded = ExecuteIntFunction(&Engine, Filename, ModuleName, Declaration, InvocationResult);
			State->Result = InvocationResult;
			State->bCompleted = true;
		});

		return State;
	}

	bool WaitForDataBreakpointInvocationCompletion(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		const TSharedRef<FAsyncDataBreakpointInvocationState>& InvocationState,
		const TCHAR* Context)
	{
		const bool bCompleted = Session.PumpUntil(
			[&InvocationState]()
			{
				return InvocationState->bCompleted.Load();
			},
			Session.GetDefaultTimeoutSeconds());

		return Test.TestTrue(Context, bCompleted);
	}

	bool WaitForMonitorReady(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		TAtomic<bool>& bMonitorReady,
		const TCHAR* Context)
	{
		const bool bReady = Session.PumpUntil(
			[&bMonitorReady]()
			{
				return bMonitorReady.Load();
			},
			Session.GetDefaultTimeoutSeconds());

		return Test.TestTrue(Context, bReady);
	}

	bool HandshakeMonitorClient(
		FAngelscriptDebuggerTestClient& Client,
		TAtomic<bool>& bShouldStop,
		float TimeoutSeconds,
		FString& OutError)
	{
		const double HandshakeEnd = FPlatformTime::Seconds() + TimeoutSeconds;
		bool bSentStart = false;
		bool bReceivedVersion = false;
		while (FPlatformTime::Seconds() < HandshakeEnd && !bShouldStop.Load())
		{
			if (!bSentStart)
			{
				bSentStart = Client.SendStartDebugging(2);
				if (!bSentStart)
				{
					OutError = FString::Printf(TEXT("Monitor failed to send StartDebugging: %s"), *Client.GetLastError());
					return false;
				}
			}

			TOptional<FAngelscriptDebugMessageEnvelope> Envelope = Client.ReceiveEnvelope();
			if (Envelope.IsSet())
			{
				if (Envelope->MessageType == EDebugMessageType::DebugServerVersion)
				{
					bReceivedVersion = true;
					break;
				}
			}
			else if (!Client.GetLastError().IsEmpty())
			{
				OutError = FString::Printf(TEXT("Monitor failed during handshake: %s"), *Client.GetLastError());
				return false;
			}

			FPlatformProcess::Sleep(0.001f);
		}

		if (!bReceivedVersion)
		{
			OutError = bShouldStop.Load()
				? TEXT("Monitor handshake aborted before receiving DebugServerVersion.")
				: TEXT("Monitor timed out waiting for DebugServerVersion.");
			return false;
		}

		return true;
	}

	template <typename T>
	bool WaitForTypedMessageUntil(
		FAngelscriptDebuggerTestClient& Client,
		TAtomic<bool>& bShouldStop,
		EDebugMessageType ExpectedType,
		float TimeoutSeconds,
		TOptional<T>& OutValue,
		FString& OutError,
		const TCHAR* Context)
	{
		const double EndTime = FPlatformTime::Seconds() + TimeoutSeconds;
		while (FPlatformTime::Seconds() < EndTime && !bShouldStop.Load())
		{
			TOptional<FAngelscriptDebugMessageEnvelope> Envelope = Client.ReceiveEnvelope();
			if (Envelope.IsSet())
			{
				if (Envelope->MessageType == ExpectedType)
				{
					OutValue = FAngelscriptDebuggerTestClient::DeserializeMessage<T>(Envelope.GetValue());
					if (!OutValue.IsSet())
					{
						OutError = FString::Printf(TEXT("%s: failed to deserialize debugger message type %d."), Context, static_cast<int32>(ExpectedType));
						return false;
					}

					return true;
				}
			}
			else if (!Client.GetLastError().IsEmpty())
			{
				OutError = FString::Printf(TEXT("%s: %s"), Context, *Client.GetLastError());
				return false;
			}

			FPlatformProcess::Sleep(0.001f);
		}

		OutError = bShouldStop.Load()
			? FString::Printf(TEXT("%s: aborted while waiting for debugger message type %d."), Context, static_cast<int32>(ExpectedType))
			: FString::Printf(TEXT("%s: timed out waiting for debugger message type %d."), Context, static_cast<int32>(ExpectedType));
		return false;
	}

	struct FDataBreakpointMonitorResult
	{
		TOptional<FStoppedMessage> InitialStopMessage;
		TOptional<FAngelscriptVariable> ResultVariable;
		TOptional<FStoppedMessage> DataBreakpointStopMessage;
		TOptional<FAngelscriptClearDataBreakpoints> ClearDataBreakpoints;
		bool bTimedOut = false;
		FString Error;
	};

	TFuture<FDataBreakpointMonitorResult> StartDataBreakpointMonitor(
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		const FAngelscriptDebuggerScriptFixture& Fixture,
		float TimeoutSeconds)
	{
		return Async(EAsyncExecution::ThreadPool,
			[Port, &bMonitorReady, &bShouldStop, Fixture, TimeoutSeconds]() -> FDataBreakpointMonitorResult
			{
				FDataBreakpointMonitorResult Result;
				FAngelscriptDebuggerTestClient MonitorClient;
				ON_SCOPE_EXIT
				{
					MonitorClient.SendStopDebugging();
					MonitorClient.SendDisconnect();
					MonitorClient.Disconnect();
				};

				if (!MonitorClient.Connect(TEXT("127.0.0.1"), Port))
				{
					Result.Error = FString::Printf(TEXT("Data breakpoint monitor failed to connect: %s"), *MonitorClient.GetLastError());
					bMonitorReady = true;
					return Result;
				}

				if (!HandshakeMonitorClient(MonitorClient, bShouldStop, TimeoutSeconds, Result.Error))
				{
					Result.bTimedOut = !bShouldStop.Load();
					bMonitorReady = true;
					return Result;
				}

				bMonitorReady = true;

				if (!WaitForTypedMessageUntil(MonitorClient, bShouldStop, EDebugMessageType::HasStopped, TimeoutSeconds, Result.InitialStopMessage, Result.Error, TEXT("Data breakpoint monitor failed to receive the initial stop")))
				{
					Result.bTimedOut = !bShouldStop.Load();
					return Result;
				}

				if (!MonitorClient.SendRequestEvaluate(Fixture.GetEvalPath(TEXT("ResultPath"))))
				{
					Result.Error = FString::Printf(TEXT("Data breakpoint monitor failed to request evaluate for Result: %s"), *MonitorClient.GetLastError());
					return Result;
				}

				if (!WaitForTypedMessageUntil(MonitorClient, bShouldStop, EDebugMessageType::Evaluate, TimeoutSeconds, Result.ResultVariable, Result.Error, TEXT("Data breakpoint monitor failed to receive evaluate reply for Result")))
				{
					Result.bTimedOut = !bShouldStop.Load();
					return Result;
				}

				if (Result.ResultVariable->ValueAddress == 0 || Result.ResultVariable->ValueSize == 0)
				{
					Result.Error = FString::Printf(
						TEXT("Data breakpoint monitor received a non-monitorable evaluate reply for Result (Address=%llu, Size=%u)."),
						static_cast<unsigned long long>(Result.ResultVariable->ValueAddress),
						static_cast<uint32>(Result.ResultVariable->ValueSize));
					return Result;
				}

				FAngelscriptDataBreakpoints DataBreakpoints;
				FAngelscriptDataBreakpoint DataBreakpoint;
				DataBreakpoint.Id = 11;
				DataBreakpoint.Address = Result.ResultVariable->ValueAddress;
				DataBreakpoint.AddressSize = Result.ResultVariable->ValueSize;
				DataBreakpoint.HitCount = 1;
				DataBreakpoint.Name = TEXT("Result");
				DataBreakpoints.Breakpoints.Add(DataBreakpoint);
				if (!MonitorClient.SendTypedMessage(EDebugMessageType::SetDataBreakpoints, DataBreakpoints))
				{
					Result.Error = FString::Printf(TEXT("Data breakpoint monitor failed to send SetDataBreakpoints: %s"), *MonitorClient.GetLastError());
					return Result;
				}

				if (!MonitorClient.SendContinue())
				{
					Result.Error = FString::Printf(TEXT("Data breakpoint monitor failed to continue from the initial breakpoint stop: %s"), *MonitorClient.GetLastError());
					return Result;
				}

				if (!WaitForTypedMessageUntil(MonitorClient, bShouldStop, EDebugMessageType::HasStopped, TimeoutSeconds, Result.DataBreakpointStopMessage, Result.Error, TEXT("Data breakpoint monitor failed to receive the data breakpoint stop")))
				{
					Result.bTimedOut = !bShouldStop.Load();
					return Result;
				}

				if (!MonitorClient.SendContinue())
				{
					Result.Error = FString::Printf(TEXT("Data breakpoint monitor failed to continue from the data breakpoint stop: %s"), *MonitorClient.GetLastError());
					return Result;
				}

				if (!WaitForTypedMessageUntil(MonitorClient, bShouldStop, EDebugMessageType::ClearDataBreakpoints, TimeoutSeconds, Result.ClearDataBreakpoints, Result.Error, TEXT("Data breakpoint monitor failed to receive ClearDataBreakpoints")))
				{
					Result.bTimedOut = !bShouldStop.Load();
					return Result;
				}

				return Result;
			});
	}

	struct FPassiveBreakpointMonitorResult
	{
		TArray<FStoppedMessage> StopMessages;
		bool bTimedOut = false;
		FString Error;
	};

	TFuture<FPassiveBreakpointMonitorResult> StartPassiveBreakpointMonitor(
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		float TimeoutSeconds)
	{
		return Async(EAsyncExecution::ThreadPool,
			[Port, &bMonitorReady, &bShouldStop, TimeoutSeconds]() -> FPassiveBreakpointMonitorResult
			{
				FPassiveBreakpointMonitorResult Result;
				FAngelscriptDebuggerTestClient MonitorClient;
				ON_SCOPE_EXIT
				{
					MonitorClient.SendStopDebugging();
					MonitorClient.SendDisconnect();
					MonitorClient.Disconnect();
				};

				if (!MonitorClient.Connect(TEXT("127.0.0.1"), Port))
				{
					Result.Error = FString::Printf(TEXT("Passive breakpoint monitor failed to connect: %s"), *MonitorClient.GetLastError());
					bMonitorReady = true;
					return Result;
				}

				if (!HandshakeMonitorClient(MonitorClient, bShouldStop, TimeoutSeconds, Result.Error))
				{
					Result.bTimedOut = !bShouldStop.Load();
					bMonitorReady = true;
					return Result;
				}

				bMonitorReady = true;

				const double EndTime = FPlatformTime::Seconds() + TimeoutSeconds;
				while (FPlatformTime::Seconds() < EndTime && !bShouldStop.Load())
				{
					TOptional<FAngelscriptDebugMessageEnvelope> Envelope = MonitorClient.ReceiveEnvelope();
					if (Envelope.IsSet())
					{
						if (Envelope->MessageType == EDebugMessageType::HasStopped)
						{
							TOptional<FStoppedMessage> StopMessage = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(Envelope.GetValue());
							if (!StopMessage.IsSet())
							{
								Result.Error = TEXT("Passive breakpoint monitor failed to deserialize a HasStopped payload.");
								return Result;
							}

							Result.StopMessages.Add(StopMessage.GetValue());
							MonitorClient.SendContinue();
						}
					}
					else if (!MonitorClient.GetLastError().IsEmpty())
					{
						Result.Error = FString::Printf(TEXT("Passive breakpoint monitor failed while polling: %s"), *MonitorClient.GetLastError());
						return Result;
					}

					FPlatformProcess::Sleep(0.001f);
				}

				if (!bShouldStop.Load() && FPlatformTime::Seconds() >= EndTime)
				{
					Result.bTimedOut = true;
				}

				return Result;
			});
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerDataBreakpointTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerDataBreakpointLocalValueHitCountTest,
	"Angelscript.TestModule.Debugger.DataBreakpoint.LocalValueHitCount",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerDataBreakpointLocalValueHitCountTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartDataBreakpointDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Session.GetEngine();
	const FAngelscriptDebuggerScriptFixture Fixture = CreateDataBreakpointFixture();
	FAngelscriptClearBreakpoints ClearBreakpoints;
	ClearBreakpoints.Filename = Fixture.Filename;
	ClearBreakpoints.ModuleName = Fixture.ModuleName.ToString();

	ON_SCOPE_EXIT
	{
		Client.SendClearBreakpoints(ClearBreakpoints);
		Client.SendStopDebugging();
		Client.SendDisconnect();
		Client.Disconnect();
		Engine.DiscardModule(*Fixture.ModuleName.ToString());
		CollectGarbage(RF_NoFlags, true);
	};

	if (!TestTrue(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should compile the data breakpoint fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	TAtomic<bool> bDataMonitorReady(false);
	TAtomic<bool> bDataMonitorShouldStop(false);
	TFuture<FDataBreakpointMonitorResult> DataMonitorFuture = StartDataBreakpointMonitor(
		Session.GetPort(),
		bDataMonitorReady,
		bDataMonitorShouldStop,
		Fixture,
		Session.GetDefaultTimeoutSeconds());
	ON_SCOPE_EXIT
	{
		bDataMonitorShouldStop = true;
		if (DataMonitorFuture.IsValid())
		{
			DataMonitorFuture.Wait();
		}
	};

	if (!WaitForMonitorReady(*this, Session, bDataMonitorReady, TEXT("Debugger.DataBreakpoint.LocalValueHitCount should bring the data breakpoint monitor up before execution")))
	{
		return false;
	}

	FAngelscriptBreakpoint Breakpoint;
	Breakpoint.Filename = Fixture.Filename;
	Breakpoint.ModuleName = Fixture.ModuleName.ToString();
	Breakpoint.LineNumber = Fixture.GetLine(TEXT("StepAfterCallLine"));
	if (!TestTrue(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should set the step-after-call breakpoint"), Client.SendSetBreakpoint(Breakpoint)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForDebuggerBreakpointCount(*this, Session, 1, TEXT("Debugger.DataBreakpoint.LocalValueHitCount should observe the line breakpoint registration")))
	{
		return false;
	}

	const TSharedRef<FAsyncDataBreakpointInvocationState> FirstInvocation = DispatchDataBreakpointInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration);
	if (!WaitForDataBreakpointInvocationCompletion(*this, Session, FirstInvocation, TEXT("Debugger.DataBreakpoint.LocalValueHitCount should finish the first invocation after the monitor resumes execution")))
	{
		return false;
	}

	const FDataBreakpointMonitorResult DataMonitorResult = DataMonitorFuture.Get();

	if (!TestTrue(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should finish the data breakpoint monitor without transport errors"), DataMonitorResult.Error.IsEmpty()))
	{
		AddError(DataMonitorResult.Error);
		return false;
	}

	if (!TestFalse(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should not time out while driving the data breakpoint sequence"), DataMonitorResult.bTimedOut))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should capture the initial breakpoint stop"), DataMonitorResult.InitialStopMessage.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should capture the evaluate reply for Result"), DataMonitorResult.ResultVariable.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should capture the data breakpoint stop"), DataMonitorResult.DataBreakpointStopMessage.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should capture the ClearDataBreakpoints reply"), DataMonitorResult.ClearDataBreakpoints.IsSet()))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should stop initially because of the explicit line breakpoint"), DataMonitorResult.InitialStopMessage->Reason, FString(TEXT("breakpoint")));
	TestEqual(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should evaluate Result before mutation"), DataMonitorResult.ResultVariable->Value, FString(TEXT("13")));
	TestTrue(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should expose a non-zero ValueAddress for Result"), DataMonitorResult.ResultVariable->ValueAddress != 0);
	TestTrue(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should expose a positive ValueSize for Result"), DataMonitorResult.ResultVariable->ValueSize > 0);
	TestEqual(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should stop because of an exception when the data breakpoint fires"), DataMonitorResult.DataBreakpointStopMessage->Reason, FString(TEXT("exception")));
	TestTrue(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should report the data breakpoint name in the stop text"), DataMonitorResult.DataBreakpointStopMessage->Text.Contains(TEXT("Data breakpoint (Result) triggered!")));
	TestEqual(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should clear exactly one data breakpoint"), DataMonitorResult.ClearDataBreakpoints->Ids.Num(), 1);
	TestEqual(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should clear the hit-count-limited data breakpoint id"), DataMonitorResult.ClearDataBreakpoints->Ids[0], 11);
	TestTrue(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should complete the first invocation successfully"), FirstInvocation->bSucceeded);
	TestEqual(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should preserve the first invocation result"), FirstInvocation->Result, 14);

	if (!TestTrue(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should clear the line breakpoint before the second invocation"), Client.SendClearBreakpoints(ClearBreakpoints)))
	{
		AddError(Client.GetLastError());
		return false;
	}

	if (!WaitForDebuggerBreakpointCount(*this, Session, 0, TEXT("Debugger.DataBreakpoint.LocalValueHitCount should observe the breakpoint removal before the second invocation")))
	{
		return false;
	}

	Client.DrainPendingMessages();

	TAtomic<bool> bPassiveMonitorReady(false);
	TAtomic<bool> bPassiveMonitorShouldStop(false);
	TFuture<FPassiveBreakpointMonitorResult> PassiveMonitorFuture = StartPassiveBreakpointMonitor(
		Session.GetPort(),
		bPassiveMonitorReady,
		bPassiveMonitorShouldStop,
		Session.GetDefaultTimeoutSeconds());
	ON_SCOPE_EXIT
	{
		bPassiveMonitorShouldStop = true;
		if (PassiveMonitorFuture.IsValid())
		{
			PassiveMonitorFuture.Wait();
		}
	};

	if (!WaitForMonitorReady(*this, Session, bPassiveMonitorReady, TEXT("Debugger.DataBreakpoint.LocalValueHitCount should bring the passive monitor up before the second invocation")))
	{
		return false;
	}

	const TSharedRef<FAsyncDataBreakpointInvocationState> SecondInvocation = DispatchDataBreakpointInvocation(
		Engine,
		Fixture.Filename,
		Fixture.ModuleName,
		Fixture.EntryFunctionDeclaration);
	if (!WaitForDataBreakpointInvocationCompletion(*this, Session, SecondInvocation, TEXT("Debugger.DataBreakpoint.LocalValueHitCount should finish the second invocation without any debugger stop")))
	{
		return false;
	}

	bPassiveMonitorShouldStop = true;
	const FPassiveBreakpointMonitorResult PassiveMonitorResult = PassiveMonitorFuture.Get();

	if (!TestTrue(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should keep the passive monitor error-free on the second invocation"), PassiveMonitorResult.Error.IsEmpty()))
	{
		AddError(PassiveMonitorResult.Error);
		return false;
	}

	if (!TestFalse(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should not time out while passively watching the second invocation"), PassiveMonitorResult.bTimedOut))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should not stop again after the hit-count-limited data breakpoint auto-clears"), PassiveMonitorResult.StopMessages.Num(), 0);
	TestTrue(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should complete the second invocation successfully"), SecondInvocation->bSucceeded);
	TestEqual(TEXT("Debugger.DataBreakpoint.LocalValueHitCount should preserve the second invocation result"), SecondInvocation->Result, 14);
	return !HasAnyErrors();
}

#endif

