#include "Shared/AngelscriptDebuggerScriptFixture.h"
#include "Shared/AngelscriptDebuggerTestClient.h"
#include "Shared/AngelscriptDebuggerTestSession.h"

#include "Async/Async.h"
#include "HAL/PlatformProcess.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"
#include "UObject/UObjectGlobals.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Debugger_AngelscriptDebuggerBindingTests_Private
{
	bool StartBindingDebuggerSession(FAutomationTestBase& Test, FAngelscriptDebuggerTestSession& Session, FAngelscriptDebuggerTestClient& Client)
	{
		FAngelscriptDebuggerSessionConfig SessionConfig;
		// UE 5.7: headless has no production subsystem. Let Initialize() create
		// an isolated FAngelscriptEngine with its own FAngelscriptDebugServer.
		SessionConfig.DefaultTimeoutSeconds = 45.0f;

		if (!Test.TestTrue(TEXT("Debugger binding should initialize against the debuggable production engine"), Session.Initialize(SessionConfig)))
		{
			return false;
		}

		if (!Test.TestTrue(TEXT("Debugger binding should connect the primary debugger client"), Client.Connect(TEXT("127.0.0.1"), Session.GetPort())))
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

		if (!Test.TestTrue(TEXT("Debugger binding should send StartDebugging before invoking the binding fixture"), bStartMessageSent))
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

		if (!Test.TestTrue(TEXT("Debugger binding should receive the DebugServerVersion response"), bReceivedVersion))
		{
			Test.AddError(Client.GetLastError());
			return false;
		}

		return true;
	}

	template <typename TInvocationState>
	bool WaitForBindingInvocationCompletion(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		const TSharedRef<TInvocationState>& InvocationState,
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

	bool HandshakeBindingMonitorClient(
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
					OutError = FString::Printf(TEXT("Binding monitor failed to send StartDebugging: %s"), *Client.GetLastError());
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
				OutError = FString::Printf(TEXT("Binding monitor failed during handshake: %s"), *Client.GetLastError());
				return false;
			}

			FPlatformProcess::Sleep(0.001f);
		}

		if (!bReceivedVersion)
		{
			OutError = bShouldStop.Load()
				? TEXT("Binding monitor handshake aborted before receiving DebugServerVersion.")
				: TEXT("Binding monitor timed out waiting for DebugServerVersion.");
			return false;
		}

		return true;
	}

	template <typename T>
	bool WaitForTypedBindingMessage(
		FAngelscriptDebuggerTestClient& Client,
		EDebugMessageType ExpectedType,
		float TimeoutSeconds,
		TOptional<T>& OutValue,
		FString& OutError,
		const TCHAR* Context)
	{
		OutValue = Client.WaitForTypedMessage<T>(ExpectedType, TimeoutSeconds);
		if (!OutValue.IsSet())
		{
			OutError = FString::Printf(TEXT("%s: %s"), Context, *Client.GetLastError());
			return false;
		}

		return true;
	}

	struct FBindingStopMonitorResult
	{
		TArray<FAngelscriptDebugMessageEnvelope> StopEnvelopes;
		TOptional<FStoppedMessage> StopMessage;
		TOptional<FAngelscriptCallStack> Callstack;
		int32 ContinuedCount = 0;
		bool bTimedOut = false;
		FString Error;
	};

	struct FBindingNoStopMonitorResult
	{
		int32 UnexpectedStopCount = 0;
		int32 ContinuedCount = 0;
		bool bTimedOut = false;
		FString Error;
	};

	TFuture<FBindingStopMonitorResult> StartBindingStopMonitor(
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		float TimeoutSeconds)
	{
		return Async(EAsyncExecution::ThreadPool,
			[Port, &bMonitorReady, &bShouldStop, TimeoutSeconds]() -> FBindingStopMonitorResult
			{
				FBindingStopMonitorResult Result;
				FAngelscriptDebuggerTestClient MonitorClient;
				ON_SCOPE_EXIT
				{
					MonitorClient.SendStopDebugging();
					MonitorClient.SendDisconnect();
					MonitorClient.Disconnect();
				};

				if (!MonitorClient.Connect(TEXT("127.0.0.1"), Port))
				{
					Result.Error = FString::Printf(TEXT("Binding monitor failed to connect: %s"), *MonitorClient.GetLastError());
					bMonitorReady = true;
					return Result;
				}

				if (!HandshakeBindingMonitorClient(MonitorClient, bShouldStop, TimeoutSeconds, Result.Error))
				{
					Result.bTimedOut = !bShouldStop.Load();
					bMonitorReady = true;
					return Result;
				}

				bMonitorReady = true;

				TOptional<FAngelscriptDebugMessageEnvelope> StopEnvelope = MonitorClient.WaitForMessageType(EDebugMessageType::HasStopped, TimeoutSeconds);
				if (!StopEnvelope.IsSet())
				{
					Result.Error = FString::Printf(TEXT("Binding monitor timed out waiting for HasStopped: %s"), *MonitorClient.GetLastError());
					Result.bTimedOut = !bShouldStop.Load();
					return Result;
				}

				Result.StopEnvelopes.Add(StopEnvelope.GetValue());
				Result.StopMessage = FAngelscriptDebuggerTestClient::DeserializeMessage<FStoppedMessage>(StopEnvelope.GetValue());
				if (!Result.StopMessage.IsSet())
				{
					Result.Error = TEXT("Binding monitor failed to deserialize the HasStopped payload.");
					return Result;
				}

				if (!MonitorClient.SendRequestCallStack() ||
					!WaitForTypedBindingMessage(MonitorClient, EDebugMessageType::CallStack, TimeoutSeconds, Result.Callstack, Result.Error, TEXT("Binding monitor failed to receive CallStack")))
				{
					Result.bTimedOut = !bShouldStop.Load();
					return Result;
				}

				if (!MonitorClient.SendContinue())
				{
					Result.Error = FString::Printf(TEXT("Binding monitor failed to send Continue: %s"), *MonitorClient.GetLastError());
					return Result;
				}

				TOptional<FEmptyMessage> ContinuedMessage;
				if (!WaitForTypedBindingMessage(MonitorClient, EDebugMessageType::HasContinued, TimeoutSeconds, ContinuedMessage, Result.Error, TEXT("Binding monitor failed to receive HasContinued")))
				{
					Result.bTimedOut = !bShouldStop.Load();
					return Result;
				}

				Result.ContinuedCount = 1;
				return Result;
			});
	}

	TFuture<FBindingNoStopMonitorResult> StartBindingNoStopMonitor(
		int32 Port,
		TAtomic<bool>& bMonitorReady,
		TAtomic<bool>& bShouldStop,
		TAtomic<bool>& bInvocationCompleted,
		float TimeoutSeconds)
	{
		return Async(EAsyncExecution::ThreadPool,
			[Port, &bMonitorReady, &bShouldStop, &bInvocationCompleted, TimeoutSeconds]() -> FBindingNoStopMonitorResult
			{
				FBindingNoStopMonitorResult Result;
				FAngelscriptDebuggerTestClient MonitorClient;
				ON_SCOPE_EXIT
				{
					MonitorClient.SendStopDebugging();
					MonitorClient.SendDisconnect();
					MonitorClient.Disconnect();
				};

				if (!MonitorClient.Connect(TEXT("127.0.0.1"), Port))
				{
					Result.Error = FString::Printf(TEXT("Binding no-stop monitor failed to connect: %s"), *MonitorClient.GetLastError());
					bMonitorReady = true;
					return Result;
				}

				if (!HandshakeBindingMonitorClient(MonitorClient, bShouldStop, TimeoutSeconds, Result.Error))
				{
					Result.bTimedOut = !bShouldStop.Load();
					bMonitorReady = true;
					return Result;
				}

				bMonitorReady = true;

				const double EndTime = FPlatformTime::Seconds() + TimeoutSeconds;
				while (FPlatformTime::Seconds() < EndTime && !bShouldStop.Load())
				{
					if (bInvocationCompleted.Load())
					{
						return Result;
					}

					TOptional<FAngelscriptDebugMessageEnvelope> Envelope = MonitorClient.ReceiveEnvelope();
					if (Envelope.IsSet())
					{
						if (Envelope->MessageType == EDebugMessageType::HasStopped)
						{
							++Result.UnexpectedStopCount;
							if (!MonitorClient.SendContinue())
							{
								Result.Error = FString::Printf(TEXT("Binding no-stop monitor failed to send Continue after an unexpected stop: %s"), *MonitorClient.GetLastError());
								return Result;
							}

							TOptional<FEmptyMessage> ContinuedMessage;
							if (!WaitForTypedBindingMessage(MonitorClient, EDebugMessageType::HasContinued, TimeoutSeconds, ContinuedMessage, Result.Error, TEXT("Binding no-stop monitor failed to receive HasContinued after an unexpected stop")))
							{
								Result.bTimedOut = !bShouldStop.Load();
								return Result;
							}

							++Result.ContinuedCount;
						}
					}
					else if (!MonitorClient.GetLastError().IsEmpty())
					{
						Result.Error = FString::Printf(TEXT("Binding no-stop monitor failed while waiting for invocation completion: %s"), *MonitorClient.GetLastError());
						return Result;
					}

					FPlatformProcess::Sleep(0.001f);
				}

				if (!bInvocationCompleted.Load() && !bShouldStop.Load())
				{
					Result.bTimedOut = true;
					Result.Error = TEXT("Binding no-stop monitor timed out waiting for invocation completion.");
				}

				return Result;
			});
	}

	bool WaitForBindingMonitorReady(
		FAutomationTestBase& Test,
		FAngelscriptDebuggerTestSession& Session,
		TAtomic<bool>& bMonitorReady,
		const TCHAR* Context)
	{
		return Test.TestTrue(
			Context,
			Session.PumpUntil(
				[&bMonitorReady]()
				{
					return bMonitorReady.Load();
				},
				Session.GetDefaultTimeoutSeconds()));
	}

	struct FBindingFixtureRuntime
	{
		UClass* GeneratedClass = nullptr;
		UFunction* TriggerDebugBreakFunction = nullptr;
		UFunction* TriggerEnsureFunction = nullptr;
		UObject* Object = nullptr;
	};

	bool ResolveBindingFixtureRuntime(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FAngelscriptDebuggerScriptFixture& Fixture,
		FBindingFixtureRuntime& OutRuntime)
	{
		OutRuntime.GeneratedClass = Fixture.FindGeneratedClass(Engine);
		if (!Test.TestNotNull(TEXT("Debugger.Binding.DebugBreakAndEnsure should resolve the generated binding fixture class"), OutRuntime.GeneratedClass))
		{
			return false;
		}

		OutRuntime.TriggerDebugBreakFunction = Fixture.FindGeneratedFunction(Engine, TEXT("TriggerDebugBreak"));
		if (!Test.TestNotNull(TEXT("Debugger.Binding.DebugBreakAndEnsure should resolve TriggerDebugBreak on the generated binding fixture"), OutRuntime.TriggerDebugBreakFunction))
		{
			return false;
		}

		OutRuntime.TriggerEnsureFunction = Fixture.FindGeneratedFunction(Engine, TEXT("TriggerEnsure"));
		if (!Test.TestNotNull(TEXT("Debugger.Binding.DebugBreakAndEnsure should resolve TriggerEnsure on the generated binding fixture"), OutRuntime.TriggerEnsureFunction))
		{
			return false;
		}

		OutRuntime.Object = NewObject<UObject>(GetTransientPackage(), OutRuntime.GeneratedClass);
		return Test.TestNotNull(TEXT("Debugger.Binding.DebugBreakAndEnsure should create a runtime UObject from the generated binding fixture class"), OutRuntime.Object);
	}

	struct FBindingCheckFixtureRuntime
	{
		UFunction* TriggerCheckFunction = nullptr;
		UObject* Object = nullptr;
	};

	bool ResolveBindingCheckFixtureRuntime(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FAngelscriptDebuggerScriptFixture& Fixture,
		FBindingCheckFixtureRuntime& OutRuntime)
	{
		UClass* GeneratedClass = Fixture.FindGeneratedClass(Engine);
		if (!Test.TestNotNull(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should resolve the generated binding fixture class"), GeneratedClass))
		{
			return false;
		}

		OutRuntime.TriggerCheckFunction = Fixture.FindGeneratedFunction(Engine, TEXT("TriggerCheck"));
		if (!Test.TestNotNull(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should resolve TriggerCheck on the generated binding fixture"), OutRuntime.TriggerCheckFunction))
		{
			return false;
		}

		OutRuntime.Object = NewObject<UObject>(GetTransientPackage(), GeneratedClass);
		return Test.TestNotNull(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should create a runtime UObject from the generated binding fixture class"), OutRuntime.Object);
	}
}

using namespace AngelscriptTest_Debugger_AngelscriptDebuggerBindingTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerBindingDebugBreakAndEnsureTest,
	"Angelscript.TestModule.Debugger.Binding.DebugBreakAndEnsure",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerBindingDebugBreakAndEnsureTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartBindingDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	const FAngelscriptDebuggerScriptFixture Fixture = FAngelscriptDebuggerScriptFixture::CreateBindingFixture();
	FAngelscriptEngine& Engine = Session.GetEngine();

	ON_SCOPE_EXIT
	{
		Client.SendStopDebugging();
		Client.SendDisconnect();
		Client.Disconnect();
		Engine.DiscardModule(*Fixture.ModuleName.ToString());
		CollectGarbage(RF_NoFlags, true);
	};

	if (!TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should compile the binding fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	FBindingFixtureRuntime Runtime;
	if (!ResolveBindingFixtureRuntime(*this, Engine, Fixture, Runtime))
	{
		return false;
	}

	FBindingStopMonitorResult DebugBreakMonitorResult;
	bool bDebugBreakInvocationSucceeded = false;
	{
		Client.DrainPendingMessages();

		TAtomic<bool> bMonitorReady(false);
		TAtomic<bool> bMonitorShouldStop(false);
		TFuture<FBindingStopMonitorResult> MonitorFuture = StartBindingStopMonitor(
			Session.GetPort(),
			bMonitorReady,
			bMonitorShouldStop,
			Session.GetDefaultTimeoutSeconds());
		ON_SCOPE_EXIT
		{
			bMonitorShouldStop = true;
			if (MonitorFuture.IsValid())
			{
				MonitorFuture.Wait();
			}
		};

		if (!WaitForBindingMonitorReady(*this, Session, bMonitorReady, TEXT("Debugger.Binding.DebugBreakAndEnsure should bring the debug-break monitor up before invoking TriggerDebugBreak")))
		{
			return false;
		}

		const TSharedRef<FAsyncGeneratedVoidInvocationState> InvocationState = DispatchGeneratedVoidInvocation(
			Engine,
			Runtime.Object,
			Runtime.TriggerDebugBreakFunction);
		if (!WaitForBindingInvocationCompletion(*this, Session, InvocationState, TEXT("Debugger.Binding.DebugBreakAndEnsure should finish TriggerDebugBreak after the monitor resumes execution")))
		{
			return false;
		}

		bDebugBreakInvocationSucceeded = InvocationState->bSucceeded;
		bMonitorShouldStop = true;
		DebugBreakMonitorResult = MonitorFuture.Get();
	}

	if (!TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should complete the debug-break phase without monitor errors"), DebugBreakMonitorResult.Error.IsEmpty()))
	{
		AddError(DebugBreakMonitorResult.Error);
		return false;
	}

	if (!TestFalse(TEXT("Debugger.Binding.DebugBreakAndEnsure should not time out while monitoring TriggerDebugBreak"), DebugBreakMonitorResult.bTimedOut))
	{
		return false;
	}

	if (!TestEqual(TEXT("Debugger.Binding.DebugBreakAndEnsure should capture exactly one stop for TriggerDebugBreak"), DebugBreakMonitorResult.StopEnvelopes.Num(), 1))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should deserialize the TriggerDebugBreak stop payload"), DebugBreakMonitorResult.StopMessage.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should capture a callstack for TriggerDebugBreak"), DebugBreakMonitorResult.Callstack.IsSet()))
	{
		return false;
	}

	const FAngelscriptCallStack& DebugBreakCallstack = DebugBreakMonitorResult.Callstack.GetValue();
	if (!TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should return at least one frame for TriggerDebugBreak"), DebugBreakCallstack.Frames.Num() > 0))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Binding.DebugBreakAndEnsure should report a breakpoint stop for TriggerDebugBreak"), DebugBreakMonitorResult.StopMessage->Reason, FString(TEXT("breakpoint")));
	TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should report the binding fixture filename for TriggerDebugBreak"), DebugBreakCallstack.Frames[0].Source.EndsWith(Fixture.Filename));
	TestEqual(TEXT("Debugger.Binding.DebugBreakAndEnsure should stop TriggerDebugBreak at BindingDebugBreakLine"), DebugBreakCallstack.Frames[0].LineNumber, Fixture.GetLine(TEXT("BindingDebugBreakLine")));
	TestEqual(TEXT("Debugger.Binding.DebugBreakAndEnsure should observe a single HasContinued after TriggerDebugBreak"), DebugBreakMonitorResult.ContinuedCount, 1);
	TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should execute TriggerDebugBreak successfully after resume"), bDebugBreakInvocationSucceeded);

	AddExpectedError(TEXT("Ensure condition failed: Once"), EAutomationExpectedErrorFlags::Contains, 1);

	FBindingStopMonitorResult EnsureMonitorResult;
	bool bEnsureInvocationSucceeded = false;
	bool bEnsureReturnValue = true;
	{
		Client.DrainPendingMessages();

		TAtomic<bool> bMonitorReady(false);
		TAtomic<bool> bMonitorShouldStop(false);
		TFuture<FBindingStopMonitorResult> MonitorFuture = StartBindingStopMonitor(
			Session.GetPort(),
			bMonitorReady,
			bMonitorShouldStop,
			Session.GetDefaultTimeoutSeconds());
		ON_SCOPE_EXIT
		{
			bMonitorShouldStop = true;
			if (MonitorFuture.IsValid())
			{
				MonitorFuture.Wait();
			}
		};

		if (!WaitForBindingMonitorReady(*this, Session, bMonitorReady, TEXT("Debugger.Binding.DebugBreakAndEnsure should bring the ensure monitor up before invoking TriggerEnsure(false, Once)")))
		{
			return false;
		}

		const TSharedRef<FAsyncGeneratedBoolInvocationState> InvocationState = DispatchGeneratedBoolInvocation(
			Engine,
			Runtime.Object,
			Runtime.TriggerEnsureFunction,
			false,
			TEXT("Once"));
		if (!WaitForBindingInvocationCompletion(*this, Session, InvocationState, TEXT("Debugger.Binding.DebugBreakAndEnsure should finish TriggerEnsure(false, Once) after the monitor resumes execution")))
		{
			return false;
		}

		bEnsureInvocationSucceeded = InvocationState->bSucceeded;
		bEnsureReturnValue = InvocationState->bReturnValue;
		bMonitorShouldStop = true;
		EnsureMonitorResult = MonitorFuture.Get();
	}

	if (!TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should complete the first ensure phase without monitor errors"), EnsureMonitorResult.Error.IsEmpty()))
	{
		AddError(EnsureMonitorResult.Error);
		return false;
	}

	if (!TestFalse(TEXT("Debugger.Binding.DebugBreakAndEnsure should not time out while monitoring TriggerEnsure(false, Once)"), EnsureMonitorResult.bTimedOut))
	{
		return false;
	}

	if (!TestEqual(TEXT("Debugger.Binding.DebugBreakAndEnsure should capture exactly one stop for TriggerEnsure(false, Once)"), EnsureMonitorResult.StopEnvelopes.Num(), 1))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should deserialize the TriggerEnsure(false, Once) stop payload"), EnsureMonitorResult.StopMessage.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should capture a callstack for TriggerEnsure(false, Once)"), EnsureMonitorResult.Callstack.IsSet()))
	{
		return false;
	}

	const FAngelscriptCallStack& EnsureCallstack = EnsureMonitorResult.Callstack.GetValue();
	if (!TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should return at least one frame for TriggerEnsure(false, Once)"), EnsureCallstack.Frames.Num() > 0))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Binding.DebugBreakAndEnsure should report a breakpoint stop for TriggerEnsure(false, Once)"), EnsureMonitorResult.StopMessage->Reason, FString(TEXT("breakpoint")));
	TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should report the binding fixture filename for TriggerEnsure(false, Once)"), EnsureCallstack.Frames[0].Source.EndsWith(Fixture.Filename));
	TestEqual(TEXT("Debugger.Binding.DebugBreakAndEnsure should stop TriggerEnsure(false, Once) at BindingEnsureLine"), EnsureCallstack.Frames[0].LineNumber, Fixture.GetLine(TEXT("BindingEnsureLine")));
	TestEqual(TEXT("Debugger.Binding.DebugBreakAndEnsure should observe a single HasContinued after TriggerEnsure(false, Once)"), EnsureMonitorResult.ContinuedCount, 1);
	TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should execute TriggerEnsure(false, Once) successfully after resume"), bEnsureInvocationSucceeded);
	TestFalse(TEXT("Debugger.Binding.DebugBreakAndEnsure should return false after TriggerEnsure(false, Once)"), bEnsureReturnValue);

	FBindingNoStopMonitorResult EnsureRepeatMonitorResult;
	bool bEnsureRepeatInvocationSucceeded = false;
	bool bEnsureRepeatReturnValue = true;
	{
		Client.DrainPendingMessages();

		TAtomic<bool> bMonitorReady(false);
		TAtomic<bool> bMonitorShouldStop(false);
		TAtomic<bool> bInvocationCompleted(false);
		TFuture<FBindingNoStopMonitorResult> MonitorFuture = StartBindingNoStopMonitor(
			Session.GetPort(),
			bMonitorReady,
			bMonitorShouldStop,
			bInvocationCompleted,
			Session.GetDefaultTimeoutSeconds());
		ON_SCOPE_EXIT
		{
			bMonitorShouldStop = true;
			if (MonitorFuture.IsValid())
			{
				MonitorFuture.Wait();
			}
		};

		if (!WaitForBindingMonitorReady(*this, Session, bMonitorReady, TEXT("Debugger.Binding.DebugBreakAndEnsure should bring the repeat-ensure monitor up before invoking TriggerEnsure(false, Repeat)")))
		{
			return false;
		}

		const TSharedRef<FAsyncGeneratedBoolInvocationState> InvocationState = DispatchGeneratedBoolInvocation(
			Engine,
			Runtime.Object,
			Runtime.TriggerEnsureFunction,
			false,
			TEXT("Repeat"));
		if (!WaitForBindingInvocationCompletion(*this, Session, InvocationState, TEXT("Debugger.Binding.DebugBreakAndEnsure should finish TriggerEnsure(false, Repeat) without needing another stop")))
		{
			return false;
		}

		bEnsureRepeatInvocationSucceeded = InvocationState->bSucceeded;
		bEnsureRepeatReturnValue = InvocationState->bReturnValue;
		bInvocationCompleted = true;
		bMonitorShouldStop = true;
		EnsureRepeatMonitorResult = MonitorFuture.Get();
	}

	if (!TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should complete the repeat ensure phase without monitor errors"), EnsureRepeatMonitorResult.Error.IsEmpty()))
	{
		AddError(EnsureRepeatMonitorResult.Error);
		return false;
	}

	if (!TestFalse(TEXT("Debugger.Binding.DebugBreakAndEnsure should not time out while monitoring TriggerEnsure(false, Repeat)"), EnsureRepeatMonitorResult.bTimedOut))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Binding.DebugBreakAndEnsure should not emit another stop for the same ensure location in the same session"), EnsureRepeatMonitorResult.UnexpectedStopCount, 0);
	TestEqual(TEXT("Debugger.Binding.DebugBreakAndEnsure should not need any extra HasContinued messages during the repeat ensure phase"), EnsureRepeatMonitorResult.ContinuedCount, 0);
	TestTrue(TEXT("Debugger.Binding.DebugBreakAndEnsure should execute TriggerEnsure(false, Repeat) successfully without another stop"), bEnsureRepeatInvocationSucceeded);
	TestFalse(TEXT("Debugger.Binding.DebugBreakAndEnsure should still return false after TriggerEnsure(false, Repeat)"), bEnsureRepeatReturnValue);
	return !HasAnyErrors();
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerBindingCheckBreaksEveryInvocationTest,
	"Angelscript.TestModule.Debugger.Binding.CheckBreaksEveryInvocation",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerBindingCheckBreaksEveryInvocationTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebuggerTestSession Session;
	FAngelscriptDebuggerTestClient Client;
	if (!StartBindingDebuggerSession(*this, Session, Client))
	{
		return false;
	}

	const FAngelscriptDebuggerScriptFixture Fixture = FAngelscriptDebuggerScriptFixture::CreateBindingFixture();
	FAngelscriptEngine& Engine = Session.GetEngine();

	ON_SCOPE_EXIT
	{
		Client.SendStopDebugging();
		Client.SendDisconnect();
		Client.Disconnect();
		Engine.DiscardModule(*Fixture.ModuleName.ToString());
		CollectGarbage(RF_NoFlags, true);
	};

	if (!TestTrue(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should compile the binding fixture"), Fixture.Compile(Engine)))
	{
		return false;
	}

	FBindingCheckFixtureRuntime Runtime;
	if (!ResolveBindingCheckFixtureRuntime(*this, Engine, Fixture, Runtime))
	{
		return false;
	}

	AddExpectedError(TEXT("Check condition failed: CheckA"), EAutomationExpectedErrorFlags::Contains, 1);

	FBindingStopMonitorResult CheckAMonitorResult;
	bool bCheckAInvocationSucceeded = false;
	{
		Client.DrainPendingMessages();

		TAtomic<bool> bMonitorReady(false);
		TAtomic<bool> bMonitorShouldStop(false);
		TFuture<FBindingStopMonitorResult> MonitorFuture = StartBindingStopMonitor(
			Session.GetPort(),
			bMonitorReady,
			bMonitorShouldStop,
			Session.GetDefaultTimeoutSeconds());
		ON_SCOPE_EXIT
		{
			bMonitorShouldStop = true;
			if (MonitorFuture.IsValid())
			{
				MonitorFuture.Wait();
			}
		};

		if (!WaitForBindingMonitorReady(*this, Session, bMonitorReady, TEXT("Debugger.Binding.CheckBreaksEveryInvocation should bring the first check monitor up before invoking TriggerCheck(false, CheckA)")))
		{
			return false;
		}

		const TSharedRef<FAsyncGeneratedVoidInvocationState> InvocationState = DispatchGeneratedVoidInvocation(
			Engine,
			Runtime.Object,
			Runtime.TriggerCheckFunction,
			false,
			TEXT("CheckA"));
		if (!WaitForBindingInvocationCompletion(*this, Session, InvocationState, TEXT("Debugger.Binding.CheckBreaksEveryInvocation should finish TriggerCheck(false, CheckA) after the monitor resumes execution")))
		{
			return false;
		}

		bCheckAInvocationSucceeded = InvocationState->bSucceeded;
		bMonitorShouldStop = true;
		CheckAMonitorResult = MonitorFuture.Get();
	}

	if (!TestTrue(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should complete the first check phase without monitor errors"), CheckAMonitorResult.Error.IsEmpty()))
	{
		AddError(CheckAMonitorResult.Error);
		return false;
	}

	if (!TestFalse(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should not time out while monitoring TriggerCheck(false, CheckA)"), CheckAMonitorResult.bTimedOut))
	{
		return false;
	}

	if (!TestEqual(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should capture exactly one stop for TriggerCheck(false, CheckA)"), CheckAMonitorResult.StopEnvelopes.Num(), 1))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should deserialize the TriggerCheck(false, CheckA) stop payload"), CheckAMonitorResult.StopMessage.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should capture a callstack for TriggerCheck(false, CheckA)"), CheckAMonitorResult.Callstack.IsSet()))
	{
		return false;
	}

	const FAngelscriptCallStack& CheckACallstack = CheckAMonitorResult.Callstack.GetValue();
	if (!TestTrue(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should return at least one frame for TriggerCheck(false, CheckA)"), CheckACallstack.Frames.Num() > 0))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should report a breakpoint stop for TriggerCheck(false, CheckA)"), CheckAMonitorResult.StopMessage->Reason, FString(TEXT("breakpoint")));
	TestTrue(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should report the binding fixture filename for TriggerCheck(false, CheckA)"), CheckACallstack.Frames[0].Source.EndsWith(Fixture.Filename));
	TestEqual(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should stop TriggerCheck(false, CheckA) at BindingCheckLine"), CheckACallstack.Frames[0].LineNumber, Fixture.GetLine(TEXT("BindingCheckLine")));
	TestEqual(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should observe a single HasContinued after TriggerCheck(false, CheckA)"), CheckAMonitorResult.ContinuedCount, 1);
	TestTrue(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should execute TriggerCheck(false, CheckA) successfully after resume"), bCheckAInvocationSucceeded);

	AddExpectedError(TEXT("Check condition failed: CheckB"), EAutomationExpectedErrorFlags::Contains, 1);

	FBindingStopMonitorResult CheckBMonitorResult;
	bool bCheckBInvocationSucceeded = false;
	{
		Client.DrainPendingMessages();

		TAtomic<bool> bMonitorReady(false);
		TAtomic<bool> bMonitorShouldStop(false);
		TFuture<FBindingStopMonitorResult> MonitorFuture = StartBindingStopMonitor(
			Session.GetPort(),
			bMonitorReady,
			bMonitorShouldStop,
			Session.GetDefaultTimeoutSeconds());
		ON_SCOPE_EXIT
		{
			bMonitorShouldStop = true;
			if (MonitorFuture.IsValid())
			{
				MonitorFuture.Wait();
			}
		};

		if (!WaitForBindingMonitorReady(*this, Session, bMonitorReady, TEXT("Debugger.Binding.CheckBreaksEveryInvocation should bring the second check monitor up before invoking TriggerCheck(false, CheckB)")))
		{
			return false;
		}

		const TSharedRef<FAsyncGeneratedVoidInvocationState> InvocationState = DispatchGeneratedVoidInvocation(
			Engine,
			Runtime.Object,
			Runtime.TriggerCheckFunction,
			false,
			TEXT("CheckB"));
		if (!WaitForBindingInvocationCompletion(*this, Session, InvocationState, TEXT("Debugger.Binding.CheckBreaksEveryInvocation should finish TriggerCheck(false, CheckB) after the monitor resumes execution")))
		{
			return false;
		}

		bCheckBInvocationSucceeded = InvocationState->bSucceeded;
		bMonitorShouldStop = true;
		CheckBMonitorResult = MonitorFuture.Get();
	}

	if (!TestTrue(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should complete the second check phase without monitor errors"), CheckBMonitorResult.Error.IsEmpty()))
	{
		AddError(CheckBMonitorResult.Error);
		return false;
	}

	if (!TestFalse(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should not time out while monitoring TriggerCheck(false, CheckB)"), CheckBMonitorResult.bTimedOut))
	{
		return false;
	}

	if (!TestEqual(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should capture exactly one stop for TriggerCheck(false, CheckB)"), CheckBMonitorResult.StopEnvelopes.Num(), 1))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should deserialize the TriggerCheck(false, CheckB) stop payload"), CheckBMonitorResult.StopMessage.IsSet()))
	{
		return false;
	}

	if (!TestTrue(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should capture a callstack for TriggerCheck(false, CheckB)"), CheckBMonitorResult.Callstack.IsSet()))
	{
		return false;
	}

	const FAngelscriptCallStack& CheckBCallstack = CheckBMonitorResult.Callstack.GetValue();
	if (!TestTrue(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should return at least one frame for TriggerCheck(false, CheckB)"), CheckBCallstack.Frames.Num() > 0))
	{
		return false;
	}

	TestEqual(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should report a breakpoint stop for TriggerCheck(false, CheckB)"), CheckBMonitorResult.StopMessage->Reason, FString(TEXT("breakpoint")));
	TestTrue(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should report the binding fixture filename for TriggerCheck(false, CheckB)"), CheckBCallstack.Frames[0].Source.EndsWith(Fixture.Filename));
	TestEqual(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should stop TriggerCheck(false, CheckB) at BindingCheckLine"), CheckBCallstack.Frames[0].LineNumber, Fixture.GetLine(TEXT("BindingCheckLine")));
	TestEqual(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should observe a single HasContinued after TriggerCheck(false, CheckB)"), CheckBMonitorResult.ContinuedCount, 1);
	TestTrue(TEXT("Debugger.Binding.CheckBreaksEveryInvocation should execute TriggerCheck(false, CheckB) successfully after resume"), bCheckBInvocationSucceeded);
	return !HasAnyErrors();
}

#endif

