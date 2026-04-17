#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Examples_AngelscriptScriptExampleMixinMethodsTest_Private
{
	const AngelscriptScriptExamples::FScriptExampleSource GMixinMethodsExample = {
		TEXT("Example_MixinMethods.as"),
		TEXT(R"ANGELSCRIPT(
/**
 * Global functions declared with the 'mixin' keyword can only be called as methods.
 * The first paramater will be the type of object the method can be used on.
 *
 * The module must still be imported for the mixin method to be usable.
 *
 * This behaves similar to the ScriptMixin meta tag for C++ function libraries.
 */
mixin void ExampleMixinActorMethod(AActor Self, FVector Location)
{
	Print("Mixin invoked on: " + Self.GetClass().GetName());
}

void Example_MixinMethod()
{
    AActor ActorReference;
    ActorReference.ExampleMixinActorMethod(FVector(0.0, 0.0, 100.0));
})ANGELSCRIPT"),
		nullptr,
		nullptr,
	};
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExampleMixinMethodsTest_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExampleMixinMethodsTest, "Angelscript.TestModule.ScriptExamples.MixinMethods", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExampleMixinMethodsTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, GMixinMethodsExample);
}

#endif
