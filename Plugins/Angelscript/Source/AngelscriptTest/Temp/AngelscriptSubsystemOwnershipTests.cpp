#include "AngelscriptEngine.h"
#include "AngelscriptGameInstanceSubsystem.h"
#include "Misc/AutomationTest.h"
#include "Tickable.h"

#include <type_traits>

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineTickOwnershipTest,
	"Angelscript.TestModule.CppTests.Subsystem.EngineNoLongerTickable",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSubsystemTickOwnershipTest,
	"Angelscript.TestModule.CppTests.Subsystem.GameInstanceSubsystemOwnsTick",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEngineTickOwnershipTest::RunTest(const FString& Parameters)
{
	TestFalse(
		TEXT("FAngelscriptEngine should no longer inherit FTickableGameObject once subsystem tick ownership is enabled"),
		std::is_base_of_v<FTickableGameObject, FAngelscriptEngine>);
	return true;
}

bool FAngelscriptSubsystemTickOwnershipTest::RunTest(const FString& Parameters)
{
	TestTrue(
		TEXT("UAngelscriptGameInstanceSubsystem should inherit FTickableGameObject to own primary-engine ticking"),
		std::is_base_of_v<FTickableGameObject, UAngelscriptGameInstanceSubsystem>);
	return true;
}

#endif
