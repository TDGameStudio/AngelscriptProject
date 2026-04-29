// AngelscriptASSDKThreadTests.cpp
// Tests for as_thread.cpp - thread-local storage via asCThreadManager.
// Automation IDs: Angelscript.TestModule.AngelScriptSDK.Thread.*

#include "Misc/AutomationTest.h"
#include "HAL/Runnable.h"
#include "HAL/RunnableThread.h"
#include "HAL/Event.h"
#include "HAL/PlatformProcess.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_thread.h"
#include "EndAngelscriptHeaders.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptASSDKThreadGetLocalDataNonNullTest,
	"Angelscript.TestModule.AngelScriptSDK.Thread.GetLocalDataNonNull",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptASSDKThreadGetLocalDataStableTest,
	"Angelscript.TestModule.AngelScriptSDK.Thread.GetLocalDataStable",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptASSDKThreadDifferentTLSTest,
	"Angelscript.TestModule.AngelScriptSDK.Thread.DifferentTLS",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASSDKThreadGetLocalDataNonNullTest::RunTest(const FString& Parameters)
{
	asCThreadLocalData* TLS = asCThreadManager::GetLocalData();
	TestNotNull(TEXT("GetLocalData on main thread should return non-null"), TLS);
	return true;
}

bool FAngelscriptASSDKThreadGetLocalDataStableTest::RunTest(const FString& Parameters)
{
	asCThreadLocalData* TLS1 = asCThreadManager::GetLocalData();
	asCThreadLocalData* TLS2 = asCThreadManager::GetLocalData();
	TestNotNull(TEXT("First GetLocalData should be non-null"), TLS1);
	TestNotNull(TEXT("Second GetLocalData should be non-null"), TLS2);
	TestEqual(TEXT("Two calls on same thread should return identical pointer"), TLS1, TLS2);
	return true;
}

namespace AngelscriptTest_AngelScriptSDK_Thread_Private
{
	class FTLSCaptureRunnable : public FRunnable
	{
	public:
		asCThreadLocalData* CapturedTLS = nullptr;
		FEvent* CompletionEvent = nullptr;

		explicit FTLSCaptureRunnable(FEvent* InEvent) : CompletionEvent(InEvent) {}

		virtual uint32 Run() override
		{
			CapturedTLS = asCThreadManager::GetLocalData();
			if (CompletionEvent) CompletionEvent->Trigger();
			return 0;
		}
	};
}

bool FAngelscriptASSDKThreadDifferentTLSTest::RunTest(const FString& Parameters)
{
	using namespace AngelscriptTest_AngelScriptSDK_Thread_Private;

	asCThreadLocalData* MainTLS = asCThreadManager::GetLocalData();
	TestNotNull(TEXT("Main thread TLS should be non-null"), MainTLS);

	FEvent* CompletionEvent = FPlatformProcess::GetSynchEventFromPool(true);
	FTLSCaptureRunnable Runnable(CompletionEvent);

	FRunnableThread* Thread = FRunnableThread::Create(&Runnable, TEXT("TLSCaptureThread"));
	if (!TestNotNull(TEXT("Should create worker thread"), Thread))
	{
		FPlatformProcess::ReturnSynchEventToPool(CompletionEvent);
		return false;
	}

	CompletionEvent->Wait();
	Thread->WaitForCompletion();
	delete Thread;
	FPlatformProcess::ReturnSynchEventToPool(CompletionEvent);

	TestNotNull(TEXT("Worker thread TLS should be non-null"), Runnable.CapturedTLS);
	TestNotEqual(TEXT("Worker thread TLS should differ from main thread TLS"), Runnable.CapturedTLS, MainTLS);
	return true;
}

#endif // WITH_DEV_AUTOMATION_TESTS
