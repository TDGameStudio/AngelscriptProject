#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Examples_AngelscriptScriptExampleDelegatesTest_Private
{
	const AngelscriptScriptExamples::FScriptExampleSource GDelegatesExample = {
		TEXT("Example_Delegates.as"),
		TEXT(R"ANGELSCRIPT(/*
 * A function signature can be declared with the 'delegate' keyword,
 * this will create an unreal delegate type with this name. Delegates
 * can be used as arguments to functions, and are equivalent to
 * C++ DECLARE_DYNAMIC_DELEGATE() macros.
 */
delegate void FExampleDelegate_UnitTest(UObject Object, float Value);

UFUNCTION()
void ExecuteExampleDelegate(FExampleDelegate_UnitTest InDelegate)
{
	// You can check if a delegate is bound before executing it
	if (!InDelegate.IsBound())
	{
		Log("Input delegate was not bound.");
		return;
	}

	// To call a delegate, use either .Execute (errors out when unbound),
	InDelegate.Execute(nullptr, 5.4);

	// or .ExecuteIfBound, which does nothing if the delegate isn't boundd.
	InDelegate.ExecuteIfBound(nullptr, 1.0);
}

/*
 * Function signatures can also be declared with the 'event' keyword,
 * this allows creation of event dispatchers on script classes, letting
 * blueprints / level scripts bind to the events.
 *
 * Events cannot be passed as arguments to UFUNCTION()s, but can be
 * set as UPROPERTY()s on script classes.
 *
 * Events are equivalent to C++ DECLARE_DYNAMIC_MULTICAST_DELEGATE() macros.
 */
event void FExampleEvent_UnitTest(UObject Object, float Value);

class AExampleEventActor_UnitTest : AActor
{
	// Events declared as UPROPERTY() will become assignable by blueprint
	UPROPERTY(Category = "Example Events")
	FExampleEvent_UnitTest ExampleEvent;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// The example event is called whenever the level begins play
		// by using its .Broadcast() function. Broadcast never errors,
		// even if nothing is bound to the event, so you do not need
		// to check .IsBound() first.
		ExampleEvent.Broadcast(nullptr, 100.0);
	}

	/*
	 * Both delegates and events can be bound from script by using
	 * .BindUFunction() or .AddUFunction() respectively. Note that
	 * these can only bind functions that are marked UFUNCTION().
	 */
	UFUNCTION()
	void ExampleFunction(UObject InObject, float InValue)
	{
		Log("ExampleFunction: "+InValue);
	}

	UFUNCTION()
	void BindExampleDelegates()
	{
		// Bind the example function in this class to its example event.
		ExampleEvent.AddUFunction(this, n"ExampleFunction");

		// Execute the example event. This will call both functions bound above
		// as well as any blueprint nodes binding to the event.
		ExampleEvent.Broadcast(nullptr, 12.5);

		// Create a new delegate with the previously declared signature.
		FExampleDelegate_UnitTest ExampleLocalDelegate;

		// Immediately bind our example method to the delegate
		//  Note the n"" prefix to the string, this indicates a literal FName.
		//  Literal FNames get resolved at compile time, improving performance
		//  over constructing them dynamically.
		ExampleLocalDelegate.BindUFunction(this, n"ExampleFunction");

		// Pass it to the previously declared execution global function,
		// this will end up calling ExampleFunction twice.
		ExecuteExampleDelegate(ExampleLocalDelegate);
	}
};)ANGELSCRIPT"),
		nullptr,
		nullptr,
	};
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExampleDelegatesTest_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExampleDelegatesTest, "Angelscript.TestModule.ScriptExamples.Delegates", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExampleDelegatesTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, GDelegatesExample);
}

#endif
