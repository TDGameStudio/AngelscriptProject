#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Examples_AngelscriptScriptExampleStructTest_Private
{
	const AngelscriptScriptExamples::FScriptExampleSource GStructExample = {
		TEXT("Example_Struct.as"),
		TEXT(R"ANGELSCRIPT(/*
 * All structs are automatically bound to unreal and can
 * be used without further ado.
 *
 * Note that for technical reasons changing any properties
 * in a struct requires a full reload, regardless of whether
 * they are UPROPERTY() or not.
 */
struct FExampleStruct_UnitTest
{
	/* Properties with UPROPERTY() in a struct are reflected on generated types.
	 * Blueprint Make/Break exposure for script structs is currently disabled by default. */
	UPROPERTY()
	float ExampleNumber = 4.0;

	UPROPERTY()
	FString ExampleString = "Example String";

	/* Properties without UPROPERTY() will still be in the struct, but cannot be seen by blueprint. */
	float ExampleHiddenNumber = 3.0;
};

/* Structs can be used as properties in classes, or as arguments to functions. */
class AExampleStructActor_UnitTest : AActor
{
	UPROPERTY()
	FExampleStruct_UnitTest ExampleStruct;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print(ExampleStruct.ExampleString+", "+ExampleStruct.ExampleNumber);
	}

	/* Structs from C++ can of course be used as well. */
	UPROPERTY()
	FHitResult ExampleHitResult;
};)ANGELSCRIPT"),
		nullptr,
		nullptr,
	};
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExampleStructTest_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExampleStructTest, "Angelscript.TestModule.ScriptExamples.Struct", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExampleStructTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, GStructExample);
}

#endif
