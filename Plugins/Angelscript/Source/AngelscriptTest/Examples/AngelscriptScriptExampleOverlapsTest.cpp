#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Examples_AngelscriptScriptExampleOverlapsTest_Private
{
	const AngelscriptScriptExamples::FScriptExampleSource GOverlapsExample = {
		TEXT("Example_Overlaps.as"),
		TEXT(R"ANGELSCRIPT(/*
    For detecting overlaps on actors, override the
    ActorBeginOverlap and ActorEndOverlap functions,
    which provide the actor our overlap is with.
*/
class AExampleOverlapActor_UnitTest : AActor
{
    UFUNCTION(BlueprintOverride)
    void ActorBeginOverlap(AActor OtherActor)
    {
        Print("Overlapping with: "+OtherActor.Name);
    }

    UFUNCTION(BlueprintOverride)
    void ActorEndOverlap(AActor OtherActor)
    {
        Print("No longer overlapping with: "+OtherActor.Name);
    }
};

/*
    Component overlaps are slightly more tricky, because
    their overlaps use events, rather than functions to override.

    You will need to bind a function to their OnComponentBeginOverlap
    and OnComponentEndOverlap events, like this:
*/
class UExampleOverlapComponent_UnitTest : UPrimitiveComponent
{
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // Bind to the component's overlap events. This can of course
        // be one from outside the component as well, but we're doing it
        // in begin play now. The functions we bind must be UFUNCTION()s
        OnComponentBeginOverlap.AddUFunction(this, n"TriggeredOnBeginOverlap");
        OnComponentEndOverlap.AddUFunction(this, n"TriggeredOnEndOverlap");
    }

    UFUNCTION()
    void TriggeredOnBeginOverlap(
        UPrimitiveComponent OverlappedComponent, AActor OtherActor,
        UPrimitiveComponent OtherComponent, int OtherBodyIndex,
        bool bFromSweep, const FHitResult&in Hit)
    {
        Print("Overlapping with component: "+OtherComponent.Name);
    }

    UFUNCTION()
    void TriggeredOnEndOverlap(
        UPrimitiveComponent OverlappedComponent, AActor OtherActor,
        UPrimitiveComponent OtherComponent, int OtherBodyIndex)
    {
        Print("No longer overlapping with component: "+OtherComponent.Name);
    }
};)ANGELSCRIPT"),
		nullptr,
		nullptr,
	};
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExampleOverlapsTest_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExampleOverlapsTest, "Angelscript.TestModule.ScriptExamples.Overlaps", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExampleOverlapsTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, GOverlapsExample);
}

#endif
