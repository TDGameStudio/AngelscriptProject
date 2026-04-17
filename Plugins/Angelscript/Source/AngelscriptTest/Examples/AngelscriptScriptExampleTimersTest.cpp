#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Examples_AngelscriptScriptExampleTimersTest_Private
{
	const AngelscriptScriptExamples::FScriptExampleSource GTimersExample = {
		TEXT("Example_Timers.as"),
		TEXT(R"ANGELSCRIPT(/*
    This is an example of how to set a timer to call a function on
    an object at a later point in time.
*/

class AExampleTimerActor_UnitTest : AActor
{
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // Set a timer for 3 seconds after BeginPlay, that does not loop
        System::SetTimer(this, n"FunctionCalledByTimer", 3.0, bLooping=false);

        // SetTimer returns an FTimerHandle, which can be used to pause or stop
        // the specified timer.
        // NB: Functions can only have one timer at a time, using the same function to SetTimer
        //     twice will override the first timer.
        FTimerHandle SecondTimer = System::SetTimer(this, n"FunctionCalledBySecondTimer", 3.0, bLooping=false);

        // This branch toggles whether the timer is paused
        if (System::IsTimerPausedHandle(SecondTimer)) // Will always return true here
        {
            System::PauseTimerHandle(SecondTimer);
        }
        else
        {
            System::UnPauseTimerHandle(SecondTimer);
        }

        // Clear an active timer, preventing it from ever activating
        System::ClearAndInvalidateTimerHandle(SecondTimer);
    }

    // Note that like delegates, functions used in timers must always be UFUNCTION()s
    UFUNCTION()
    void FunctionCalledByTimer()
    {
        Print("Timer popped!");
    }

    UFUNCTION()
    void FunctionCalledBySecondTimer()
    {
        Print("Second timer popped!");
    }
};)ANGELSCRIPT"),
		nullptr,
		nullptr,
	};
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExampleTimersTest_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExampleTimersTest, "Angelscript.TestModule.ScriptExamples.Timers", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExampleTimersTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, GTimersExample);
}

#endif
